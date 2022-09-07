#!/usr/bin/env bash

# shellcheck source=/dev/null
source "$XDG_CONFIG_HOME/polybar/scripts/parse_colors.sh"

function update() {
  local source
  local state
  local muted
  local easyeffects_muted
  local symbol
  local color
  source=$(pactl info | grep 'Default Source' | awk -F: '{print $2}')
  IFS=: read -r state muted <<<"$(pactl list sources | grep -E 'State:|Name:|Mute:' | sed -zr "s#^.*[\t ]+State: (\S+?)\n\s+Name:$source\n\tMute: (\S+?)\n.*\$#\1:\2#g")"
  IFS=: read -r easyeffects_muted <<<"$(pactl list sources | grep -E 'State:|Name:|Mute:' | sed -zr "s#^.*[\t ]+State: \S+?\n\s+Name: easyeffects_source\n\tMute: (\S+?)\n.*\$#\1#g")"

  if [[ "$easyeffects_muted" == yes ]]; then
    pactl set-source-mute easyeffects_source false
  fi

  if [[ "$muted" == yes ]]; then
    symbol=""
    if [[ "$state" == RUNNING ]]; then
      # shellcheck disable=SC2154
      color="$color_pishade7"
    else
      # shellcheck disable=SC2154
      color="$color_green"
    fi
  else
    symbol="  "
    # shellcheck disable=SC2154
    color="$color_pink"
  fi

  echo "%{F$color}$symbol%{F-}"

  if [[ "$state" != RUNNING ]]; then
    pactl set-source-mute @DEFAULT_SOURCE@ true
  fi

  return

  # Do I need a cooldown before auto-muting?
  if [[ "$state" == RUNNING ]]; then
    flock -x "$XDG_RUNTIME_DIR/polybar/microphone_lock" bash -c "date +%s > '$XDG_RUNTIME_DIR/polybar/microphone'"
  else
    if (( ($(date +%s) - $(cat "$XDG_RUNTIME_DIR/polybar/microphone")) > 10 )); then
      pactl set-source-mute @DEFAULT_SOURCE@ true
      flock -x "$XDG_RUNTIME_DIR/polybar/microphone_lock" bash -c "echo 0 > '$XDG_RUNTIME_DIR/polybar/microphone'"
    fi
  fi
}

[ -f "$XDG_RUNTIME_DIR/polybar/microphone" ] || (echo 0 > "$XDG_RUNTIME_DIR/polybar/microphone")

update
pactl subscribe | grep change --line-buffered | while read -r _; do
  update
done
