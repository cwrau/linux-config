#!/bin/bash
set -uo pipefail

# Chromium (and possibly others) never restore their own OS nice value when a
# backgrounded window regains focus - known Chromium-on-Linux limitation, not
# something under our control. Watch the actual X11 active-window property
# for real change events (no polling, no i3 IPC burst noise - X11 only fires
# this once per genuine focus change) and renice the newly-focused window's
# process tree back down to whatever its owning systemd unit says it should.

lastWindowId=""

xprop -root -spy _NET_ACTIVE_WINDOW 2>/dev/null | while IFS= read -r line; do
  windowId="$(awk -F'# ' '{print $2}' <<<"$line")"
  [[ -n "$windowId" ]] || continue
  [[ "$windowId" == "$lastWindowId" ]] && continue
  lastWindowId="$windowId"

  pid="$(xprop -id "$windowId" _NET_WM_PID 2>/dev/null | awk -F'= ' '{print $2}')"
  [[ -n "${pid:-}" && "$pid" != 0 ]] || continue

  unit="$(basename "$(awk -F: '{print $NF}' "/proc/$pid/cgroup" 2>/dev/null)")"
  [[ "$unit" == *.service ]] || continue

  nice="$(systemctl --user show "$unit" -p Nice --value 2>/dev/null)"
  [[ -n "$nice" && "$nice" != 0 ]] || continue

  # walk the whole descendant tree in one `ps` call instead of forking
  # pgrep/renice per node - that doesn't scale with chromium's process count
  mapfile -t pids < <(
    ps -eo pid,ppid --no-headers | awk -v root="$pid" '
      { children[$2] = children[$2] " " $1 }
      function walk(p,   kids, n, arr, i) {
        print p
        kids = children[p]
        n = split(kids, arr, " ")
        for (i = 1; i <= n; i++) if (arr[i] != "") walk(arr[i])
      }
      END { walk(root) }
    '
  )

  # nice is per-thread in Linux, not per-process - expand to every task (LWP)
  # of every pid, then renice them all in a single call
  tids=()
  for p in "${pids[@]}"; do
    for t in "/proc/$p/task/"*; do
      [[ -d "$t" ]] && tids+=("${t##*/}")
    done
  done
  if [[ ${#tids[@]} -gt 0 ]]; then
    renice -n "$nice" -p "${tids[@]}" &>/dev/null || true
  fi
done
