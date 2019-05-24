#!/bin/bash

width=$(echo $1 | jq .width -r)
rel_x=$(echo $1 | jq .relative_x -r)
interface=$(echo $1 | jq .instance -r)

if (( $(echo "($rel_x / $width) < .5" | bc -l) ))
then
  exec networkmanager_dmenu
else
  ip address show $interface | grep -Po 'inet \K[\d.]+' | tr -d '\n' | xclip -selection clipboard
fi
