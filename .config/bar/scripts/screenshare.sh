#!/usr/bin/env bash
# Shows an icon while the screen is being captured, nothing otherwise.
# Detection:
#   - PipeWire: a Stream/Input/Video node linked to a Stream/Output/Video node
#     (portal screencast; cameras are Video/Source and thus excluded)
#   - X11: Chromium's "is sharing your screen" control window (Chromium captures X11 directly)
#   - known recorder processes that bypass PipeWire (wlr-screencopy / x11grab)
SYMBOL_SCREEN=$''

source "$XDG_CONFIG_HOME/bar/scripts/parse_colors.sh"

recorders='wf-recorder|wl-screenrec|obs|kooha'

function pipewire_capture() {
  pw-dump | jq -e '
    (map(select(.type == "PipeWire:Interface:Node") | {key: (.id | tostring), value: .info.props["media.class"]}) | from_entries) as $class
    | any(.[] | select(.type == "PipeWire:Interface:Link") | .info;
        $class[(.["input-node-id"] | tostring)] == "Stream/Input/Video"
        and $class[(.["output-node-id"] | tostring)] == "Stream/Output/Video")
  ' >/dev/null
}

function x11_capture() {
  [[ -n "$DISPLAY" ]] && xdotool search --onlyvisible --name 'is sharing (your screen|a window|your tab)|Stop sharing' >/dev/null 2>&1
}

function recorder_running() {
  pgrep -x "$recorders" >/dev/null || pgrep -a -x ffmpeg | rg -q '(x11grab|kmsgrab)'
}

function update() {
  local text="" tooltip=""
  if pipewire_capture; then
    tooltip="Screen shared via PipeWire"
  elif x11_capture; then
    tooltip="Screen shared via X11 window"
  elif recorder_running; then
    tooltip="Screen recorder running"
  fi

  if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    [[ -n "$tooltip" ]] && text="<span color=\"$color_pink\"> $SYMBOL_SCREEN </span>"
    jq -cn --arg text "$text" --arg tooltip "$tooltip" '{text:$text,tooltip:$tooltip}'
  elif [[ -n "$tooltip" ]]; then
    echo "%{F$color_pink} $SYMBOL_SCREEN %{F-}"
  else
    echo -n ""
  fi
}

last=
while true; do
  out=$(update)
  # only emit on change, re-emitting identical output makes the bar redraw/flicker
  if [[ "$out" != "$last" ]]; then
    echo "$out"
    last=$out
  fi
  sleep 2
done
