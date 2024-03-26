#!/usr/bin/env bash

set -e -o pipefail

source "$XDG_CONFIG_HOME/polybar/scripts/parse_colors.sh"

cd "$HOME" &>/dev/null

function update() {
  untracked=$(git ls-files -o --exclude-standard | wc -l)
  unadded=$(git diff --name-only | wc -l)
  uncommitted=$(git diff --cached --name-only | wc -l)
  unpushed=$(git log --branches --not --remotes --format=%H | wc -l)

  if [[ ${untracked:-0} -gt 0 ]] || [[ ${unadded:-0} -gt 0 ]] || [[ ${uncommitted:-0} -gt 0 ]] || [[ ${unpushed:-0} -gt 0 ]]; then
    echo -n "%{F$color_red}"
  fi

  if [[ ${untracked:-0} -gt 0 ]]; then
    echo -n "$untracked file$([[ ${untracked} -gt 1 ]] && echo s) untracked"
  fi

  if [[ ${unadded:-0} -gt 0 ]]; then
    [[ ${untracked:-0} -gt 0 ]] && echo -n ', '
    echo -n "$unadded file$([[ ${unadded} -gt 1 ]] && echo s) changed"
  fi

  if [[ ${uncommitted:-0} -gt 0 ]]; then
    [[ ${untracked:-0} -gt 0 ]] || [[ ${unadded:-0} -gt 0 ]] && echo -n ', '
    echo -n "$uncommitted change$([[ ${uncommitted} -gt 1 ]] && echo s) not committed"
  fi

  if [[ ${unpushed:-0} -gt 0 ]]; then
    [[ ${untracked:-0} -gt 0 ]] || [[ ${uncommitted:-0} -gt 0 ]] || [[ ${unadded:-0} -gt 0 ]] && echo -n ', '
    echo -n "$unpushed commit$([[ ${unpushed} -gt 1 ]] && echo s) not pushed"
  fi

  if [[ ${untracked:-0} -gt 0 ]] || [[ ${unadded:-0} -gt 0 ]] || [[ ${uncommitted:-0} -gt 0 ]] || [[ ${unpushed:-0} -gt 0 ]]; then
    echo "%{F-}"
  fi

  if [[ ${untracked:-0} -eq 0 ]] && [[ ${unadded:-0} -eq 0 ]] && [[ ${uncommitted:-0} -eq 0 ]] && [[ ${unpushed:-0} -eq 0 ]]; then
    echo ""
  fi
}

update
while :; do
  current_time=$(date +%s.%N)
  next_time=$(date -d "+ 10 seconds" +%s.%N)
  target_time=$(date -d @"$(echo "$next_time - ($next_time % 10 )" | bc)" +%s.%N)

  sleep_seconds=$(echo "$target_time - $current_time" | bc)

  sleep "$sleep_seconds"

  update
done
