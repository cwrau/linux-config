#!/bin/bash

set -ex -o pipefail
if rg '^#' /etc/udev/rules.d/20-yubikey.rules &> /dev/null
then
  echo Off
  echo $color_bad
else
  echo On
  echo $color_good
fi
