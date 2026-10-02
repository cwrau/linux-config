---
name: aoe-cli
description: Reference for interacting with Agent of Empires (`aoe`) — the tmux/ACP session manager this and most other sessions run under. Load before listing/finding sessions, messaging or waking another session, creating a new session (especially with a worktree), renaming/trashing/restoring sessions, checking what's running, or managing plugins. Covers session-identity conventions, the exact CLI flags in current use, and known gotchas (worktree-creation trap, schema-version mismatches, the Monitor tool's wake-trigger not surviving restarts).
---

`aoe` is the session manager this session (and most others on this machine) runs inside. This is a command reference distilled from real usage across ~700 distinct `aoe` invocations in prior sessions plus the current CLI's own `--help` output — not a workflow to follow top to bottom, jump to the relevant section.

## Session identity

- **This session's own ID** = `basename "$AOE_ARTIFACT_DIR"`. Also available via `aoe session current --json | jq -r .id` or `aoe session current -q` (bare id, for scripting).
- **Web URL for a session**: `https://agent.cwrau.de/session/<id>` — **singular** `/session/`, not `/sessions/.../acp`. The plural form exists in the aoe source (`web/public/sw.js`, internal API/websocket route) but is not the public deep-link.
- Session IDs are 16-char hex strings — don't confuse with `$CLAUDE_CODE_SESSION_ID` (a UUID, the Claude SDK's own unrelated session id).

## Finding sessions

`aoe list --json` is the main enumeration tool. Fields: `id`, `title`, `path`, `group`, `state` (`live`/`trashed`/`archived` — note `--state=` filter only accepts `live`/`trashed`/`all`, archived rows show up under `all`), `tool`, `profile`, `created_at`, `archived_at`, `workspace_repos`.

```bash
aoe list --json --state=live | jq -r '.[] | select(.group == "<name>") | "\(.id)\t\(.title)"'
aoe list --json | jq -r '.[] | select(.title | test("pattern"; "i")) | .id'
```

`--all` includes other profiles; plain `aoe list --json` defaults to `--state=all` (every persisted session, including trashed/archived) despite the name — filter explicitly if you want only live ones.

**Duplicate-session gate-check pattern** (used by cron jobs to avoid racing a still-running prior instance of themselves): list live sessions in your own `group`, compare `created_at` against your own session's — if a sibling is newer, abort.

`aoe ps` / `aoe ps --acp [--json]` — substrate-agnostic runtime view: tmux panes and ACP structured-view workers, one row each. Useful to see what's *actually running* right now vs. what's merely registered in `aoe list`.

`aoe session show <id>` — full details on one session.

## Messaging / waking a session

`aoe send <id-or-title> "<message>"` — sends a message to a running session, **auto-reviving it if dead/stopped** (pass `--no-revive` to fail loud instead, e.g. for a script that wants the old bail-out behavior). Works for both tmux-based and structured-view/ACP sessions (goes through the daemon's prompt endpoint for the latter). This is the primitive for "wake another session and tell it something" — e.g. `pr-watch` uses it to deliver review/CI events to the session that owns a PR.

```bash
aoe send fix-validate-title-ci "Investigate why PR #2375 fails the Validate Title check..."
```

## Creating a session

`aoe add [PATH] [OPTIONS]` — `PATH` defaults to cwd, omit entirely when using `--scratch`.

**Always pass `--structured-view --agent claude-code` (or another ACP-capable `--agent`).** `aoe add` defaults to a raw tmux/PTY terminal session — that's a bare TUI with nobody attached, useless for a session created programmatically (nothing renders it, nothing can drive it usefully via `aoe send`). `--structured-view` is what makes it an actual ACP session: rendered natively, and — critically — **its worker lifecycle is via `aoe serve`, auto-spawning on the first `aoe send`**, so `-l/--launch` becomes a no-op and isn't needed once you're using structured-view. Don't create a session without this flag pair unless the user explicitly wants a plain terminal session for themselves to attach to.

**Worktree gotcha (bit twice before, confirmed via `aoe list`):** to create a session with its own git worktree, pass **the main repo's path** as `PATH` and let `-w` generate/attach the worktree:

```bash
aoe add <main-repo-path> -w <branch-name> [-b] [--base-branch <ref>] --structured-view --agent claude-code
```

**Never point `PATH` directly at an already-existing worktree directory** (e.g. `<repo>-worktrees/<name>`) — that registers the worktree as its own orphan project instead of attaching it as a session of the parent repo. A correctly-created session shows the *main repo path* in `aoe list`'s `path` field even though it actually runs in a worktree — that's the signal to check if unsure. If a worktree/branch already exists from a botched attempt: `aoe remove <title> --purge`, then `git worktree remove -f -f <path>` and (if it has no real commits beyond base drift) `git branch -D <branch>`, before recreating.

Other flags worth knowing: `-b/--new-branch` (with `--base-branch`, useful for stacking on an in-flight PR branch), `--fork-from <session>` (resume another session's context in a new, independently-diverging session — claude/codex/opencode only), `--scratch` (fresh scratch dir under `<app_dir>/scratch/<id>/`, mutually exclusive with worktree flags, removed on `aoe rm` unless `--keep-scratch`), `-s/--sandbox` (container sandbox), `-P/--parent <session>` (sub-session, inherits group).

## Renaming, trashing, restoring

- `aoe session rename <id-or-title> -t "<new title>"` — e.g. the `[merged] ` prefix convention: `aoe session rename "$(basename "$AOE_ARTIFACT_DIR")" -t "[merged] <original title>"`. Prefix, not suffix; check for it first so re-running doesn't double-tag.
- `aoe remove <id-or-title>` — trashes by default (recoverable). `aoe session restore <id>` undoes it. `aoe remove --purge` (or `aoe rm --purge`) permanently deletes — irreversible, also tears down worktree/branch/container per flags (`--delete-worktree`, `--delete-branch`, `--force`, `--keep-container`, `--keep-scratch`).
- `aoe session list-trash` — see what's in the trash before purging.

## Watching for completion / long-running work

Two different concerns, don't conflate them:
- **The underlying watch/poll mechanism** should be durable — see the `long-running-jobs` skill (systemd-run user units) for anything that itself takes more than a couple of minutes, and the `pr-watch` skill for PR/MR review-and-CI watching specifically.
- **The `Monitor` tool's wake-trigger does not survive this session restarting or being compacted** — it's tied to the current process. The polling/collection logic can keep running fine (e.g. a systemd unit), but the "wake me up when it's done" half dies silently and needs re-arming. Warn the user up front for any "keep watching, wake me when X" request rather than letting them assume it's durable.

## Plugins

`aoe plugin list/info/install/uninstall/update/hash/discover/outdated`. Install from a local dir (`aoe plugin install <path> --yes`) or `gh:owner/repo[@ref]` slug (no `@ref` = latest release; an explicit ref installs unaudited code). Plugins run as Tier-1 workers the daemon itself supervises (ndjson JSON-RPC over stdio) — not subject to any session/Monitor timeout, the natural place for genuinely persistent background logic tied to aoe itself. See `~/projects/aoe/docs/plugin-api.md` for the manifest schema if building one; `~/.config/agent-of-empires/plugins/agent-of-empires.github/` is a real worked example. Note: **plugins cannot register their own MCP servers** (moved into core as of manifest api_version 10) — a plugin that needs to expose tools to an agent needs a separate standalone MCP server alongside it.

**Cron plugin jobs specifically**: there's no `aoe schedule` CLI — jobs are meant to be edited via the TUI/web dashboard, but hand-editing `~/.config/agent-of-empires/config.toml`'s `[[plugins."agent-of-empires.cron".settings.jobs]]` array directly also works, **without needing `aoe serve --restart`** — confirmed a new/edited job took effect live (2026-09-24). Validate the TOML parses (`python3 -c "import tomllib; tomllib.load(open('...', 'rb'))"`) before trusting an edit. Match the existing schema exactly: `agent_id`, `enabled`, `group` (also the spawned session's group — give the job its own group distinct from any group it queries/pings, or its duplicate-session gate-check will collide with what it's searching for), `id` (a fresh UUID), `mode_id`, `model_id`, `name`, `project_paths` (`["/home/cwr/.cache/agent-of-empires/cron-plugin/runtime"]` for jobs that don't need a specific repo), `prompt`, `sandbox`, `schedule` (5-field cron). Every existing job's prompt starts with the same duplicate-session-gate-check boilerplate (compare own `created_at` in `aoe list --json --state=live` filtered to its own group against siblings, abort if a newer one exists) and ends with unconditionally trashing its own group's old sessions — cron jobs share one plugin-wide concurrency cap (5 active sessions), so a job that doesn't clean up after itself can starve every other cron job.

## ACP / structured-view sessions

`aoe acp agents` (list supported agents + install status), `aoe acp doctor` (diagnose a broken ACP worker), `aoe acp history <id> [--json]` (dump a session's transcript), `aoe acp prompt`, `aoe acp stop`. `aoe url` prints the running daemon's URL; `aoe serve` starts it (`--restart` to bounce it).

## Other useful subcommands

- `aoe project add <path> --name <name>` / `list` / `remove` — the registry multi-repo session pickers draw from.
- `aoe group delete <name> --force` — remove a session group.
- `aoe session set-worktree-name` — rename a managed worktree's directory (and optionally branch); session must not be running.
- `aoe session import --dry-run --all` / `--group <name> --yes <path...>` — bulk-import existing on-disk Claude Code conversations as sessions.
- `aoe session current [--json|-q]` — what this skill's "session identity" section above is built on.

## Known gotchas

- **Plugin/schema version mismatch**: `aoe plugin list` (and similar) can fail with `data schema version N is newer than this build supports` inside a sandboxed runtime whose pinned `aoe` build is older than the one that wrote the data (e.g. a cron-plugin runtime dir vs. the main installed `aoe`). Not a real error to chase — it's a version skew between two `aoe` binaries on the same machine.
- **Structured-view worker conflict**: `Failed to start structured view agent '<tool>': session ... already has a running structured view worker` — a recurring harness-level concurrency bug (already tracked upstream), not something to work around by retrying blindly.
- **Rate-limit duplicate-prompt bug**: on `RateLimit` → `RateLimitAutoResumed`, the harness can re-fire the original prompt as a brand-new one instead of resuming the paused turn — filed upstream, still recurring as of the most recent weekly digest (`~/.config/agent-of-empires/weekly-learnings-log.md`). If a session's transcript shows the same prompt landing many times in a row, this is why.
- `AOE_INSTANCE_ID` / `AOE_HOOK_BIN` env vars drive the status-file plumbing under `/tmp/aoe-hooks-<uid>/<instance-id>/status` (waiting/idle/running) that the TUI dashboard reads — internal wiring set up via `~/.claude/settings.json` hooks, not something to invoke directly.
