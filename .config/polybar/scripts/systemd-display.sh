#!/bin/bash

set -e
set -o pipefail

source "$XDG_CONFIG_HOME/polybar/scripts/parse_colors.sh"

unit=${1}
display=${2}
clickUnit=${3:-$unit}
dbusUnitName="$(dbus-send --type=method_call --dest=org.freedesktop.systemd1 --print-reply=literal /org/freedesktop/systemd1 org.freedesktop.systemd1.Manager.LoadUnit "string:$unit" | awk '{print $1}')"

function update() {
  local output="%{A1:$XDG_CONFIG_HOME/polybar/scripts/systemd-click.sh $clickUnit:}"
  local print=false
  case $(systemctl --user is-active "${unit}") in
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
}

update

dbus-monitor "path=$dbusUnitName",member=PropertiesChanged --profile | while read -r _; do
  update
done
