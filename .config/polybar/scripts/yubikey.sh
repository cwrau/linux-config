#!/bin/bash

set -e -o pipefail

# shellcheck source=/dev/null
source "$XDG_CONFIG_HOME/polybar/scripts/parse_colors.sh"

function update() {
  if rg '^#' /etc/udev/rules.d/20-yubikey.rules &> /dev/null; then
    # shellcheck disable=SC2154
    echo "%{F$color_red}%{F-}"
  else
    # shellcheck disable=SC2154
    echo "%{F$color_green}%{F-}"
  fi
}


update
inotifywait -m -r -e modify /etc/udev/rules.d/ 2> /dev/null | while read -r _; do
  update
done
