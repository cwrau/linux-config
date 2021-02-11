#!/usr/bin/env bash

type=${1:?Must provide type: bar/radial}

set -exu

while read -r width height x y
do
  upperBarHeight=26
  lowerBarHeight=18

  radialHeight=$(( height - upperBarHeight - lowerBarHeight))
  radialWidth=$width
  radialY=$(( y + upperBarHeight ))
  radialX=$x

  lowerBarY=$(( upperBarHeight + radialHeight ))

  if [ $type = "bar" ]; then
    glava -m bars -r "setgeometry $x $y $width $upperBarHeight" &
    #glava -m bars -r "setgeometry $x $lowerBarY $width $lowerBarHeight" &
  elif [ $type = "radial" ]; then
    glava -m radial -r "setgeometry $radialX $radialY $radialWidth $radialHeight" &
  fi
  echo
done < <(xrandr --query | grep x | grep + | grep " connected" | sed -r 's# primary##g' | cut -d" " -f3 | tr 'x+' '  ')
