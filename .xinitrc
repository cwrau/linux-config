dbus-update-activation-environment --systemd --all

#xinput | rg Touchpad | sed -r 's#^.+id=([0-9]+).+$#\1#g' | xargs -t -I {} sh -x -c "xinput set-prop {} \$(xinput list-props {} | grep 'Tapping Enabled' | grep -i -v default | sed -r 's#^.+\(([0-9]+)\).+\$#\1#g') 1"

#xinput | rg Touchpad | sed -r 's#^.+id=([0-9]+).+$#\1#g' | xargs -t -I {} sh -x -c "xinput set-prop {} \$(xinput list-props {} | grep 'Disable While Typing Enabled' | grep -i -v default | sed -r 's#^.+\(([0-9]+)\).+\$#\1#g') 0"

#xinput --map-to-output $(xinput | rg Touchscreen | sed -r 's#^.+id=([0-9]+).+$#\1#g') $(xrandr | rg eDP | sed -r 's#^([^ ]+).+$#\1#g')

xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --output eDP-1-1 --mode 1920x1080 --primary
autorandr --skip-option gamma,brightness --change --default horizontal

xinput set-prop 'SynPS/2 Synaptics TouchPad' 'libinput Click Method Enabled' 0 1

xset r on r rate 250
xrandr --dpi 100

systemd-cat --stderr-priority=warning --identifier=i3 i3
systemctl --user stop graphical-session.target
