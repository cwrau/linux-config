#!/bin/bash

choice=$(echo -e 'Yes\nManual\nNo' | dmenu -p "Remove Orphaned packages?")
if [[ ${choice} = "Yes" ]]
then
  i3-msg exec 'gnome-terminal -- sh -c "yay -Rns --noconfirm $(yay -Qtdq)"' &> /dev/null
elif [[ ${choice} = "Manual" ]]
then
  i3-msg exec 'gnome-terminal -- sh -c "yay -Rns $(yay -Qtdq)"' &> /dev/null
fi
