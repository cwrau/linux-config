#!/usr/bin/env bash

type=${1:?Must provide type: bars/radial}

set -exu

function round() {
  printf "%.0f" "$1"
}

function getHeight() {
  local config="$1"
  round "$(echo "scale=3; $height * ($(grep -oP '^height\s*=\s*(\K[0-9.]+)' "$XDG_CONFIG_HOME/polybar/config-$config.ini") / 100) / 1" | bc)"
}

while read -r monitor width height x y; do
  upperBarHeight=$(getHeight top)
  lowerBarHeight=$(getHeight bottom)

  if [ "$type" = "bars" ]; then
    geometry="$x $y $width $upperBarHeight"
    #lowerGeometry="x $(( height - lowerBarHeight )) $width $lowerBarHeight"
  elif [ "$type" = "radial" ]; then
    radius=$(round "$(echo "$(( (width < height ? width : height) - upperBarHeight - lowerBarHeight )) * 1" | bc)")
    radialY=$(( y + ((height / 2) - (radius / 2)) ))
    radialX=$(( x + ((width / 2) - (radius / 2)) ))

    geometry="$radialX $radialY $radius $radius"
  fi
  unitName="glava-$type@$monitor"
  if systemctl --user is-failed --quiet "$unitName"; then
    systemctl --user reset-failed "$unitName"
  elif systemctl --user is-active --quiet "$unitName"; then
    systemctl --user stop "$unitName"
  fi
  systemd-run --user --unit "$unitName" --collect --nice 19 --setenv TRAY --setenv MONITOR --slice "glava-$type.slice" -- glava -m "$type" -r "setgeometry $geometry"
done < <(polybar -m | tr ':x+' '   ' | sed -r 's# +# #g; s# \(.*\)##g')
