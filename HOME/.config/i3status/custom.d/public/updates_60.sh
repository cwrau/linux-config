#!/bin/bash

set -ex -o pipefail

timeout 0.4 ping -c 1 google.com &>/dev/null

timeout 20 yay -Syy &>/dev/null

num=$(yay -Qu 2>/dev/null | wc -l)

if [[ ${num:-0} -gt 0 ]]
then
  echo "$num Updates available"
  echo "$color_bad"
  echo "$num Updates available"
  echo "-u critical"
fi
