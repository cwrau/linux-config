#!/usr/bin/env bash

set -e -o pipefail

eval $(cat $HOME/.config/polybar/colors.ini | rg '^[a-z]+ = #[0-9a-fA-F]+$' | tr -d ' ' | sed -r 's#^#color_#g')

DIR=/tmp/polybar/orphaned-packages
mkdir -p $DIR

function update() {
  num=$(yay -Qtd 2>/dev/null | wc -l || echo)

  if [[ ${num:-0} -gt 0 ]] && ! pgrep yay
  then
    notify-send.sh -t 10000 -R $DIR/NOTIFICATION_ID -u critical " $num"
    i3-msg exec "i3-sensible-terminal -- sh -c 'yay -Rns --noconfirm \$(yay -Qtdq)'"
  fi
  echo
}

update
inotifywait -m -r -e modify -e create $DIR 2> /dev/null | grep --line-buffered event | while read -r _
do
  sudo rm -f $DIR/event
  update
done
