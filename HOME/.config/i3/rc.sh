#!/bin/bash

sudo xinput set-prop 'DLL06E4:01 06CB:7A13 Touchpad' 297 1, 0, 0
sudo xinput set-prop 'DLL06E4:01 06CB:7A13 Touchpad' 304 0
sudo xinput set-prop 'DLL06E4:01 06CB:7A13 Touchpad' 288 0
sudo xinput set-prop 'DLL06E4:01 06CB:7A13 Touchpad' 284 1
sudo xinput set-prop 'DLL06E4:01 06CB:7A13 Touchpad' 285 1
touchscreenId="$(xinput | grep Touchscreen | sed -r 's#^.+id=([0-9]+).+$#\1#g')"
if [[ ! -z $touchscreenId ]]
then
    sudo xinput map-to-output $touchscreenId eDP1
fi
