dbus-update-activation-environment --systemd --all

#xinput | rg Touchpad | sed -r 's#^.+id=([0-9]+).+$#\1#g' | xargs -t -I {} sh -x -c "xinput set-prop {} \$(xinput list-props {} | grep 'Tapping Enabled' | grep -i -v default | sed -r 's#^.+\(([0-9]+)\).+\$#\1#g') 1"

#xinput | rg Touchpad | sed -r 's#^.+id=([0-9]+).+$#\1#g' | xargs -t -I {} sh -x -c "xinput set-prop {} \$(xinput list-props {} | grep 'Disable While Typing Enabled' | grep -i -v default | sed -r 's#^.+\(([0-9]+)\).+\$#\1#g') 0"

#xinput --map-to-output $(xinput | rg Touchscreen | sed -r 's#^.+id=([0-9]+).+$#\1#g') $(xrandr | rg eDP | sed -r 's#^([^ ]+).+$#\1#g')

xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --output eDP-1-1 --mode 1920x1080 --primary
autorandr --skip-option gamma,brightness --change --default horizontal

xinput list | grep touchpad | cut -d = -f 2 A NF=1 | xargs -i xinput set-prop {} 'libinput Click Method Enabled' 0 1
xinput list | grep touchpad | cut -d = -f 2 A NF=1 | xargs -i xinput set-prop {} 'libinput Tapping Enabled' 1

xset r on r rate 200
xset s off
xrandr --dpi 100

systemd-cat --stderr-priority=warning --identifier=i3 i3
systemctl --user stop graphical-session.target
