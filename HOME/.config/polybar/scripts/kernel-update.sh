#!/usr/bin/env bash

set -e -o pipefail

eval $(cat $HOME/.config/polybar/colors.ini | rg '^[a-z]+ = #[0-9a-fA-F]+$' | tr -d ' ' | sed -r 's#^#color_#g')

DIR=/tmp/polybar/kernel-update
mkdir -p $DIR

function update() {
  loadedKernel="$(uname -r)"
  if [ -f /boot/vmlinuz-linux-zen ]
  then
    installedKernel="$(file /boot/vmlinuz-linux-zen | sed -r 's#^.+version ([^ ]+) .+$#\1#g')"
  else
    installedKernel="$(file /boot/vmlinuz-linux | sed -r 's#^.+version ([^ ]+) .+$#\1#g')"
  fi

  if [[ "$loadedKernel" != "$installedKernel" ]]
  then
    echo "%{F$color_red}Kernel Update%{F-}"
   # if mkdir $DIR/LOCK &> /dev/null
   # then
      notify-send.sh -t 10000 -r 051151 -u critical "Kernel Update, reboot?" \
          -o Yes:"systemctl reboot" \
          -o No:echo
     # choice=$(timeout 10 dunstify -t 10000 -r 051151 -u critical -A yes,Yes -A no,No "Kernel Update, reboot?" || true)
     # case $choice in
     #   yes) reboot ;;
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