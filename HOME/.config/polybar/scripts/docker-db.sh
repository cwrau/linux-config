#!/bin/bash

eval $(cat $HOME/.config/polybar/colors.ini | rg '^[a-z]+ = #[0-9a-fA-F]+$' | tr -d ' ' | sed -r 's#^#color_#g')

if docker inspect -f '{{.State.Running}}' db 2> /dev/null | grep true &> /dev/null; then
  echo "%{F$color_green}%{F-}"
else
  echo "%{F$color_orange}%{F-}"
fi
