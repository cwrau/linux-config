#!/bin/bash

set -ex -o pipefail

timeout 0.4 ping -c 1 topixsrv.cm.dom &>/dev/null

timeout 20 yay -Syy &>/dev/null

pgrep yay &>/dev/null && exit 1

num=$(yay -Qu 2>/dev/null | wc -l)

if [[ ${num:-0} -gt 0 ]]
then
  echo "$num Updates available"
  echo "$color_bad"
  echo "$num Updates available"
  echo "-u critical"
fi
