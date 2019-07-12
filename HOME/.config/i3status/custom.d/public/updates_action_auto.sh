#!/bin/bash

i3-msg exec "gnome-terminal -- sh -c 'yay -Syu --noconfirm --removemake'" &> /dev/null
