#!/usr/bin/env bash

source "$XDG_CONFIG_HOME/polybar/scripts/parse_colors.sh"

failedUnits="$(
  for context in --user ''; do
    systemctl ${context} list-units --state=failed -o json
  done | jq -ser '.[][] | .unit' | sort | paste -sd,
)"
echo "${failedUnits:+%{F$color_red\}${failedUnits}}"
