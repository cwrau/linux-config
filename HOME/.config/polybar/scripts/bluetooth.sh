#! /usr/bin/env bash

if bluetoothctl show | grep -q "Powered: yes"; then
  if bluetoothctl info | grep -q 'Device'; then
    echo "%{F#2193ff} $(bluetoothctl info | grep Alias | sed -r 's#^\s*Alias: (.+)$#\1#g')"
  else
    echo ""
  fi
else
  echo "%{F#66ffffff}"
fi
