#!/bin/bash

choice=$(echo -e 'Yes\nManual\nNo' | dmenu -p "Update packages?")

case $choice in
  Yes) i3-msg exec "i3-sensible-terminal -- sh -c 'yay -Syu --noconfirm --removemake'" ;;
  Manual) i3-msg exec "i3-sensible-terminal -- sh -c 'yay -Syu'" ;;
esac
