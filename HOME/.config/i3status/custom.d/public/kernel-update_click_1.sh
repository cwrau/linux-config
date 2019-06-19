#!/bin/bash

choice=$(echo -e 'Yes\nNo' | dmenu -p "Reboot?")
if [[ ${choice} = "Yes" ]]
then
  i3-msg exec "reboot"
fi
