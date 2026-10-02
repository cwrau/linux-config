---
name: dependency-mr-review
description: Use in the current session (not as a delegated subagent) to triage and merge automated dependency-update MRs/PRs (renovate, dependabot, or similar bots) in a repo. Triggers on "review and merge update MRs", "see if the renovate MRs can merge", "is it safe to merge <dependency> bump", or similar. This is inherently a long-running task (batch triage, then react to pipeline/merge/conflict events over hours) — stay in this session, use `pr-watch` to get woken on events instead of polling, and never merge/approve anything without the user's explicit go-ahead first.
---

This runs in the current session, not as a spawned subagent — the whole point is that it can span hours (waiting on pipelines, merge queues, renovate rebases) and get woken back up by `pr-watch` notifications or the user returning, instead of running to completion in one isolated shot. Don't dispatch this via the Agent tool.

## The one rule that overrides everything else

**Checking mergeability is not authorization to merge.** "Review the MRs," "see if X can merge," "check if these are mergeable" — all of these mean triage and report, then stop and wait. Only proceed to approve/merge once the user has explicitly said to (a blanket "merge the safe ones" after you've presented your triage counts as authorization for that batch; it does not authorize anything you didn't already flag as safe). This has burned the user before — an earlier session merged 7 renovate MRs off "see if can merge them" when only a check was wanted. When in doubt, present and ask.

## Workflow

### Phase 0: Load current standing rules

Read these three memory files before doing anything — they hold specifics (exact commands, exact usernames, which repos) that drift over time and are the source of truth, not this skill:
- `~/.claude/memory/feedback_mr_defaults.md` — GitLab MR reviewer/label/auto-merge defaults, and the `glab mr merge --auto-merge` bug + raw-API workaround + mandatory post-push verify step.
- `~/.claude/memory/feedback_github_automerge_defaults.md` — which GitHub repos get auto-merge by default.
- `~/.claude/memory/feedback_renovate_conflict_resolution.md` — the don't-hand-resolve-lockfile-conflicts rule, with its precise scope.

If any of these files don't exist or don't say what you expect, don't assume — fall back to the guidance below and flag the discrepancy to the user.

### Phase 1: Discover

Determine the host from `git remote get-url origin` (github.com → GitHub/`gh`; anything else, e.g. gitlab.teuto.net → GitLab/`glab`, set `GITLAB_HOST`).

List **all** open bot-authored MRs/PRs at once — batch, never one at a time:

**GitHub:**
```bash
gh pr list --search "author:app/renovate" --json number,title,mergeable,mergeStateStatus,statusCheckRollup,autoMergeRequest,headRefName --limit 50
# dependabot too, if present:
gh pr list --search "author:app/dependabot" --json number,title,mergeable,mergeStateStatus,statusCheckRollup,autoMergeRequest,headRefName --limit 50
```

**GitLab:**
```bash
glab mr list --repo <path>   # or --all if labels/state filtering hides drafts you need to see
```
If a label-based filter (`labels[]` containing "dependenc...") returns nothing, don't conclude there are no dependency MRs — fall back to listing *all* open MRs and identifying dependency bumps by branch-name prefix (`renovate/*` is the observed convention here). Non-bot branches (`feat/*`, `Draft:*`, human-authored work) are out of scope — exclude them by inspection, don't touch them.

### Phase 2: Batch triage (cheap gate before any diff review)

For every candidate, fetch mergeability/conflict/pipeline status **before** looking at diffs — this is a cheap filter that immediately separates "just needs approval" from "has a real problem":

**GitHub:**
```bash
for n in <numbers>; do
  gh pr view $n --json number,title,mergeable,mergeStateStatus,autoMergeRequest,statusCheckRollup \
    -q '{number,title,mergeable,mergeStateStatus,autoMerge: .autoMergeRequest, checks: [.statusCheckRollup[] | {name,status,conclusion}]}'
done
gh pr checks $n --required   # required checks only -- tolerate non-required flakes
```

**GitLab:**
```bash
for iid in <iids>; do
  glab api "projects/<url-encoded-path>/merge_requests/$iid" \
    | jq -r '"title=\(.title) merge_status=\(.detailed_merge_status) conflicts=\(.has_conflicts) pipeline=\(.head_pipeline.status // "none")"'
done
```

Bucket into:
- **Clean**: required checks green, no conflicts, only blocked on missing approval.
- **Needs investigation**: CI red, conflicts, major/breaking version bump, or touches critical/high-blast-radius infra (e.g. a cluster-lifecycle engine, prod-facing config, anything where "still compiles" doesn't prove "still behaves correctly").
- **Duplicate**: same dependency/version bumped by two bots (renovate + dependabot) — keep renovate as primary (it's this user's primary dependency tool), plan to close the other with a comment explaining why.

### Phase 3: Investigate the "needs investigation" bucket

Don't stop at "CI is red" or "it's a major bump" — dig in enough to give the user a real verdict, not just a red flag:

- **CI failure**: root-cause it before deciding rerun vs. real regression. `gh run view <id> --log-failed | tail -60` / `glab api .../jobs/$id/trace | tail -60`. A rate-limited/infra-flake failure (runner shutdown, transient 429) gets rerun; a real compile/test break gets left alone and flagged.
- **Major/breaking version bump**: read the upstream changelog/release notes (`gh release view <tag> --repo <upstream>`) before trusting green CI alone — a passing build only proves it still compiles, not that behavior is unchanged. Weigh this especially heavily for anything with wide blast radius (core infra, cluster-lifecycle code, anything prod touches) — hold off and flag rather than merge on green CI alone when the changelog lists real breaking changes.
- **"No-op" bump detection**: before assuming a version bump needs a real code migration, grep whether the module is actually imported/used (`rg -n "<module>" --type <lang> -g '!vendor' .`, check for an `h1:` hash in `go.sum`, etc.). A bump that only touches `go.mod`/`package.json` bookkeeping with no actual usage is safe to merge as-is but should be flagged as cosmetic, not a real migration.
- **Real migration needed** (import path changed, API changed): if you can do it, do it in an isolated worktree off the bot's own branch, validate with the repo's actual task runner (`go-task ci` / `go-task check-diff` / whatever the repo's own CI invokes — never bypass with raw `go build`/`go test` if a task target exists, that's a hard rule violation), then **force-push onto the bot's existing branch** (`git push origin HEAD:refs/heads/<bot-branch> --force-with-lease`) rather than opening a new MR — this reuses the existing bump instead of duplicating it. Amend the bot's own commit rather than adding a new one if it's a small fixup. Confirm with the user before doing the actual migration work, not just before merging.
- **Lockfile conflicts** (`go.mod`/`go.sum`, `package-lock.json`, etc.) that are a *real* content divergence (two bumps touching the same entry), not just a stale digest: **do not hand-resolve.** Leave the MR for the bot's own rebase pass — see `feedback_renovate_conflict_resolution.md`. A trivial stale-digest conflict fixable by a plain rebase is fine to do yourself. Non-lockfile conflicts (e.g. a CI config file) can be hand-fixed if trivial, but confirm with the user first if it's not obviously mechanical.
- **Infra/cluster-affecting bumps**: if relevant tooling is available (capi-shell-mcp or similar) and the bump's safety depends on live cluster state (e.g. "is anything still using the old API version"), check it rather than reasoning from the diff alone.

### Phase 4: Present findings and get confirmation

Report, per MR/PR: number, title, verdict (merge / hold-flagged / close-as-duplicate), and your reasoning. Group similar failures (e.g. "4 PRs failing the same lint job, likely one root cause") rather than listing them as unrelated unknowns. Then **stop and wait** — do not proceed to Phase 5 without explicit confirmation, even if everything looks obviously safe.

### Phase 5: Execute (only after confirmation)

- **Approve the agreed-safe batch.** Check whether the bot already has auto-merge armed (GitHub renovate PRs typically do — `autoMergeRequest.enabledBy: app/renovate`) — if so, approving is the only action needed, don't also call merge. Otherwise merge explicitly:
  - GitHub: `gh pr merge <n> --auto --squash` (or per repo default — see `feedback_github_automerge_defaults.md`).
  - GitLab: prefer the raw-API path from `feedback_mr_defaults.md` (`glab mr merge`'s `--auto-merge` flag has a known bug that misreports "pipeline failed" when the real blocker is missing approval) — `glab api -X PUT ".../merge_requests/$iid/merge" -f merge_when_pipeline_succeeds=true`, then verify `merge_when_pipeline_succeeds` came back `true`.
- **Close duplicates/superseded MRs** with a comment naming which MR supersedes them: `gh pr close <n> -c "Duplicate of #<other>, which covers the same bump. Keeping <bot> as primary."` / `glab api -X PUT ".../merge_requests/$iid" -f state_event=close`.
- **Leave flagged ones untouched** — don't force a decision the user didn't make.

### Phase 6: Watch what's left, and keep the session alive for it

Register `pr-watch` on anything not yet terminal (merged/closed), filtered to **merge/close/conflict-type events only** — explicitly exclude REVIEW and CI events, the user has corrected this twice ("don't watch review or ci"). Unregister once an item reaches a terminal state. If a `pr-watch` tool call fails on parameter shape (e.g. singular vs. plural), reread the `pr-watch` skill rather than guessing — this is a skill-owned tool shape, not something to memorize a workaround for.

This is the phase where the task genuinely runs long (real sessions doing this have spanned hours to days, resuming across rate-limit hits and idle gaps). Stay in this session rather than handing off — react to each `pr-watch` notification as it arrives (re-check state, re-approve after a stale-review dismissal, rebase-nudge, etc.), don't synchronously poll/wait for it.

### Phase 7: Final report

Give a human-readable summary using titles, not bare numbers — "merged: helm chart X bump, operator image Y bump, ... — held back: Z (major version, breaking changes in changelog) — closed as duplicate: W". If asked later whether something merged, re-query live state rather than trusting your own earlier summary.

## Quality standards

- Never merge/approve without explicit confirmation for that specific batch, even for "obviously safe" patch bumps.
- Never hand-resolve a real lockfile conflict on a bot branch.
- Never bypass a repo's task runner for validation when a task target exists.
- Never silently fold newly-appeared MRs into an in-progress review pass — flag them as new and ask.
- Weigh blast radius explicitly for infra/critical-path dependencies — green CI is necessary but not sufficient for those.
- Report what was skipped and why, plainly — don't just report successes.

## Error handling

- If `glab mr merge`/`gh pr merge` fails unexpectedly, check the known-bug memory files before reporting it as a real blocker.
- If a repo has no open bot MRs, say so clearly and exit — nothing to do.
- If host/tooling detection is ambiguous, ask rather than guessing wrong and running the wrong CLI.

## Saving what you learn

If you hit a genuinely new, recurring judgment call (a repo-specific high-blast-radius dependency, a durable preference about merge order, etc.), save it as a normal global memory file under `~/.claude/memory/` (feedback/project type as appropriate) and index it in `~/.claude/memory/MEMORY.md` — same as any other standing learning in this session, not a separate memory store.
