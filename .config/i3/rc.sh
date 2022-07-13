#!/bin/bash

#sudo xinput set-prop 'DLL06E4:01 06CB:7A13 Touchpad' 297 1, 0, 0
#sudo xinput set-prop 'DLL06E4:01 06CB:7A13 Touchpad' 304 0
#sudo xinput set-prop 'DLL06E4:01 06CB:7A13 Touchpad' 288 0
#sudo xinput set-prop 'DLL06E4:01 06CB:7A13 Touchpad' 284 1
#
#sudo xinput set-prop 'DLL06E4:01 06CB:7A13 Touchpad' 285 1
#touchscreenId="$(xinput | grep Touchscreen | sed -r 's#^.+id=([0-9]+).+$#\1#g')"
#if [[ ! -z $touchscreenId ]]
#then
#  xinput --map-to-output $(xinput | rg Touchscreen | sed -r 's#^.+id=([0-9]+).+$#\1#g') $(xrandr | rg eDP | sed -r 's#^([^ ]+).+$#\1#g')
#fi
#
#
#touchPad=$(xinput | rg Touchpad | sed -r 's#^.+id=([0-9]+).+$#\1#g')
#tappingProperty=$(xinput list-props $touchPad | grep 'Tapping Enabled' | grep -i -v default | sed -r 's#^.+\(([0-9]+)\).+$#\1#g')
#xinput set-prop $touchPad $tappingProperty 1
#
#typingProperty=$(xinput list-props $touchPad | grep 'Disable While Typing Enabled' | grep -i -v default | sed -r 's#^.+\(([0-9]+)\).+$#\1#g')
#
#xinput set-prop $touchPad $typingProperty 0
#xinput --map-to-output $(xinput | rg Touchscreen | sed -r 's#^.+id=([0-9]+).+$#\1#g') $(xrandr | rg eDP | sed -r 's#^([^ ]+).+$#\1#g')

