#!/usr/bin/env bash

type=${1:?Must provide type: bar/radial}

set -exu

while read -r width height x y
do
  barHeight=26
  radialHeight=$(( height * 2 / 3 ))
  radialHeight=$(( height - barHeight - 18))
  radialWidth=$width
  radialY=$(( y + ( ((height + barHeight) / 2 ) - ((radialHeight + 18) / 2 ) ) ))
  radialX=$(( x + ( (width / 2 ) - (radialWidth / 2 ) ) ))

  if [ $type = "bar" ]; then
    glava -r "setgeometry $x $y $width $barHeight" &
  elif [ $type = "radial" ]; then
    glava -m radial -r "setgeometry $radialX $radialY $radialWidth $radialHeight" &
  fi
  echo
done < <(xrandr --query | grep " connected" | sed -r 's# primary##g' | cut -d" " -f3 | tr 'x+' '  ')
