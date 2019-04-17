dbus-update-activation-environment --systemd --all
$HOME/.config/screenlayouts/autosetup.sh
xinput | rg Touchpad | sed -r 's#^.+id=([0-9]+).+$#\1#g' | xargs -t -n 1 -I {} sh -x -c "xinput set-prop {} \$(xinput list-props {} | grep 'Tapping Enabled' | grep -i -v default | sed -r 's#^.+\(([0-9]+)\).+\$#\1#g') 1"
exec i3
