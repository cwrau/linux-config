#!/bin/bash

width=$(echo $1 | jq .width -r)
rel_x=$(echo $1 | jq .relative_x -r)
interface=$(echo $1 | jq .instance -r)

if (( $(echo "($rel_x / $width) < .5" | bc -l) ))
then
  i3-msg exec 'gnome-terminal -- gotop -r 8' &> /dev/null
else
  i3-msg exec 'gnome-terminal -- glances' &> /dev/null
fi
