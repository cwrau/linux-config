#! /usr/bin/env bash

function dbus() {
  mac=$2
  case "$1" in
    bluez)
      service=bluez
      path=dev_${mac//:/_}
      object=Battery1
      field=Percentage
      ;;
    hsphfpd)
      service=hsphfpd
      path=dev_${mac//:/_}/$3
      object=Endpoint
      field=BatteryLevel
      ;;
  esac

  dbus-send --system --dest=org.$service --print-reply=literal /org/$service/hci0/$path org.freedesktop.DBus.Properties.Get string:org.$service.$object string:$field 2>/dev/null | awk '{print $3}' || echo -1
}

function unlock() {
  flock -u 4
  flock -u 5
}

LOCKDIR=$XDG_RUNTIME_DIR/bluetooth-battery
mkdir -p $LOCKDIR

exec 4<>$LOCKDIR/run-lock
exec 5<>$LOCKDIR/message-lock
trap unlock EXIT

if flock -n 4; then
  flock -x 5
  if bluetoothctl show | grep -q "Powered: yes"; then
    echo -n "%{F#2193ff}"
    if bluetoothctl info | grep -q 'Device'; then
      for mac in $(bluetoothctl paired-devices | awk '{print $2}'); do
        info="$(bluetoothctl info $mac)"
        if grep -q 'Connected: yes' <<<"$info"; then
          battery=
          alias="$(grep 'Alias' <<<"$info" | cut -d ' ' -f 2-)"
          if grep -q '0000180f-0000-1000-8000-00805f9b34fb' <<<"$info"; then # Battery Service
            battery=$(dbus bluez $mac)
          elif grep -q '0000111e-0000-1000-8000-00805f9b34fb' <<<"$info"; then # Handsfree
            battery=$(echo "from bluetooth_battery import BatteryStateQuerier; print(int(BatteryStateQuerier(\"$mac\")))" | python 2>/dev/null)
          #elif grep -q '00001200-0000-1000-8000-00805f9b34fb' <<<"$info"; then # PnP Information
          #  for protocol in hfp_hf hfp_ag hsp_hs; do
          #    battery=$(dbus hsphfpd $mac $protocol)
          #    if [ ! -z "$battery" ] && [ "$battery" != "-1" ]; then
          #      break
          #    fi
          #  done
          #  if [ "$battery" = "-1" ]; then
          #    unset battery
          #  fi
          fi
          echo "$alias${battery:+ ($battery%)}"
        fi
      done | sort | paste -sd "," - | sed 's#,#, #g; s#^# #'
    fi
  else
    echo ""
  fi | tee $LOCKDIR/message
else
  flock -s 5
  cat $LOCKDIR/message
fi

