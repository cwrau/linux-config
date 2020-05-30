#!/usr/bin/env sh

set -exu

for MONITOR in $(polybar -m | cut -d: -f1)
do
  # Launch bar1 and bar2
  if polybar -m | grep $MONITOR | grep primary &>/dev/null
  then
    TRAY=right
  else
    TRAY=none
  fi
  TRAY=$TRAY MONITOR=$MONITOR polybar -r top -c ~/.config/polybar/config-top.ini &
  #MONITOR=$MONITOR polybar -r top-transparent -c ~/.config/polybar/config-top.ini &
  MONITOR=$MONITOR polybar -r bottom -c ~/.config/polybar/config-bottom.ini &
done
