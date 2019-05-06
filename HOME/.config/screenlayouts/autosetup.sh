#!/bin/sh

set -ex -o pipefail

if xrandr | grep -Pzo 'HDMI-1 .+\n(\s+.+\n)+' | grep -Pzo '\d+x1080 .+\n'
then
    $(dirname $(realpath $0))/1080multi.sh $(xrandr | grep -Pzo 'HDMI-1 .+\n(\s+.+\n)+' | grep -Pzo '\d+x1080 .+\n' | sed -r 's#([0-9]+)x1080.+$#\1#g' | sort -h | tail -1)
elif [ "$(xrandr | grep ' connected ' | wc -l)" -eq 1 ]
then
    $(dirname $(realpath $0))/laptop.sh
fi

feh --bg-fill $HOME/.config/background.jpg