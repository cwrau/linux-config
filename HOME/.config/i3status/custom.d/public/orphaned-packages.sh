#!/bin/bash

set -ex -o pipefail

pgrep yay &>/dev/null && exit 1

num=$(yay -Qtd 2>/dev/null | wc -l || echo)

if [[ ${num:-0} -gt 0 ]]
then
    echo "$num Packages orphaned"
    echo "$color_bad"
fi
