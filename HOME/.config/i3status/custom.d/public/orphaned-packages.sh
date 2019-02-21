#!/bin/bash

set -ex -o pipefail

pgrep yay &>/dev/null && exit 1

num=$(timeout 20 bash -c "yay -Qtd  2>/dev/null | awk '{print \$1}' | wc -l")

if [[ ${num:-0} -gt 0 ]]
then
    echo "$num Packages orphaned"
    echo "$color_bad"
fi
