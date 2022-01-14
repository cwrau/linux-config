#!/usr/bin/env bash

type=${1:?Must provide type: bar/radial}

set -exu

while read -r monitor width height x y
do
  upperBarHeight=26
  lowerBarHeight=18

  radialHeight=$(( height - upperBarHeight - lowerBarHeight))
  radialWidth=$width
  radialY=$(( y + upperBarHeight ))
  radialX=$x

  lowerBarY=$(( upperBarHeight + radialHeight ))

  if [ $type = "bar" ]; then
    systemd-run --user --unit glava-$type@$monitor --nice 19 --setenv TRAY --setenv MONITOR --slice glava-$type.slice -- glava -m bars -r "setgeometry $x $y $width $upperBarHeight" &
    #glava -m bars -r "setgeometry $x $lowerBarY $width $lowerBarHeight" &
  elif [ $type = "radial" ]; then
    systemd-run --user --unit glava-$type@$monitor --nice 19 --setenv TRAY --setenv MONITOR --slice glava-$type.slice -- glava -m radial -r "setgeometry $radialX $radialY $radialWidth $radialHeight" &
  fi
  echo
done < <(xrandr --query | grep x | grep + | grep " connected" | sed -r 's# primary##g' | cut -d" " -f1,3 | tr 'x+' '  ')
