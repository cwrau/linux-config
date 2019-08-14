#!/usr/bin/env bash

set -exu

while pgrep -u $UID -x glava >/dev/null
do
  killall -q glava
  sleep 1
done

while read -r width height x y
do
  # radialHeight=$height
  # radialWidth=$width
  # radialY=$(( $y + ( ($height / 2 ) - ($radialHeight / 2 ) ) ))
  # radialX=$(( $x + ( ($width / 2 ) - ($radialWidth / 2 ) ) ))
  # glava -m radial -r "setgeometry $radialX $radialY $radialWidth $radialHeight" &
  glava -r "setgeometry $x $y $width 30" &
done < <(xrandr --query | grep " connected" | sed -r 's# primary##g' | cut -d" " -f3 | tr 'x+' '  ')
