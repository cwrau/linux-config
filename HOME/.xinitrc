dbus-update-activation-environment --systemd --all
$HOME/.config/screenlayouts/autosetup.sh

xinput | rg Touchpad | sed -r 's#^.+id=([0-9]+).+$#\1#g' | xargs -t -n 1 -I {} sh -x -c "xinput set-prop {} \$(xinput list-props {} | grep 'Tapping Enabled' | grep -i -v default | sed -r 's#^.+\(([0-9]+)\).+\$#\1#g') 1"

xinput | rg Touchpad | sed -r 's#^.+id=([0-9]+).+$#\1#g' | xargs -t -n 1 -I {} sh -x -c "xinput set-prop {} \$(xinput list-props {} | grep 'Disable While Typing Enabled' | grep -i -v default | sed -r 's#^.+\(([0-9]+)\).+\$#\1#g') 0"
xinput --map-to-output $(xinput | rg Touchscreen | sed -r 's#^.+id=([0-9]+).+$#\1#g') $(xrandr | rg eDP | sed -r 's#^([^ ]+).+$#\1#g')

xrandr --setprovideroutputsource modesetting NVIDIA-0
xrandr --output eDP-1-1 --dpi 92 --primary --scale 1x1 --mode 1920x1080
autorandr --skip-option gamma --change

xset -r rate 250

sudo rfkill unblock all

i3
