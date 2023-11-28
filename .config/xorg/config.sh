#!/usr/bin/env bash

set -x

xinput list | grep -i touchpad | cut -d = -f 2 | awk NF=1 | while read touchpadId; do
	xinput set-prop $touchpadId 'libinput Click Method Enabled' 0 1
	xinput set-prop $touchpadId 'libinput Tapping Enabled' 1
	xinput set-prop $touchpadId 'libinput Natural Scrolling Enabled' 0
done

xset r on r rate 200
xset s off
xrandr --dpi 100
xrdb "$XDG_CONFIG_HOME/xorg/Xresources"
