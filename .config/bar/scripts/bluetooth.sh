#! /usr/bin/env bash

if [[ "$1" == "--toggle" ]]; then
  if bluetoothctl show | grep -q "Powered: yes"; then
    bluetoothctl power off
  else
    bluetoothctl power on
  fi
  exit 0
fi

source "$XDG_CONFIG_HOME/bar/scripts/parse_colors.sh"

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

LOCKDIR=$XDG_RUNTIME_DIR/bar/bluetooth-battery
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

function get_charging_state() {
  local mac=$1
  local path info
  while IFS= read -r path; do
    info=$(upower -i "$path" 2>/dev/null)
    if grep -qi "serial:.*$mac" <<<"$info"; then
      awk '/^[[:space:]]*state:/{print $2}' <<<"$info"
      return
    fi
  done < <(upower -e 2>/dev/null | grep -v DisplayDevice)
}

function update() {
  if flock -n $RUN_LOCK; then
    flock -x $MESSAGE_LOCK
    local message
    local mac info battery charging alias protocol
    local -a old_devices new_devices device_strings
    local old_device new_device
    local devices_text="" connected_count=0 bt_powered=false

    mapfile -t old_devices <"$DEVICES_FILE"
    truncate -s 0 "$DEVICES_FILE"

    if bluetoothctl show | grep -q "Powered: yes"; then
      bt_powered=true
      for mac in $(bluetoothctl devices Connected | grep -E ^Device | awk '{print $2}'); do
        info="$(bluetoothctl info "$mac")"
        battery=
        alias="$(grep 'Alias' <<<"$info" | cut -d ' ' -f 2-)"
        echo "$alias" >>"$DEVICES_FILE"
        if grep -q "Battery Percentage:" <<<"$info"; then
          battery=$(sed -rn 's/^\s*Battery Percentage: .+ \(([0-9]+)\)$/\1/p' <<<"$info")
        elif grep -q '0000180f-0000-1000-8000-00805f9b34fb' <<<"$info"; then
          battery=$(dbus bluez "$mac")
        elif grep -q '0000111e-0000-1000-8000-00805f9b34fb' <<<"$info"; then
          battery=$(echo "from bluetooth_battery import BatteryStateQuerier; print(int(BatteryStateQuerier(\"$mac\")))" | python 2>/dev/null)
        elif $supportsHSPHFPD && grep -q '00001200-0000-1000-8000-00805f9b34fb' <<<"$info"; then
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
        charging=$(get_charging_state "$mac")
        if [[ "$charging" == "charging" ]]; then
          device_strings+=("${alias} (charging)")
        else
          device_strings+=("${alias}${battery:+ (${battery}%)}")
        fi
        ((connected_count++))
      done
      devices_text=$(printf '%s, ' "${device_strings[@]}")
      devices_text="${devices_text%, }"
    fi

    local bt_icon=$'\uf294'
    if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
      local text tooltip class color
      if $bt_powered; then
        color="$color_blue"
        if ((connected_count > 0)); then
          text="<span color=\"$color\">${bt_icon} ${devices_text}</span>"
          tooltip="Bluetooth: ${connected_count} device(s) - ${devices_text}"
          class="connected"
        else
          text="<span color=\"$color\">${bt_icon}</span>"
          tooltip="Bluetooth: on, no devices"
          class="on"
        fi
      else
        color="$color_grey"
        text="<span color=\"$color\">${bt_icon}</span>"
        tooltip="Bluetooth: off"
        class="off"
      fi
      message="$(jq -cn --arg text "$text" --arg tooltip "$tooltip" --arg class "$class" '{text:$text,tooltip:$tooltip,class:$class}')"
    else
      message="%{A3:$0 --toggle:}$(if $bt_powered; then
        echo -n "%{F$color_blue}${bt_icon}"
        if [[ -n "$devices_text" ]]; then
          echo -n " $devices_text"
        fi
        echo -n "%{F-}"
      else
        echo -n "%{F$color_grey}${bt_icon}%{F-}"
      fi)%{A}"
    fi

    echo "$message" | tee "$MESSAGE_FILE"
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

dbus-monitor --system --profile member=PropertiesChanged 2>/dev/null | grep --line-buffered -e /org/bluez/hci0/dev -e ':1.5.*/org/bluez/hci0' -e /org/hsphfpd | while read -r _; do
  update
done
