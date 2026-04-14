#!/bin/bash

set -e -o pipefail

source "$XDG_CONFIG_HOME/bar/scripts/parse_colors.sh"

function update() {
  if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    if dunstctl is-paused | grep -q false; then
      printf '{"text":"","class":"active"}\n'
    else
      printf '{"text":"","class":"paused"}\n'
    fi
  else
    # shellcheck disable=SC2154
    echo -n "%{A1:/usr/bin/dunstctl set-paused toggle:}%{F$color_green}"
    if dunstctl is-paused | grep -q false; then
      echo -n "%{F-}"
    else
      echo -n "%{F-}"
    fi
    echo '%{A}'
  fi
}

update

dbus-monitor path=/org/freedesktop/Notifications,member=PropertiesChanged --profile | while read -r _; do
  update
done
