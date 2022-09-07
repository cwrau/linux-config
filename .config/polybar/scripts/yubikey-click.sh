#!/bin/bash

set -ex -o pipefail
if rg -v '^#' /etc/udev/rules.d/20-yubikey.rules &> /dev/null; then
  sudo sed -i -r 's/^/#/g' /etc/udev/rules.d/20-yubikey.rules
  sudo udevadm control --reload-rules
  until=$(( 10 - ($(date +%s) % 10) ))
  notify-send -t "$(( (until + 1) * 1000 ))" 'YubiKey Security' -u critical "YubiKey Security turned off, but will be turned on again in $until Seconds"
fi
