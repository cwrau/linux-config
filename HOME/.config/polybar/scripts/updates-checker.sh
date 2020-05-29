#!/usr/bin/env bash

set -e -o pipefail

eval $(cat $HOME/.config/polybar/colors.ini | rg '^[a-z]+ = #[0-9a-fA-F]+$' | tr -d ' ' | sed -r 's#^#color_#g')

DIR=/tmp/polybar/updates

function cleanUp() {
  sudo rm -rf $DIR &> /dev/null
}

cleanUp
mkdir -p $DIR

trap cleanUp EXIT

function interval() {
  [[ $(( $(date +%s) % $1 )) == 0 ]]
}

function update() {
  timeout 20 /bin/yay -Syy &>/dev/null &
  wait
  UPDATES=$(yay -Qu --repo 2>/dev/null | wc -l)
  AUR_UPDATES=$(yay -Qu --aur --devel 2> /dev/null | wc -l)
  if (( (UPDATES + AUR_UPDATES) >= 1 )) && ! pgrep -x yay &> /dev/null &> /dev/null
  then
    notify-send.sh -t 10000 -R $DIR/NOTIFICATION_ID -u critical "$(BAR_ICON) $UPDATES | $AUR_UPDATES $(BAR_ICON)"
    i3-msg exec "i3-sensible-terminal -- sh -c 'yay -Syu --devel --noconfirm --removemake --combinedupgrade --batchinstall'"
  fi
  echo
}

while true; do
  current_time=$(date +%s.%N)
  target_time=$(date -d $(date -d 'next hour' --iso-8601=hours) +%s.%N)

  sleep_seconds=$(echo "$target_time - $current_time" | bc)

  sleep $sleep_seconds

  if mkdir $DIR/LOCK &> /dev/null; then
    update
    rmdir $DIR/LOCK &> /dev/null
  fi
done
