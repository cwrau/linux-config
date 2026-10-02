#!/usr/bin/env bash

source "$XDG_CONFIG_HOME/bar/scripts/parse_colors.sh"

function update() {
  failedUnits="$(
    for context in --user --system; do
      systemctl ${context} list-units --state=failed -o json
    done | jq -ser '.[][] | .unit' | sort | paste -sd,
  )"

  if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    if [[ -n "$failedUnits" ]]; then
      jq -cn --arg text "<span color=\"$color_red\">$failedUnits</span>" --arg tooltip "Failed units:\n${failedUnits//,/\\n}" '{text:$text,tooltip:$tooltip}'
    fi
  else
    echo "${failedUnits:+%{F$color_red\}${failedUnits}}"
  fi
}

while true; do
  update
  sleep 2
done
