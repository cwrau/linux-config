#!/usr/bin/env bash

NOTIFY_ICON=/usr/share/icons/Papirus/32x32/apps/system-software-update.svg
INTERVAL=60
DIR=/tmp/polybar/orphaned-packages
mkdir -p $DIR

function lock() {
  mkdir $1 &> /dev/null
}

function interval() {
  [[ $(( $(date +%s) % $1 )) == 0 ]]
}

function get_orphaned_packages() {
  if interval $INTERVAL && lock $DIR/LOCK
  then
    yay -Qtd 2>/dev/null | wc -l > $DIR/count

    rmdir $DIR/LOCK
  fi

  ORPHANED_PACKAGES=$(cat $DIR/count)
}

function BAR_ICON() {
  if (( ORPHANED_PACKAGES == 1 ))
  then
    echo ""
  elif (( ORPHANED_PACKAGES > 1 ))
  then
    echo ""
  else
    echo
  fi
}

while true; do
  get_orphaned_packages

  if (( ORPHANED_PACKAGES > 0 )) && ( [[ $ORPHANED_PACKAGES != ${OLDORPHANED_PACKAGES:-0} ]] || interval 30 )
  then
    polybar-msg hook orphaned-packages 1
    notify-send.sh -t 10000 -r 21181154 -u critical -i $NOTIFY_ICON "$(BAR_ICON) $ORPHANED_PACKAGES" \
        -o Auto:"i3-msg exec \"i3-sensible-terminal -- sh -c 'yay -Rns --noconfirm \$(yay -Qtdq)'\"" \
        -o Manual:"i3-msg exec \"i3-sensible-terminal -- sh -c 'yay -Rns \$(yay -Qtdq)'\""
   # choice=$(dunstify -t 10000 -r 21181154 -u critical -A auto,Auto -A manual,Manual -i $NOTIFY_ICON "$(BAR_ICON) $ORPHANED_PACKAGES")
   # case $choice in
   #   auto) i3-msg exec "i3-sensible-terminal -- sh -c 'yay -Rns --noconfirm \$(yay -Qtdq)'" ;;
   #   manual) i3-msg exec "i3-sensible-terminal -- sh -c 'yay -Rns \$(yay -Qtdq)'" ;;
   # esac
  fi

  sleep 1

  if (( ORPHANED_PACKAGES >= 1 ))
  then
    polybar-msg hook orphaned-packages 1
  else
    polybar-msg hook orphaned-packages 2
  fi
  OLDORPHANED_PACKAGES=$ORPHANED_PACKAGES
done &> /dev/null
