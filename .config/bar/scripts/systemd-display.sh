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

  if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    local class
    case "$state" in
      active) class="active" ;;
      inactive) class="inactive" ;;
      failed) class="failed" ;;
      *) class="inactive" ;;
    esac
    printf '{"text":"%s","tooltip":"%s: %s","class":"%s"}\n' "$display" "$unit" "$state" "$class"
  else
    local output="%{A1:$XDG_CONFIG_HOME/bar/scripts/systemd-click.sh $clickUnit:}"
    local print=false
    case "$state" in
      active)
        print=true
        output+="%{F$color_green}${display}%{F-}"
        ;;
      inactive)
        print=true
        output+="%{F$color_orange}${display}%{F-}"
        ;;
      failed)
        print=true
        output+="%{F$color_red}${display}%{F-}"
        ;;
    esac
    output+="%{A}"
    if $print; then
      echo "$output"
    fi
  fi
}

update

dbus-monitor "path=$dbusUnitName",member=PropertiesChanged --profile | while read -r _; do
  update
done
