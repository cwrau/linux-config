#! /usr/bin/env bash

source "$XDG_CONFIG_HOME/polybar/scripts/parse_colors.sh"

function notify() {
  dunstify -a bluetooth -t 2000 "$@"
}

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

  sudo dbus-send --system --dest="org.$service" --print-reply=literal "/org/$service/hci0/$path" org.freedesktop.DBus.Properties.Get "string:org.$service.$object" "string:$field" | awk '{print $3}' || echo -1
}

function unlock() {
  flock -u 4
  flock -u 5
}

LOCKDIR=$XDG_RUNTIME_DIR/polybar/bluetooth-battery
mkdir -p "$LOCKDIR"

exec 4<>"$LOCKDIR/run-lock"
RUN_LOCK=4
exec 5<>"$LOCKDIR/message-lock"
MESSAGE_LOCK=5
MESSAGE_FILE="$LOCKDIR/message"
touch "$MESSAGE_FILE"
DEVICES_FILE="$LOCKDIR/connected_devices"
touch "$DEVICES_FILE"
trap unlock EXIT

first_run=true
supportsHSPHFPD=false
if busctl status org.hsphfpd &>/dev/null; then
  supportsHSPHFPD=true
fi

function update() {
  if flock -n $RUN_LOCK; then
    flock -x $MESSAGE_LOCK
    local mac info battery alias protocol
    local -a old_devices new_devices
    local old_device new_device
    mapfile -t old_devices <"$DEVICES_FILE"
    truncate -s 0 "$DEVICES_FILE"
    if bluetoothctl show | grep -q "Powered: yes"; then
      echo -n "%{F$color_blue}"
      for mac in $(bluetoothctl devices Connected | grep -E ^Device | awk '{print $2}'); do
        info="$(bluetoothctl info "$mac")"
        battery=
        alias="$(grep 'Alias' <<<"$info" | cut -d ' ' -f 2-)"
        echo "$alias" >>"$DEVICES_FILE"
        if grep -q "Battery Percentage:" <<<"$info"; then
          battery=$(sed -rn 's/^\s*Battery Percentage: .+ \(([0-9]+)\)$/\1/p' <<<"$info")
        elif grep -q '0000180f-0000-1000-8000-00805f9b34fb' <<<"$info"; then # Battery Service
          battery=$(dbus bluez "$mac")
        elif grep -q '0000111e-0000-1000-8000-00805f9b34fb' <<<"$info"; then # Handsfree
          battery=$(echo "from bluetooth_battery import BatteryStateQuerier; print(int(BatteryStateQuerier(\"$mac\")))" | python 2>/dev/null)
        elif $supportsHSPHFPD && grep -q '00001200-0000-1000-8000-00805f9b34fb' <<<"$info"; then # PnP Information
          for protocol in hfp_hf hfp_ag hsp_hs; do
            battery=$(dbus hsphfpd "$mac" $protocol)
            if [[ -n "$battery" && "$battery" != "-1" ]]; then
              break
            fi
          done
          if [[ "$battery" == "-1" ]]; then
            unset battery
          fi
        fi
        echo "$alias${battery:+ ($battery%)}"
      done | sort | paste -sd "," - | sed 's#,#, #g; s#^# #'
    else
      echo ""
    fi | tee "$MESSAGE_FILE"
    mapfile -t new_devices <"$DEVICES_FILE"
    if [[ "$first_run" == false ]]; then
      for new_device in "${new_devices[@]}"; do
        if ! grep -q "$new_device" <<<"${old_devices[*]}"; then
          notify -i bluetooth-active "Connected $new_device"
        fi
      done
      for old_device in "${old_devices[@]}"; do
        if ! grep -q "$old_device" <<<"${new_devices[*]}"; then
          notify -i bluetooth-disconnected-symbolic "Disonnected $old_device"
        fi
      done
    else
      first_run=false
    fi
  else
    flock -s $MESSAGE_LOCK
    cat "$MESSAGE_FILE"
  fi
  unlock
}

update

dbus-monitor --system --profile member=PropertiesChanged 2>/dev/null | grep --line-buffered -e /org/bluez/hci0/dev -e /org/hsphfpd | while read -r _; do
  update
done
