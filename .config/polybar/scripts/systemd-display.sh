#!/bin/bash

set -e
set -o pipefail

source "$XDG_CONFIG_HOME/polybar/scripts/parse_colors.sh"

name=${1}
text=${2}
dbusUnitName="$(dbus-send --type=method_call --dest=org.freedesktop.systemd1 --print-reply=literal /org/freedesktop/systemd1 org.freedesktop.systemd1.Manager.LoadUnit "string:$name" | awk '{print $1}')"

function update() {
  case $(systemctl --user is-active "${name}") in
    active)
      echo "%{F$color_green}${text}%{F-}"
      ;;

    inactive)
      echo "%{F$color_orange}${text}%{F-}"
      ;;

    failed)
      echo "%{F$color_red}${text}%{F-}"
      ;;
  esac
}

update

dbus-monitor "path=$dbusUnitName",member=PropertiesChanged --profile | while read -r _; do
  update
done
