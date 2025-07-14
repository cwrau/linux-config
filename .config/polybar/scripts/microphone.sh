#!/usr/bin/env bash
SYMBOL_MIC=""
SYMBOL_MIC_MUTED=""

source "$XDG_CONFIG_HOME/polybar/scripts/parse_colors.sh"

conferenceServices=(browser@daily.service browser@meeting.service discord.service)

function notify() {
  dunstify -a microphone -h string:x-dunst-stack-tag:microphone -t 500 "$@"
}

function update() {
  local source
  local state
  local muted
  local easyeffects_muted
  local symbol
  local color
  local outputs
  local outputString
  source=$(pactl info | grep 'Default Source' | grep -i -v monitor | awk -F ': ' '{print $2}')

  if [[ -z "$source" || "$source" == easyeffects_source ]]; then
    color="$color_grey"
    symbol=" $SYMBOL_MIC_MUTED "
  else
    IFS=: read -r state muted <<<"$(pactl list sources | grep -E 'State:|Name:|Mute:' | sed -zr "s#^.*[\t ]+State: (\S+?)\n\s+Name: $source\n\tMute: (\S+?)\n.*\$#\1:\2#g")"
    IFS=: read -r easyeffects_muted <<<"$(pactl list sources | grep -E 'State:|Name:|Mute:' | sed -zr "s#^.*[\t ]+State: \S+?\n\s+Name: easyeffects_source\n\tMute: (\S+?)\n.*\$#\1#g")"

    if [[ "$easyeffects_muted" == yes ]]; then
      pactl set-source-mute easyeffects_source false
    fi

    outputs="$(pactl list source-outputs | grep 'application.name = "' | grep -cv glava)"
    if ((outputs > 1)); then
      outputString="%{O-3pt}$outputs"
    fi

    if [[ "$muted" == yes ]]; then
      symbol="$SYMBOL_MIC_MUTED"
      if [[ "$state" == RUNNING ]]; then
        color="$color_pishade7"
        if systemctl --user is-active -q gamemode.service; then
          notify -i audio-input-microphone-muted-symbolic Microphone muted
        fi
      else
        color="$color_green"
      fi
    else
      symbol=" $SYMBOL_MIC "
      if [[ "$state" == RUNNING ]]; then
        color="$color_pink"
        if systemctl --user is-active -q gamemode.service; then
          notify -i audio-input-microphone-symbolic Microphone unmuted
        fi
        pactl set-source-volume @DEFAULT_SOURCE@ 100%
      else
        color="$color_pishade7"
      fi
    fi
  fi

  echo "%{A1:/usr/bin/pactl set-source-mute @DEFAULT_SOURCE@ toggle:}%{F$color}$symbol${outputString}%{F-}%{A}"

  if [[ "$state" == RUNNING ]]; then
    flock -x "$XDG_RUNTIME_DIR/polybar/microphone-lock" bash -c "date +%s > '$XDG_RUNTIME_DIR/polybar/microphone'"
  else
    if [[ ! -s "$XDG_RUNTIME_DIR/polybar/microphone" ]] || ((($(date +%s) - $(cat "$XDG_RUNTIME_DIR/polybar/microphone")) > 10)); then
      pactl set-source-mute @DEFAULT_SOURCE@ true
      flock -x "$XDG_RUNTIME_DIR/polybar/microphone-lock" bash -c "echo 0 > '$XDG_RUNTIME_DIR/polybar/microphone'"
    else
      (
        sleep 10
        update
      ) &
    fi
  fi

  #for conferenceService in "${conferenceServices[@]}"; do
  #  if systemctl --user is-active -q "$conferenceService"; then
  #    local clients
  #    mapfile -t clients < <(pactl -f json list | jq -er --argjson pids "$(pgrep -g "$(systemctl --user show -p MainPID --value "$conferenceService")" | jq -cers)" '.sink_inputs[] | .properties["application.process.id"] as $pid | select($pid and ($pid | tonumber | IN($pids[]))) | .index')
  #    for client in "${clients[@]}"; do
  #      pactl move-sink-input "$client" easyeffects_sink
  #    done
  #  fi
  #done
}

[ -f "$XDG_RUNTIME_DIR/polybar/microphone" ] || (echo 0 >"$XDG_RUNTIME_DIR/polybar/microphone")

update
pactl subscribe | grep --line-buffered -E "'(change|remove|new)' on source" | while read -r _; do
  update
done
