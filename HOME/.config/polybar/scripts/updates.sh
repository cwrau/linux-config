#!/usr/bin/env bash

set -e -o pipefail

eval $(cat $HOME/.config/polybar/colors.ini | rg '^[a-z]+ = #[0-9a-fA-F]+$' | tr -d ' ' | sed -r 's#^#color_#g')

DIR=/tmp/polybar/updates
mkdir -p $DIR

function cleanUp() {
  rmdir $DIR/NOTIFICATION_LOCK &> /dev/null
}

trap cleanUp EXIT

function BAR_ICON() {
  if (( UPDATES == 1 ))
  then
    echo ""
  elif (( UPDATES > 1 ))
  then
    echo ""
  else
    echo
  fi
}

function updatePrompt() {
  UPDATES=$(cat $DIR/count || echo 0)

  if (( UPDATES >= 1 ))
  then
    echo "%{F$color_red}$(BAR_ICON) $UPDATES%{F-}"
    if [ $UPDATES != ${LASTUPDATES:-0} ] # && mkdir $DIR/NOTIFICATION_LOCK &> /dev/null
    then
      notify-send.sh -t 10000 -r 5141154 -u critical "$(BAR_ICON) $UPDATES" \
          -o Auto:"i3-msg exec \"i3-sensible-terminal -- sh -c 'yay -Syu --noconfirm --removemake'\"" \
          -o Manual:"i3-msg exec \"i3-sensible-terminal -- sh -c 'yay -Syu'\""
     # choice=$(timeout 10 dunstify -t 10000 -r 5141154 -u critical -A auto,Auto -A manual,Manual "$(BAR_ICON) $UPDATES" || true)
     # case $choice in
     #   auto) i3-msg exec "i3-sensible-terminal -- sh -c 'yay -Syu --noconfirm --removemake'" &> /dev/null;;
     #   manual) i3-msg exec "i3-sensible-terminal -- sh -c 'yay -Syu'" &> /dev/null;;
     # esac
     # rmdir $DIR/NOTIFICATION_LOCK &> /dev/null
    fi
    LASTUPDATES=$UPDATES
  else
    echo
  fi
}

while true
do
  sleep 1
  updatePrompt
done
