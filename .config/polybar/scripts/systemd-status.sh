#!/usr/bin/env bash

source "$XDG_CONFIG_HOME/polybar/scripts/parse_colors.sh"

function update() {
  failedUnits="$(
    for context in --user --system; do
      systemctl ${context} list-units --state=failed -o json
    done | jq -ser '.[][] | .unit' | sort | paste -sd,
  )"
  echo "${failedUnits:+%{F$color_red\}${failedUnits}}"
}

#(
#  dbus-monitor member=PropertiesChanged --system --profile &
#  dbus-monitor member=PropertiesChanged --profile
#) | while read -r _; do
#  update
#done
while true; do
  update
  sleep 2
done
