#!/bin/bash

set -ex -o pipefail

num=$(cd $HOME/projects/linux-config &> /dev/null && git ls-files -m | wc -l)

if [[ ${num:-0} -gt 0 ]]
then
    echo "$num Configs changed"
    echo "$color_bad"
fi
