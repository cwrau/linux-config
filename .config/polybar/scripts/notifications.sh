#!/bin/bash

set -e -o pipefail

source "$XDG_CONFIG_HOME/polybar/scripts/parse_colors.sh"

function update() {
  if dunstctl is-paused | grep -q false; then
    # shellcheck disable=SC2154
    echo "%{F$color_green}%{F-}"
  else
    # shellcheck disable=SC2154
    echo "%{F$color_green}%{F-}"
  fi
}

while :; do
  update
  sleep 1
done
