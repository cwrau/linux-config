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

xinput --map-to-output $(xinput | rg Touchscreen | sed -r 's#^.+id=([0-9]+).+$#\1#g') $(xrandr | rg eDP | sed -r 's#^([^ ]+).+$#\1#g')

xinput | rg Touchpad | sed -r 's#^.+id=([0-9]+).+$#\1#g' | xargs -t -n 1 -I {} sh -x -c "xinput set-prop {} \$(xinput list-props {} | grep 'Tapping Enabled' | grep -i -v default | sed -r 's#^.+\(([0-9]+)\).+\$#\1#g') 1"

xinput | rg Touchpad | sed -r 's#^.+id=([0-9]+).+$#\1#g' | xargs -t -n 1 -I {} sh -x -c "xinput set-prop {} \$(xinput list-props {} | grep 'Disable While Typing Enabled' | grep -i -v default | sed -r 's#^.+\(([0-9]+)\).+\$#\1#g') 0"
xinput --map-to-output $(xinput | rg Touchscreen | sed -r 's#^.+id=([0-9]+).+$#\1#g') $(xrandr | rg eDP | sed -r 's#^([^ ]+).+$#\1#g')

sudo powertop --auto-tune
systemctl --user start xdg-user-dirs-update

for s in blugon blueman-applet clipmenud discord dunst feh foldingathome gnome-polkit-agent google-chrome google-play-music-player kdeconnect-indicator networkmanager-applet picom premid slack steam telegram whatsapp xfce4-power-manager; do
 scu start $s
done
