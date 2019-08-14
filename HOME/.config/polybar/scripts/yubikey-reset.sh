#!/bin/bash

while :
do
  until [[ $(( $(date +%s) % 10 )) == 0 ]]; do sleep 1; done

  if rg '^#' /etc/udev/rules.d/20-yubikey.rules &> /dev/null
  then
    sudo sed -i -r 's/^#//g' /etc/udev/rules.d/20-yubikey.rules
    sudo udevadm control --reload-rules
  fi
  sleep 1
done