@memory/MEMORY.md
^- read these recursively

## Hard Rules

- Communication style: caveman mode, ultra intensity, always, aside from german sessions — from the first reply of every session, not just after the SessionStart hook fires. Drop articles/filler/pleasantries/hedging, use fragments and short synonyms. Exception: code, commit messages, and security-sensitive content stay in normal prose. User says "normal" or "stop caveman" to deactivate for the rest of the session.
- Responses must be self-contained — never say "see above" / "scroll up" / "as shown earlier". If a draft or finding needs reviewing again, re-state it in full in the current response instead of pointing back at an earlier one.
- Permissions: always add to `~/.claude/settings.json`. Never touch `.claude/settings.json` or `.claude/settings.local.json` in any project
  directory. If a settings/hook change can't take effect in this session because it was cached at startup, spawn a fresh `claude -p` child instance to run the blocked action — it loads the updated config.

- Memory MCP (`mcp__memory__*`, mcp-memory-service at 127.0.0.1:8765) vs `MEMORY.md` files — split by purpose:
  - MCP = durable facts shared across sessions/agents (project context, decisions, gotchas, findings). `memory_search` for the current project/topic at session start before non-trivial work; `memory_store` when the user states a durable preference/decision/gotcha or something non-obvious is learned. Tags go in `metadata.tags` (project name + type), never top-level.
  - `MEMORY.md` files = behavior/feedback rules that must load every session regardless of search. Don't move those into the MCP.
  - If `mcp__memory__*` tools are missing, say so; don't silently skip.
- When working cross-repo, the projects often already exist in either $HOME/projects (one level depth) or in $HOME/work (multi level (project path in gitlab) plus some single level projects). Always `fd -td -i <repo-name> ~/work ~/projects` first — never clone before checking.

- Never stash, revert, or switch to main to investigate an error. Fix it where it is, always.
- JSON processing in shell: always use `jq`. Never `python3 -c 'import json...'` or similar.
  - Never compact print/write json; I want nicely formatted pretty-printed json
- File finding: always `fd`, never `find`. Grepping: always `rg`, never `grep`.
- YAML processing in shell: always use `yq` (jq wrapper, kislyuk/yq). Never the Go `yq` (mikefarah/yq).
  - Never mix json syntax into yaml; always pure yaml
  - Don't unnecessarily quote yaml keys or values
- Tool running: if you need to run a tool that isn't installed, run it with nix-shell. If a needed tool is missing locally mid-debug, run it yourself via nix-shell — don't hand the user a command to try instead.
- If a command's full output is long but you only need part of it right now (e.g. piping through `head`/`tail`/`grep` for a quick look), still `tee` the full output to a temp file. If you need more of it later, read the file instead of re-running the command.
- Never create system config/executables/... directly, if you want to do system wide settings, go through the Arch package $HOME/config
- Never install/upgrade packages or tools without asking first, even dev tools and transitive installs (e.g. `npx x install`). Prefer the distro package manager over curling tarballs/binaries.
- Never hand-edit a generated file (e.g. a `README.md` built from `README.md.gotmpl`). Check for a source template first.
- Never commit brainstorming/design spec docs to a repo — write them to disk for reference, leave untracked.
- Git/PR work often happens in a worktree. Worktrees live in a dedicated `<project>-worktrees/` folder sibling to the project (e.g. `~/work/helm-charts-worktrees/<name>`, `~/work/k8s/t8s-engine-worktrees/<name>`) — check there and reuse an existing worktree via `git switch` before creating a new one; don't stack a redundant worktree when already inside one. If you are launched in the main repo, don't just switch to a worktree if not needed or prompted to.
  - if you're in the main repo, just stay there.
- Git identity/signing key are directory-scoped (`includeIf` gitdir rules only cover `$HOME/work` and `$HOME/projects`). Never clone or scratch-checkout a repo outside those trees (e.g. into `/tmp`) — it silently signs commits with the wrong key/identity. Clone into the correct `~/work/<gitlab-path>` location or use a worktree of an existing checkout instead.
- If, and only if!, a repo has both an `origin` (upstream) and a `fork` (personal) remote, always push feature branches to `fork` and open the PR from there against `origin`'s default branch — never push feature branches to `origin` directly. Branch off the local default branch (e.g. `main`), never off the remote-tracking ref (e.g. `origin/main`) — branching directly off a remote-tracking ref triggers `branch.autoSetupMerge` and configures the new branch to track it, so with `push.default=upstream` a later bare `git push fork <branch>` resolves to `fork`'s default branch instead of a same-named branch there. Fast-forward local `main` from `origin/main` first if it's stale, then branch from local `main`. After this, check if local `main` contained commits not on the upstream (e.g. `origin/main`) and drop those form the branch (NOT local `main`)
- When I tell you to @triage a PR, I mean to invoke the @pr-review-triage agent
- The `pr-watch` plugin auto-discovers whatever PR/MR is open on a session's current git branch and starts watching it on its own within one scheduler tick — no action needed after a normal `gh pr create`/`glab mr create`. Only invoke the `pr-watch` skill explicitly when you need something auto-discovery can't give you: instant coverage instead of up-to-a-tick-later, an `events` filter from the start, or watching a PR/MR that isn't the one on the current session's own branch (e.g. reviewing someone else's, or after the raw-API workaround if that checkout ever ends up on a different branch). On review/CI activity, analyze and suggest next actions — never act on feedback automatically. A merge/close just leaves a permanent badge on the session row; it does not rename the session.
- Before creating any PR/MR or issue, check the repo for a template (`.github/PULL_REQUEST_TEMPLATE.md`, `.github/PULL_REQUEST_TEMPLATE/*.md`, `docs/pull_request_template.md`, same paths for `ISSUE_TEMPLATE`, or GitLab's `.gitlab/merge_request_templates/*.md` / `.gitlab/issue_templates/*.md`) and fill it out instead of writing a freeform description — never skip/ignore an existing template.
- My commit style is mostly having a single commit in a PR; so ammend the existing commit. If there are already multiple commits, check if the new change can be logically amended into one of them, otherwise you may create a new one.
- Commit messages: one-liner conventional format only (`feat: X`, `fix: Y`). At most one or two sentence body, but only if useful.
  - No Co-Authored-By or similar.
    - Exceptions are the <https://github.com/SovereignCloudStack> repos, they require Co-Authored-By.
  - Breaking change: use the `!` suffix on the type (`feat!:`) only. Never a "BREAKING CHANGE:" footer/body text.
- `gh` CLI: always run with `dangerouslyDisableSandbox: true` (needs network access).
- For gitlab.teuto.net (or any internal GitLab) diagnostics, prefer the already-authenticated `glab` CLI over asking for or testing raw personal access tokens.
- Branch switching: use `git switch` (or `git switch -c`). Reserve `git checkout` for file restoration only.
- Before reverting or overwriting any file (`git checkout --`/`restore`, `cp`, `Write`, etc.), read its full current diff/content first — never assume a "modified" file only contains changes you're aware of. `git status` only says a file changed, not what's in it; blind revert can destroy unrelated uncommitted work. For a targeted content change (removing/changing specific lines), prefer the Edit tool over a git revert/checkout — git operations are for committed history, not for editing working-directory content.
- Never delete a data file (`.xlsx`, `.csv`, `.json`, `.db`, sqlite, etc.) or anything holding real user/generated data without explicit permission first. Prefer migrating/extending it in place (e.g. add a column, don't recreate the file) over delete-and-recreate, and back it up first if restructuring.
- Branch names should always be useful, at least for pushing; $type/$scope/$short-description. $type are conventional commit types.
  If there really isn't a scope, then you can skip that. In multi repos this should be the component, in single repos this could be
  backen/frontend/... .

- `task` runner: binary is `go-task`, not `task`. Always `go-task <target>`.
- When having a task/build runner/system, never circumvent it by calling the steps directly. For example don't call golangci-lint by hand if there is a task for that.
- "Research this/about X" (casual phrasing) → do inline research (WebSearch/WebFetch/Agent), NOT the deep-research workflow. Only launch the deep-research workflow when explicitly told, e.g. "launch a research workflow to research X".
- When I talk about doing anything with home assistant, I always mean using the mcp
- Never touch `automation.ha_notification` — not routing, not notifier variable, not icon, not target, not disabled blocks. Forbidden explicitly, twice.
- Never ignore "pre-existing" issues. Code is suppose to be good, not "at least not worse", and should always improve.

- If a website blocks you, you should use the playwright agent to access it instead.
- If the target exposes a reachable REST API, prefer curl/direct API calls over browser automation (playwright).
- Never attempt an unattended browser-driven login/credential flow (OIDC, MFA, SSO, etc.) via simulated input (xdotool, screenshots, synthetic keystrokes). Ask first, every time — a prior attempt froze the desktop session and forced a reboot.
