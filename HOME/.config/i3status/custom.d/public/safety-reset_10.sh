#!/bin/bash

set -ex -o pipefail
if rg '^#' /etc/udev/rules.d/20-yubikey.rules &> /dev/null
then
  sudo sed -i -r 's/^#//g' /etc/udev/rules.d/20-yubikey.rules
  sudo udevadm control --reload-rules
fi
