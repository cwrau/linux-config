#!/bin/bash

i3-msg exec "gnome-terminal -- sh -c 'yay -Rns --noconfirm \$(yay -Qtdq)'" &> /dev/null
