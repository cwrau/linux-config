#!/bin/bash

set -ex -o pipefail

loadedKernel="$(uname -r)"
if [ -f /boot/vmlinuz-linux-zen ]
then
  installedKernel="$(file /boot/vmlinuz-linux-zen | sed -r 's#^.+version ([^ ]+) .+$#\1#g')"
else
  installedKernel="$(file /boot/vmlinuz-linux | sed -r 's#^.+version ([^ ]+) .+$#\1#g')"
fi

if [[ "$loadedKernel" != "$installedKernel" ]]
then
    echo "Kernel Update"
    echo "$color_bad"
fi
