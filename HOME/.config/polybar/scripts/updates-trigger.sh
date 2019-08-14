#!/usr/bin/env bash

NOTIFY_ICON=/usr/share/icons/Papirus/32x32/apps/system-software-update.svg
INTERVAL=60
DIR=/tmp/polybar/updates
mkdir -p $DIR

function lock() {
  mkdir $1 &> /dev/null
}

function interval() {
  [[ $(( $(date +%s) % $1 )) == 0 ]]
}

function get_total_updates() {
  if interval $INTERVAL && lock $DIR/LOCK
  then
    checkupdates 2>/dev/null | wc -l > $DIR/count

    rmdir $DIR/LOCK
  fi

  UPDATES=$(cat $DIR/count)
}

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

while true; do
  get_total_updates

  if (( UPDATES > 0 )) && ( [[ $UPDATES != ${OLDUPDATES:-0} ]] || interval 30 )
  then
    polybar-msg hook updates 1 &> /dev/null
    notify-send.sh -t 10000 -r 5141154 -u critical -i $NOTIFY_ICON "$(BAR_ICON) $UPDATES" \
        -o Auto:"i3-sensible-terminal -- sh -c 'yay -Syu --noconfirm --removemake'" \
        -o Manual:"i3-sensible-terminal -- sh -c 'yay -Syu'"
   # choice=$(dunstify -t 10000 -r 5141154 -u critical -A auto,Auto -A manual,Manual -i $NOTIFY_ICON "$(BAR_ICON) $UPDATES")
   # case $choice in
   #   auto) i3-sensible-terminal -- sh -c 'yay -Syu --noconfirm --removemake' ;;
   #   manual) i3-sensible-terminal -- sh -c 'yay -Syu';;
   # esac
  fi

  sleep 1

  if (( UPDATES >= 1 ))
  then
    polybar-msg hook updates 1 &> /dev/null
  else
    polybar-msg hook updates 2 &> /dev/null
  fi
  OLDUPDATES=$UPDATES
done
