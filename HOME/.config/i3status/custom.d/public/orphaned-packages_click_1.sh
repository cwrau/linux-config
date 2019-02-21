#!/bin/bash

if [[ $(echo -e 'Yes\nNo' | dmenu -p "Remove Orphaned packages?") = "Yes" ]]
then
  i3-msg exec 'gnome-terminal -- sh -c "yay -Rns --noconfirm $(yay -Qtdq)"' &> /dev/null
fi
