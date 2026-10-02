---
name: long-running-jobs
description: Use whenever you expect, presume, or plan for a command/script to take more than a couple of minutes (definitely anything over ~5 minutes) — builds, big test suites, image pulls/scans, bulk cluster sweeps, migrations, long waits. Run it as a durable `systemd-run --user` unit instead of inline or as a Bash background job, so it survives session restarts/compaction.
---

Anything that may run for more than a couple of minutes does **not** go inline and does **not** go into `run_in_background` / `&`. Those die or lose their output when this session restarts, compacts, or the agent worker gets recycled. A transient systemd user unit keeps running and keeps its output in the journal no matter what happens to the session.

If in doubt about the duration, treat it as long-running.

Helper scripts live next to this skill (`~/.claude/skills/long-running-jobs/scripts/`) and do all of the below for you — use them instead of hand-rolling `systemd-run`/`systemctl` calls. Every script takes just the short `<identifier>` you picked at start time; none of them need you to know or re-parse `$AOE_ARTIFACT_DIR` yourself (`scripts/_lib.sh`, sourced by all of them, derives the unit name and job dir from it once).

## Start

```bash
~/.claude/skills/long-running-jobs/scripts/start-job.sh <identifier> <command...>
```

e.g.:

```bash
~/.claude/skills/long-running-jobs/scripts/start-job.sh helm-lint-all bash -c 'go-task lint-all > "$JOB_DIR/result.txt"'
```

`start-job.sh` handles all of the following itself:

- **Naming**: unit = `agent-<aoe-session-id>-<identifier>`, where `<aoe-session-id>` = `basename "$AOE_ARTIFACT_DIR"` (outside AoE: `noaoe`) and `<identifier>` is the first argument you give it. `agent-` prefix on every unit makes agent-started jobs instantly recognizable (and greppable) alongside the user's own units. Pick a short kebab-case `<identifier>` you'll recognize later (`helm-lint-all`, `trivy-scan-capi-images`); allowed chars `[a-zA-Z0-9:_.-]`; make it unique per job, reuse only for a deliberate re-run of the same job.
- **Slice**: runs in `agent.slice` (auto-created on first use) — separate cgroup subtree from the user's own interactive units, for bulk inspection/accounting.
- **Data directory**: creates `$XDG_STATE_HOME/agent-jobs/<aoe-session-id>/<identifier>/` (`~/.local/state/agent-jobs/...` by default) and passes it to your command as `$JOB_DIR` — write real output data there (`result.json`, reports, anything you'll parse later), the journal is for logs/progress only. Auto-cleaned after ~30 days (`~/.config/user-tmpfiles.d/agent-jobs.conf`) — copy anything worth keeping elsewhere.
- **Completion notification**: wires up `ExecStopPost` so this same AoE session gets `aoe send`-messaged the moment the job ends — see "Notify on completion" below.
- Prints `Started <unit> -- job dir: <path>` — tell the user the unit name so they can follow along with `journalctl --user -fu <unit>` if they want to.
- `--collect`: the unit is garbage-collected once it exits (success or failure) so the name is free for a later re-run, and it drops out of `systemctl --user list-units` shortly after finishing — the job dir (see `job-output.sh`) is the durable record, not the unit list.
- `--same-dir`: runs in your current working directory.

**Env forwarding**: `PATH`, `JOB_DIR`, and `AOE_ARTIFACT_DIR` are always forwarded (the user manager does **not** inherit your shell's environment otherwise). For anything else the command needs (`KUBECONFIG`, `GOTOOLCHAIN`, ...), set `AGENT_JOB_EXTRA_ENV="NAME1 NAME2"` before calling `start-job.sh` — it forwards each as a bare `-E NAME` (copies the *current* value from your shell, no `=value` needed). Never put secrets on the command line; let the tool read them from its usual credential store, or forward an already-set env var the same way.

Other notes that still apply when using the wrapper:
- Tools not installed: wrap the command in `nix-shell -p <pkg> --run '...'`, same as inline.
- Multi-step/complex commands: write a script into `$JOB_DIR/run.sh` first (a normal `Write`, before calling `start-job.sh`) and pass `bash "$JOB_DIR/run.sh"` as the command — easier to re-run and inspect than a giant inline string, and avoids fighting shell-quoting across two layers (your shell → `start-job.sh` → the unit).

**When not to use the wrapper**: it always wires up the completion notification and always uses the standard naming/data-dir convention. If you genuinely need something outside that (e.g. deliberately no notification, a custom unit name, extra `systemd-run` properties), fall back to a raw `systemd-run --user --collect --slice=agent --unit=... ...` call following the same conventions by hand.

## Notify on completion

`start-job.sh` wires up `ExecStopPost=bash <skill-dir>/scripts/notify-on-completion.sh <unit>`, which sends this same AoE session a message when the job ends — success, failure, or killed — via `aoe send <aoe-session-id> "<message>"` (see the `aoe-cli` skill for `aoe send`'s exact semantics; it auto-revives a dead/stopped session by default, so the notification reaches you even if the session restarted while the job ran). You don't need to poll for completion with this wired up — the message just arrives.

`ExecStopPost` fires unconditionally on every termination path (normal exit, non-zero exit, signal/OOM-kill) — unlike a manual `; rc=$?; ...` chain tacked onto the job command, which only fires on a clean shell exit. systemd exposes `$SERVICE_RESULT` (`success`/`exit-code`/`signal`/...), `$EXIT_CODE`, `$EXIT_STATUS` to `ExecStopPost` automatically. `notify-on-completion.sh` reads the session id from `$AOE_ARTIFACT_DIR` (forwarded to the unit as a bare `-E AOE_ARTIFACT_DIR`, i.e. copied once from the launching shell) rather than requiring each caller to derive and bake in the session id itself — confirmed working end-to-end (2026-09-25), including the failure/exit-code path.

If you ever build this by hand instead of via `start-job.sh` (see "when not to use the wrapper" above): pass a **static script path** to `ExecStopPost`, not an inline `--property="ExecStopPost=bash -c '...'"` string. Nesting the quoting needed for a mix of now-expand (your own shell's variables) and later-expand (`$SERVICE_RESULT`, `$EXIT_STATUS`, set by systemd at completion time) variables inside one `--property=` argument is fragile and silently mis-parses (confirmed breaking on an innocuous-looking bash array while building this). `notify-on-completion.sh` is that static script — reuse it (it only needs `AOE_ARTIFACT_DIR` and, optionally, `JOB_DIR` forwarded, plus the unit name as `$1`) rather than writing a new one.

## Check on it (or stop it)

With the notification wired up (the default via `start-job.sh`) you generally don't need this mid-run — but it's useful to check progress, or as a fallback if a notification somehow didn't land:

```bash
~/.claude/skills/long-running-jobs/scripts/job-status.sh <identifier>              # is-active + last 50 journal lines
~/.claude/skills/long-running-jobs/scripts/job-status.sh <identifier> -n 200       # last 200 lines
~/.claude/skills/long-running-jobs/scripts/job-status.sh <identifier> --full       # whole journal for the latest invocation
~/.claude/skills/long-running-jobs/scripts/job-status.sh <identifier> --stop       # also stop it after showing status
```

Done lines in the journal look like `Main process exited, code=exited, status=N/...` and `Deactivated successfully.` / `Failed with result 'exit-code'.`

## Get the output/results

The journal (`job-status.sh`) is logs/progress; the job dir is where real result data lives (`$JOB_DIR` inside the job — see "Start" above):

```bash
~/.claude/skills/long-running-jobs/scripts/job-output.sh <identifier>              # list what the job wrote
~/.claude/skills/long-running-jobs/scripts/job-output.sh <identifier> result.json  # print one file from the job dir
```

## Find your jobs again

```bash
~/.claude/skills/long-running-jobs/scripts/list-jobs.sh                 # this session's units + job dirs
~/.claude/skills/long-running-jobs/scripts/list-jobs.sh --all-sessions  # every agent job on the machine, by cgroup (systemd-cgls)
```

A finished job's unit disappears from the first form shortly after completion (`--collect`) — its job dir (and `notify.log`, written by `notify-on-completion.sh`) is the durable record of what happened, not the unit list.
