#!/usr/bin/env bash
# Home Assistant toggle button, shown only while at home (device_tracker.steve == home)
# and at least one of the configured outputs is connected.
# Usage: ha-toggle.sh <anlage|ringlicht|fernsehen>
# Toggle by sending SIGUSR1 to the running instance (polybar: %pid%, waybar: pid in $pidFile), which already holds the decrypted token.
name="$1"
case "$name" in
  anlage)
    entity=media_player.anlage
    action=toggle
    outputs=(HDMI-0)
    symbol_on=$''
    symbol_off=$''
    ;;
  ringlicht)
    entity=light.ring_licht
    action=toggle
    outputs=(HDMI-0 DP-1)
    symbol_on=$''
    symbol_off=$''
    ;;
  fernsehen)
    # state comes from the switch, the click activates the scene
    entity=switch.buro_fernseher
    actionEntity=scene.buro_fernsehen
    action=turn_on
    outputs=(HDMI-0 DP-1)
    symbol_on=$'\uf26c'
    symbol_off=$'\uf26c'
    ;;
  *)
    echo "unknown button: $name" >&2
    exit 1
    ;;
esac

haUrl=https://homeassistant.cwrau.de/api
tracker=device_tracker.steve
actionEntity="${actionEntity:-$entity}"
actionDomain="${actionEntity%%.*}"

source "$XDG_CONFIG_HOME/bar/scripts/parse_colors.sh"

haToken="$(systemd-creds --user decrypt "$XDG_CONFIG_HOME/credstore.encrypted/homeassistant-token" -)"

function ha() {
  curl -m 5 -fsSL -H "Authorization: Bearer $haToken" -H "Content-Type: application/json" "$@"
}

function output_connected() {
  local output
  if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    # X11/NVIDIA names (HDMI-0, DP-1) -> DRM connector names (HDMI-A-*, DP-*)
    for output in "${outputs[@]}"; do
      output="${output%-*}"
      output="${output/HDMI/HDMI-A}"
      rg -q '^connected$' /sys/class/drm/card*-"$output"-*/status 2>/dev/null && return
    done
    return 1
  else
    local connected
    connected="$(xrandr --query)"
    for output in "${outputs[@]}"; do
      rg -q "^$output connected" <<<"$connected" && return
    done
    return 1
  fi
}

function update() {
  local trackerState state symbol color tooltip
  if output_connected && trackerState="$(ha "$haUrl/states/$tracker" | jq -r .state)" && [[ "$trackerState" == home ]]; then
    state="$(ha "$haUrl/states/$entity" | jq -r .state)" || state=unavailable
    case "$state" in
      off)
        symbol="$symbol_off"
        color="$color_grey"
        ;;
      unavailable | unknown | "")
        symbol="$symbol_off"
        color="$color_yellow"
        ;;
      *)
        symbol="$symbol_on"
        color="$color_green"
        ;;
    esac
    tooltip="$name: ${state:-unknown}"
    if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
      jq -cn --arg text "<span color=\"$color\"> $symbol </span>" --arg tooltip "$tooltip" '{text:$text,tooltip:$tooltip}'
    else
      echo "%{F$color} $symbol %{F-}"
    fi
  elif [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    jq -cn '{text:"",tooltip:""}'
  fi
}

pidFile="$XDG_RUNTIME_DIR/bar/ha-toggle-$name.pid"
mkdir -p "${pidFile%/*}"
echo $$ >"$pidFile"

function kill_tree() {
  local child
  for child in $(pgrep -P "$1"); do
    kill_tree "$child"
  done
  kill "$1" 2>/dev/null
}

function cleanup() {
  local child
  rm -f "$pidFile"
  for child in $(pgrep -P $$); do
    kill_tree "$child"
  done
}
trap cleanup EXIT
trap exit TERM INT HUP

function run_action() {
  ha -X POST -d "{\"entity_id\": \"$actionEntity\"}" "$haUrl/services/$actionDomain/$action" >/dev/null
}
trap run_action USR1

# Each line printed by the watchers means "something relevant may have changed".

# Home Assistant: websocket subscription, filtered server-side to our two entities.
# A heartbeat (HA ping/pong) every 30s doubles as liveness check: if nothing arrives for 90s the
# connection is considered dead and rebuilt. Re-announces on every (re)connect to resync state
# that may have changed while disconnected.
function watch_ha() {
  local ws wsPid type
  while true; do
    echo "ha-connected"
    # process substitution instead of a pipeline, so a hung connection can be killed
    exec {ws}< <(
      {
        jq -cn --arg token "$haToken" '{type: "auth", access_token: $token}'
        jq -cn --arg tracker "$tracker" --arg entity "$entity" '{id: 1, type: "subscribe_entities", entity_ids: [$tracker, $entity]}'
        id=1
        while sleep 30; do
          jq -cn --argjson id "$((++id))" '{id: $id, type: "ping"}'
        done
      } |
        websocat -t --no-close "${haUrl/#https:/wss:}/websocket" |
        jq --unbuffered -R -r 'fromjson? | select(.type == "event" or .type == "pong") | .type'
    )
    wsPid=$!
    while read -r -t 90 -u "$ws" type; do
      [[ "$type" == event ]] && echo "event"
    done
    # timeout (dead connection) or EOF (websocat exited)
    kill_tree "$wsPid"
    exec {ws}<&-
    sleep 5
  done
}

# Output hotplug via udev, works for both X11 and Wayland
function watch_outputs() {
  while true; do
    stdbuf -oL udevadm monitor --udev --subsystem-match=drm | rg --line-buffered ' change '
    sleep 5
  done
}

last=
function emit() {
  local out
  out=$(update)
  # only emit on change, re-emitting identical output makes the bar redraw/flicker
  [[ "$out" == "$last" ]] && return 1
  echo "$out"
  last=$out
}

exec {events}< <(
  watch_ha &
  watch_outputs &
  wait
)

while true; do
  emit
  # wait for an event (SIGUSR1 runs the action trap, the resulting state change arrives as an event)
  read -r -u "$events" _
  # debounce bursts (hotplug, state + attribute changes)
  while read -r -t 0.3 -u "$events" _; do :; done
done
