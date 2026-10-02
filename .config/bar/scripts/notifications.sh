#!/bin/bash

set -e -o pipefail

source "$XDG_CONFIG_HOME/bar/scripts/parse_colors.sh"

function update() {
  local bell=$'\uf06e' bell_off=$'\uf070'
  if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    if dunstctl is-paused | grep -q false; then
      jq -cn --arg text "<span color=\"$color_green\">$bell</span>" '{text:$text,class:"active"}'
    else
      jq -cn --arg text "<span color=\"$color_yellow\">$bell_off</span>" '{text:$text,class:"paused"}'
    fi
  else
    # shellcheck disable=SC2154
    echo -n "%{A1:/usr/bin/dunstctl set-paused toggle:}%{F$color_green}"
    if dunstctl is-paused | grep -q false; then
      echo -n "$bell%{F-}"
    else
      echo -n "$bell_off%{F-}"
    fi
    echo '%{A}'
  fi
}

update

dbus-monitor path=/org/freedesktop/Notifications,member=PropertiesChanged --profile | while read -r _; do
  update
done
