#!/usr/bin/env bash

type=${1:?Must provide type: bars/radial}

set -exu

while read -r monitor width height x y; do
  upperBarHeight="$(echo "scale=0; $height * 0.025 / 1" | bc)"
  lowerBarHeight="$(echo "scale=0; $height * 0.02 / 1" | bc)"

  radialHeight=$((height - upperBarHeight - lowerBarHeight))
  radialWidth=$width
  radialY=$((y + upperBarHeight))
  radialX=$x

  #lowerBarY=$(( upperBarHeight + radialHeight ))

  if [ "$type" = "bars" ]; then
    geometry="$x $y $width $upperBarHeight"
    #glava -m bars -r "setgeometry $x $lowerBarY $width $lowerBarHeight" &
  elif [ "$type" = "radial" ]; then
    geometry="$radialX $radialY $radialWidth $radialHeight"
  fi
  unitName="glava-$type@$monitor"
  if systemctl --user is-failed --quiet "$unitName"; then
    systemctl --user reset-failed "$unitName"
  elif systemctl --user is-active --quiet "$unitName"; then
    systemctl --user stop "$unitName"
  fi
  systemd-run --user --unit "$unitName" --nice 19 --setenv TRAY --setenv MONITOR --slice "glava-$type.slice" -- glava -m "$type" -r "setgeometry $geometry"
done < <(polybar -m | tr ':x+' '   ' | sed -r 's# +# #g; s# \(.*\)##g')
