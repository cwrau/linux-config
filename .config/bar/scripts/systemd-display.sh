#!/bin/bash

set -e
set -o pipefail

source "$XDG_CONFIG_HOME/bar/scripts/parse_colors.sh"

unit=${1}
display=${2}
clickUnit=${3:-$unit}
dbusUnitName="$(dbus-send --type=method_call --dest=org.freedesktop.systemd1 --print-reply=literal /org/freedesktop/systemd1 org.freedesktop.systemd1.Manager.LoadUnit "string:$unit" | awk '{print $1}')"

function update() {
  local state
  state=$(systemctl --user is-active "${unit}" 2>/dev/null || true)
  local color
  case "$state" in
    active) color="$color_green" ;;
    inactive) color="$color_orange" ;;
    failed) color="$color_red" ;;
    *) color="$color_orange" ;;
  esac

  if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    jq -cn --arg text "<span color=\"$color\">$display</span>" --arg tooltip "$unit: $state" '{text:$text,tooltip:$tooltip}'
  else
    case "$state" in
      active | inactive | failed)
        echo "%{A1:$XDG_CONFIG_HOME/bar/scripts/systemd-click.sh $clickUnit:}%{F$color}${display}%{F-}%{A}"
        ;;
    esac
  fi
}

update

dbus-monitor "path=$dbusUnitName",member=PropertiesChanged --profile | while read -r _; do
  update
done
