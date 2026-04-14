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
      printf '{"text":"%s","tooltip":"Failed units:\\n%s","class":"degraded"}\n' "$failedUnits" "${failedUnits//,/\\n}"
    else
      printf '{"text":"","tooltip":"All units healthy","class":"ok"}\n'
    fi
  else
    echo "${failedUnits:+%{F$color_red\}${failedUnits}}"
  fi
}

while true; do
  update
  sleep 2
done
