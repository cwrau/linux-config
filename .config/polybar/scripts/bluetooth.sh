#! /usr/bin/env bash

if bluetoothctl show | grep -q "Powered: yes"; then
  if bluetoothctl info | grep -q 'Device'; then
    echo -n "%{F#2193ff} "
    for mac in $(bluetoothctl paired-devices | awk '{print $2}'); do
      bluetoothctl info $mac | grep -B 99 'Connected: yes' | grep Alias | cut -d ' ' -f 2-
    done | sort | paste -sd "," - | sed 's#,#, #g'
  else
    echo ""
  fi
else
  echo "%{F#66ffffff}"
fi

