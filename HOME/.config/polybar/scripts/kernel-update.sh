#!/usr/bin/env bash

set -e -o pipefail

eval $(cat $HOME/.config/polybar/colors.ini | rg '^[a-z]+ = #[0-9a-fA-F]+$' | tr -d ' ' | sed -r 's#^#color_#g')

function update() {
  loadedKernel="$(uname -r)"
  installedKernel="$(file /boot/vmlinuz-linux | sed -r 's#^.+version ([^ ]+) .+$#\1#g')"

  if [[ "$loadedKernel" != "$installedKernel" ]]
  then
    echo "%{F$color_red}Kernel Update%{F-}"
  else
    echo
  fi
}

while :; do
  current_time=$(date +%s.%N)
  next_time=$(date -d "+ 10 seconds" +%s.%N)
  target_time=$(date -d @$( echo "$next_time - ($next_time % 10 )" | bc) +%s.%N)

  sleep_seconds=$(echo "$target_time - $current_time" | bc)

  sleep $sleep_seconds
  update
done