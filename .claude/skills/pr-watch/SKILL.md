---
name: pr-watch
description: Register a persistent watch on a just-created PR/MR for review, CI, and merge/close activity. Use immediately after `gh pr create`, `glab mr create`, or the raw-API MR/PR workaround succeeds — not for checking on PRs you didn't just open.
---

Normally you don't need to do anything: the worker auto-discovers this session's own git checkout (whatever branch it's currently on), notices the open PR/MR you just created, and starts watching it automatically within one scheduler tick — no `register` call required for that case at all. Only reach for the explicit steps below when you want something auto-discovery can't give you:

- **Instant coverage**, not up-to-a-tick-later (e.g. you want to be sure it's watched before doing anything else).
- **An `events` filter from the start** — auto-discovery always registers unfiltered (every event kind); narrowing it takes an explicit call regardless.
- **A PR/MR that isn't the one on this session's current branch** — auto-discovery only ever looks at your own checkout.

1. Resolve `$AOE_ARTIFACT_DIR` to its actual value — e.g. `echo "$AOE_ARTIFACT_DIR"`. **Pass that resolved value, never the literal text `$AOE_ARTIFACT_DIR`** — it does not get expanded inside a tool call's arguments the way it would in a shell command, so typing the variable name itself produces a `session_id` no real session will ever match (confirmed live: a registration stuck with `session_id="$AOE_ARTIFACT_DIR"` verbatim, silently auto-stopped because nothing matched it).
2. Call the `register` tool on the `pr-watch` MCP server with the PR/MR URL and that resolved value as `session_id`. It's fine to pass the full path (`/home/.../artifacts/<id>`) as-is — every `pr-watch` tool that takes `session_id` extracts the basename itself server-side, so there's no need to also run `basename` yourself:

```
mcp__pr-watch__register({
  pr_urls: ["<pr-or-mr-url>"],
  session_id: "<resolved value of $AOE_ARTIFACT_DIR>",
})
```

`pr_urls` takes one or more URLs in a single call — pass a list to register several PRs/MRs for this session at once (e.g. a stacked-PR chain), all under the same `events` filter if given. One malformed URL in the list doesn't block the rest: the response's `results` array reports each URL's own outcome (`{pr_url, registered, error?}`), and the call only fails outright if every URL in it failed.

Optional `events` param: a list restricting which event kinds actually ping this session (`REVIEW`, `COMMENT`, `CI`, `CONFLICT`, `MERGED`, `CLOSED`, `MERGE_QUEUE` — see the shapes below). Omit it for the default, every kind. Only use it when told to only care about a subset, e.g. `events: ["MERGED"]` to stay silent until it merges or closes — never narrow it unprompted. Re-registering the same URL from the same session with a different `events` list just replaces the filter, same as any other re-register.

That's it — the watch is now persistent. It's a background AoE plugin worker, not a `Monitor` call: it survives session restarts and compaction, paces its own polling against GitHub/GitLab rate limits, and pushes a message straight into this session (via `aoe send`, auto-reviving it if it's stopped) whenever something changes. There is no timeout to track and nothing to re-arm — register once and move on.

`register` is idempotent for your own session: calling it again for the same URL from the same session just refreshes it, so if you're ever unsure whether you've already registered, calling it again is harmless — this applies per URL, so re-registering a `pr_urls` batch that overlaps an earlier one just refreshes whichever ones already existed. It does not reassign ownership — a URL another session already watches gets its own independent registration for you too (multiple sessions can watch the same PR/MR, each getting their own notifications), not a takeover of theirs.

The worker polls the PR (GitHub, via `gh`) or MR (GitLab/tickets.teuto.net, via `glab`) and delivers one message per poll that found a change, straight into this session as if typed by the user. Every message names which PR/MR it's about — `[pr-watch] owner/repo#42: <event>` (GitHub) or `[pr-watch] group/project!17: <event>` (GitLab) — since a session can watch more than one at once. If a single poll turns up more than one kind of change at the same time (e.g. a new review landing in the same tick CI turns red), they arrive combined into that one message as a bulleted list instead — `[pr-watch] owner/repo#42, 2 changes:` followed by one `- <event>` line each, not as separate back-to-back messages — so treat every bullet as its own event and work through the list below once per bullet. The event shapes themselves, ref prefix aside:

- `REVIEW <author> <APPROVED|CHANGES_REQUESTED|COMMENTED>` — a new review landed. Never fires for a review authored by the worker's own account (yours, or an agent acting through the same `gh`/`glab` credential) — that's suppressed automatically, always, not something to configure. The same suppression applies to a top-level-comment `COMMENT` from that same account.
- `REVIEW_DISMISSED <author>'s <state> review was dismissed` — a review that was there at the last check is just gone now, with nothing newer replacing it. Usually means the underlying platform auto-cleared it on a push (GitHub's "dismiss stale approvals" branch protection, GitLab's "reset approvals on push" project setting) — e.g. a CHANGES_REQUESTED you were waiting on got wiped by someone else's unrelated push, so whatever you were blocked on may no longer be tracked anywhere visible.
- `COMMENT unresolved threads: <old> -> <new>` — new unresolved discussion threads, **or** a new top-level PR/MR conversation comment (the Conversation tab, not an inline review thread — e.g. a bot's walkthrough summary; GitLab system notes like "assigned to" or "enabled automatic merge" never count). Both are tracked and reported the same way. Suppressed when a `REVIEW` fires in the same tick (e.g. a `COMMENTED` review whose only content is an inline comment, or a review submission that posts its own top-level walkthrough alongside it) — that's the same review's own activity, not independent, so only `REVIEW` shows. A top-level comment authored by the worker's own account is suppressed the same way a self-authored REVIEW is (see below) — a thread-based one isn't, since neither provider exposes a per-thread author to check.
- `CI failure` — the check/pipeline just turned red. This is the only CI transition that pings — a move to `success`/`pending`/`action_required` only updates the dashboard badge silently, no message here. GitHub only: never fires (and the dashboard badge stays out of "failure" too) when the rollup's FAILURE is fully explained away as a force-push cancelling a stale run — every run for that commit terminal, none genuinely failed, at least one cancelled — since a cancelled run says nothing actually broke.
- `CONFLICT has a merge conflict with its target branch` — the PR/MR just went from mergeable to conflicting. Only the appearing transition pings (same one-shot-per-state shape as `CI failure`); it staying conflicted across polls, or clearing again, is silent — the dashboard badge already reflects both of those live.
- `MERGE_QUEUE removed from merge queue` — GitHub only: the PR was in the repo's merge queue and got dequeued without merging. The most common cause is a CI failure in the merge group's temporary check, but the ping alone can't tell you that for certain — it could also be the PR going stale/conflicting, or someone removing it manually.
- `MERGED` — merged; the worker stops polling and marks the registration merged (a permanent badge shows on the session in the plugin's dashboard/row-badge — no action needed on your end). Always arrives alone, never bundled with other events.
- `CLOSED` — closed without merging; same automatic stop, with its own distinct badge. Always arrives alone too.

## What to do with each event

**REVIEW / COMMENT / CI failure / CONFLICT / REVIEW_DISMISSED / MERGE_QUEUE (non-terminal):** the ping itself is only ever a one-line summary — it never carries the actual review/comment text, the failing job's name/log, or a direct link. Before analyzing or suggesting anything, go fetch the real content so you're reacting to what was actually said/broken, not just the summary line:

- **REVIEW**: pull the review body — `gh pr view <url> --json reviews` (GitHub) or `glab api projects/:id/merge_requests/:iid/notes` / `glab mr note list <iid>` (GitLab) — and quote or summarize what the reviewer actually wrote, not just their state. Also check for inline review comments (`gh api repos/{owner}/{repo}/pulls/{number}/comments`) and a top-level walkthrough comment (`gh pr view <url> --json comments`) posted around the same time — a `COMMENT` that would've fired for either is suppressed when it lands in the same tick as this review, so that content only surfaces here.
- **COMMENT**: pull the new content — `gh pr view <url> --json comments` for a new top-level comment, `gh api repos/{owner}/{repo}/pulls/{number}/comments` for a new inline review thread (GitHub); `glab api projects/:id/merge_requests/:iid/discussions` covers both on GitLab — and show what was actually said, not just the count. The message alone doesn't say which kind fired, so check both if unsure.
- **CI failure**: find and pull the failing job's logs/name — `gh pr checks <url>` to find the run, then `gh run view <run-id> --log-failed` (GitHub); `glab api projects/:id/pipelines/:pipeline_id/jobs?scope[]=failed` (GitLab) — don't just repeat "CI failure" back.
- **CONFLICT**: check what the conflict is actually against (`gh pr view <url> --json baseRefName,mergeable` or the GitHub conflicts UI; `glab mr show <iid>` for GitLab) and suggest rebasing/merging the target branch in — don't resolve it yourself unprompted, same rule as everything else here.
- **REVIEW_DISMISSED**: check the PR/MR's current review state (`gh pr view <url> --json reviews,reviewDecision` or `glab mr show <iid>`) to see what's actually outstanding now — if this was clearing feedback you were waiting to act on, that feedback itself hasn't gone away just because the flag tracking it did; mention what got cleared and let the user decide whether it's still worth addressing.
- **MERGE_QUEUE**: check the PR's current state (`gh pr view <url>`) to see whether it needs re-queuing, has picked up a new conflict, or has a specific failing check now visible outside the queue.

Then analyze what came in and suggest possible next actions in chat. Do not act on the feedback automatically (no pushing fixes, no resolving threads) — this is notify-and-suggest only, always let the user decide, unless they explicitly tell you to go ahead and address it. Nothing to re-arm afterward — the watch just keeps running.

**After pushing a fix for CHANGES_REQUESTED feedback, or dismissing a stray COMMENTED review that's no longer relevant** (i.e. once told to go ahead, in the same scope as above — don't do this unprompted either): a stale review doesn't clear itself just because you pushed a fix, so also clear the flag, not just the code:

- **GitHub**: use the `dismiss_review` tool on the same `pr-watch` MCP server — it runs the whole cascade itself (real API dismiss, falling back to re-requesting the reviewer, falling back to a local-only badge clear if neither GitHub action is possible), no more manual `gh api`/`gh pr edit` juggling:

  ```
  mcp__pr-watch__dismiss_review({
    pr_url: "<pr-or-mr-url>",
    session_id: "<resolved value of $AOE_ARTIFACT_DIR>",
    review_url: "<the review's own URL>",
  })
  ```

  Get `review_url` from `gh pr view <url> --json reviews --jq '.reviews[] | select(.state=="CHANGES_REQUESTED" or .state=="COMMENTED") | .html_url'` (or the `review_href` field from a prior `mcp__pr-watch__list` call). A `COMMENTED` review can't be dismissed via GitHub's API at all, so that case always resolves to the local-only fallback — the badge here clears, but the review itself stays visible on GitHub's own PR page.
- **GitLab**: re-request with `glab mr update <iid> --reviewer +<username>` (the leading `+` adds without replacing existing reviewers). GitLab has no direct API here to dismiss a reviewer's requested-changes state the way GitHub does, and `dismiss_review` only supports GitHub (GitLab's polling here never reports a `CHANGES_REQUESTED`/`COMMENTED` review state to begin with) — many GitLab projects auto-reset approvals/reviewer state on push instead (a project setting), so re-requesting is usually the whole job there.

**MERGED / CLOSED:** just report it in chat. The plugin's own row-badge already reflects the outcome permanently, so there's nothing else to do — in particular, don't rename the session.

## Checking or clearing what a session is watching

`list` takes two optional filters, `session_id` and `status` (`watching`/`merged`/`closed`/`stopped`) — omit both to see every registration across every session, or pass `session_id` (the resolved value of `$AOE_ARTIFACT_DIR`, same as above — never the literal variable name) to see just this session's own (including its terminal-status ones, e.g. to find a merged registration whose permanent badge is still showing).

`unregister` takes `pr_urls` (one or more URLs) to stop specific registrations in one call, same `results`-array shape as `register`. Omit `pr_urls` entirely (pass only `session_id`) to stop every registration that session owns in one call — e.g. clearing a leftover merged badge, or clearing everything before a session moves on to unrelated work.

## If the MCP tool isn't available

The `pr-watch` MCP server (`io.cwrau.pr-watch-mcp` plugin, `http://127.0.0.1:8632/mcp` by default) needs to be installed and its worker running, and registered with `claude mcp add --transport http pr-watch http://127.0.0.1:8632/mcp --scope user`. If `mcp__pr-watch__register` isn't available in this session, say so rather than silently skipping the watch — the daily "Pull Requests" cron job still backstops missed merges up to a day late, but live REVIEW/COMMENT/CI/MERGE_QUEUE notifications would be lost for this PR until the tool is available.
