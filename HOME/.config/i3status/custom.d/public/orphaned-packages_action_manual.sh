#!/bin/bash

i3-msg exec "gnome-terminal -- sh -c 'yay -Rns \$(yay -Qtdq)'" &> /dev/null
