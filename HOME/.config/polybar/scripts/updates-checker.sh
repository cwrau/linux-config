#!/usr/bin/env bash

set -e -o pipefail

eval $(cat $HOME/.config/polybar/colors.ini | rg '^[a-z]+ = #[0-9a-fA-F]+$' | tr -d ' ' | sed -r 's#^#color_#g')

DIR=/tmp/polybar/updates
mkdir -p $DIR

function cleanUp() {
  sudo rm $DIR/check &> /dev/null
}

trap cleanUp EXIT

function interval() {
  [[ $(( $(date +%s) % $1 )) == 0 ]]
}

function update() {
  timeout 20 yay -Syy &>/dev/null
  yay -Qu 2>/dev/null | wc -l > $DIR/count
}

while true
do
  until interval 60
  do
    if [ -e $DIR/check ]
    then
      sudo rm -f $DIR/check &> /dev/null
      update
    fi
    sleep 1
  done
  update
done
