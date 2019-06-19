#!/bin/bash

set -ex -o pipefail

loadedKernel="$(uname -r)"
installedKernel="$(file /boot/vmlinuz-linux-zen | sed -r 's#^.+version ([^ ]+) .+$#\1#g')"

if [[ "$loadedKernel" != "$installedKernel" ]]
then
    echo "Kernel Update"
    echo "$color_bad"
fi
