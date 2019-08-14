#!/bin/bash

choice=$(echo -e 'Yes\nManual\nNo' | dmenu -p "Remove Orphaned packages?")

case $choice in
  Yes) i3-msg exec "i3-sensible-terminal -- sh -c 'yay -Rns --noconfirm \$(yay -Qtdq)'" ;;
  Manual) i3-msg exec "i3-sensible-terminal -- sh -c 'yay -Rns \$(yay -Qtdq)'" ;;
esac
