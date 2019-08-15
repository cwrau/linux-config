#!/usr/bin/env bash

set -e -o pipefail

eval $(cat $HOME/.config/polybar/colors.ini | rg '^[a-z]+ = #[0-9a-fA-F]+$' | tr -d ' ' | sed -r 's#^#color_#g')

DIR=/tmp/polybar/orphaned-packages
mkdir -p $DIR

function update() {
  num=$(yay -Qtd 2>/dev/null | wc -l || echo)

  if [[ ${num:-0} -gt 0 ]]
  then
    echo "%{F$color_red} $num%{F-}"
   # if mkdir $DIR/LOCK &> /dev/null
   # then
      notify-send.sh -t 10000 -r 21181154 -u critical " $num" \
          -o Auto:"i3-msg exec \"i3-sensible-terminal -- sh -c 'yay -Rns --noconfirm \\\\\$(yay -Qtdq)'\"" \
          -o Manual:"i3-msg exec \"i3-sensible-terminal -- sh -c 'yay -Rns \\\\\$(yay -Qtdq)'\""
     # choice=$(timeout 10 dunstify -t 10000 -r 21181154 -u critical -A auto,Auto -A manual,Manual " $num" || true)
     # case $choice in
     #   auto) i3-msg exec "i3-sensible-terminal -- sh -c 'yay -Rns --noconfirm \$(yay -Qtdq)'" &> /dev/null ;;
     #   manual) i3-msg exec "i3-sensible-terminal -- sh -c 'yay -Rns \$(yay -Qtdq)'" &> /dev/null ;;
     # esac
     # rmdir $DIR/LOCK &> /dev/null
   # fi
  else
    echo
  fi
}

update
inotifywait -m -r -e modify -e create $DIR 2> /dev/null | while read -r _
do
  sudo rm -f $DIR/event
  update
done
