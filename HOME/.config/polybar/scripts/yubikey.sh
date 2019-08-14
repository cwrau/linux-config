#!/bin/bash

set -e -o pipefail

eval $(cat $HOME/.config/polybar/colors.ini | rg '^[a-z]+ = #[0-9a-fA-F]+$' | tr -d ' ' | sed -r 's#^#color_#g')

function update() {
  if rg '^#' /etc/udev/rules.d/20-yubikey.rules &> /dev/null
  then
    echo "%{F$color_red}%{F-}"
  else
    echo "%{F$color_green}%{F-}"
  fi
}


update
inotifywait -m -r -e modify /etc/udev/rules.d/ 2> /dev/null | while read -r _
do
  update
done
