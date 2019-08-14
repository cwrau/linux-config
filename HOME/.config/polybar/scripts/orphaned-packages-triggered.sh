#!/bin/bash

set -e -o pipefail

DIR=/tmp/polybar/orphaned-packages
mkdir -p $DIR

num=$(yay -Qtd 2>/dev/null | wc -l || echo)

if [[ ${num:-0} -gt 0 ]]
then
  echo " $num"
else
  echo
fi

echo $num > $DIR/count
