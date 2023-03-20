#!/usr/bin/env bash

set -x

xinput list | grep -i touchpad | cut -d = -f 2 | awk NF=1 | xargs -r -t -i xinput set-prop {} 'libinput Click Method Enabled' 0 1
xinput list | grep -i touchpad | cut -d = -f 2 | awk NF=1 | xargs -r -t -i xinput set-prop {} 'libinput Tapping Enabled' 1

xset r on r rate 200
xset s off
xrandr --dpi 100
xrdb "$XDG_CONFIG_HOME/xorg/Xresources"
