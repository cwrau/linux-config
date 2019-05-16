#!/bin/bash

choice=$(echo -e 'Yes\nManual\nNo' | dmenu -p "Update packages?")
if [[ ${choice} = "Yes" ]]
then
  i3-msg exec "gnome-terminal -- sh -c 'yay -Syu --noconfirm --removemake'" &> /dev/null
elif [[ ${choice} = "Manual" ]]
then
  i3-msg exec "gnome-terminal -- sh -c 'yay -Syu'" &> /dev/null
fi
