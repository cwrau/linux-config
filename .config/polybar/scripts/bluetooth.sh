#! /usr/bin/env bash

pactl set-source-volume alsa_input.usb-GN_Netcom_A_S_Jabra_LINK_230_000A36EA014A07-00.multichannel-input 100% &> /dev/null
pactl set-card-profile bluez_card.94_DB_56_52_CE_A3 a2dp_sink &> /dev/null
pactl set-card-profile bluez_card.04_5D_4B_98_04_86 a2dp_sink &> /dev/null

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

