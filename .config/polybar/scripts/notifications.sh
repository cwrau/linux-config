#!/bin/bash

set -e -o pipefail

source "$XDG_CONFIG_HOME/polybar/scripts/parse_colors.sh"

function update() {
  # shellcheck disable=SC2154
  echo -n "%{F$color_green}"
  if dunstctl is-paused | grep -q false; then
    echo "%{F-}"
  else
    echo "%{F-}"
  fi
}

while :; do
  update
  sleep 1
done
