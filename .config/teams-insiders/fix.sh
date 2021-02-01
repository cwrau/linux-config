#!/usr/bin/env bash

set -exu

function update() {
  set +e
  pactl move-source-output $(pacmd list-source-outputs | rg -S -B 15 'client:.+skype' | rg index | sed -r 's#\s+index: ##g') alsa_input.usb-GN_Netcom_A_S_Jabra_LINK_230_000A36EA014A07-00.multichannel-input &> /dev/null
  pactl set-source-volume alsa_input.usb-GN_Netcom_A_S_Jabra_LINK_230_000A36EA014A07-00.multichannel-input 150% &> /dev/null
  pactl set-card-profile bluez_card.94_DB_56_52_CE_A3 a2dp_sink &> /dev/null
  set -e
}

update

LANG=C pactl subscribe | grep "Event 'change' on server" --line-buffered | while read p
do
  update
done
