#!/bin/bash

set -e
set -o pipefail

function idealPercent() {
  local windowSeconds="$1" rDate="$2" rTime="$3"
  local resetEpoch nowEpoch secondsUntilReset secondsSinceStart
  [[ -z "$rDate" || -z "$rTime" ]] && return
  resetEpoch="$(date -d "$rDate $rTime" +%s)"
  nowEpoch="$(date +%s)"
  secondsUntilReset=$((resetEpoch - nowEpoch))
  ((secondsUntilReset < 0)) && secondsUntilReset=0
  ((secondsUntilReset > windowSeconds)) && secondsUntilReset=windowSeconds
  secondsSinceStart=$((windowSeconds - secondsUntilReset))
  echo $((secondsSinceStart * 100 / windowSeconds))
}

if [[ "$1" == click ]]; then
  stateFile="$XDG_STATE_HOME/agent-limit/usage.json"
  resetDate="$(jq -r '.resetDate // empty' "$stateFile")"
  resetTime="$(jq -r '.resetTime // empty' "$stateFile")"
  weeklyResetDate="$(jq -r '.weeklyResetDate // empty' "$stateFile")"
  weeklyResetTime="$(jq -r '.weeklyResetTime // empty' "$stateFile")"
  idealSession="$(idealPercent 18000 "$resetDate" "$resetTime")"
  idealWeekly="$(idealPercent 604800 "$weeklyResetDate" "$weeklyResetTime")"
  [[ -n "$idealSession" ]] && idealSession=$((100 - idealSession))
  [[ -n "$idealWeekly" ]] && idealWeekly=$((100 - idealWeekly))
  dunstify "AI Limit Usage" "$(jq -r --arg idealSession "${idealSession:--}" --arg idealWeekly "${idealWeekly:--}" \
    '"Session resets at \(.resetDate // "-")T\(.resetTime // "-") (ideal: \($idealSession)%)\nWeekly resets at \(.weeklyResetDate // "-")T\(.weeklyResetTime // "-") (ideal: \($idealWeekly)%)"' \
    "$stateFile")"
  exit 0
fi

source "$XDG_CONFIG_HOME/bar/scripts/parse_colors.sh"

stateDir="${XDG_STATE_HOME:-$HOME/.local/state}/agent-limit"
stateFile="$stateDir/usage.json"

function render() {
  if [[ ! -r "$stateFile" ]]; then
    echo
    return
  fi

  local limitUsed
  local limitLeft
  local weeklyLimitUsed
  local weeklyLimitLeft
  limitUsed="$(jq -r '.limitUsed' "$stateFile")"
  limitLeft=$((100 - limitUsed))
  weeklyLimitUsed="$(jq -r '.weeklyLimitUsed' "$stateFile")"
  weeklyLimitLeft=$((100 - weeklyLimitUsed))

  local resetDate resetTime
  resetDate="$(jq -r '.resetDate // empty' "$stateFile")"
  resetTime="$(jq -r '.resetTime // empty' "$stateFile")"

  local weeklyResetDate weeklyResetTime
  weeklyResetDate="$(jq -r '.weeklyResetDate // empty' "$stateFile")"
  weeklyResetTime="$(jq -r '.weeklyResetTime // empty' "$stateFile")"

  # pace color: compare actual usage against the "ideal" usage if spent evenly
  # across the reset cycle (elapsed/windowSeconds*100), not remaining budget
  function paceColor() {
    local usedPercent="$1" windowSeconds="$2" rDate="$3" rTime="$4"
    local ideal paceDiff
    ideal="$(idealPercent "$windowSeconds" "$rDate" "$rTime")"
    paceDiff=$((usedPercent - ideal))
    if [[ $paceDiff -lt -5 ]]; then
      echo "$color_green"
    elif [[ $paceDiff -gt 5 ]]; then
      echo "$color_red"
    else
      echo "$color_orange"
    fi
  }

  local weeklyColor
  if [[ -n "$weeklyResetDate" && -n "$weeklyResetTime" ]]; then
    weeklyColor="$(paceColor "$weeklyLimitUsed" 604800 "$weeklyResetDate" "$weeklyResetTime")"
  else
    weeklyColor="$color_orange"
  fi

  local color
  if [[ -n "$resetDate" && -n "$resetTime" ]]; then
    color="$(paceColor "$limitUsed" 18000 "$resetDate" "$resetTime")"
  else
    color="$color_orange"
  fi

  local icon
  if [[ $limitLeft -le 20 ]]; then
    icon="󱚞 "
    if [[ $limitLeft -le 1 ]]; then
      icon="󱚢 "
    fi
  elif [[ $limitLeft -le 50 ]]; then
    icon="󱙺 "
  else
    icon="󱚤 "
    if [[ $limitLeft -ge 90 ]]; then
      icon="󱚦 "
    fi
  fi

  if [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
    jq -cn --arg text "<span color=\"$color\">$icon $limitLeft%</span> (<span color=\"$weeklyColor\">$weeklyLimitLeft%</span>)" --arg tooltip "$icon limit: $limitLeft% (weekly: $weeklyLimitLeft%)" '{text:$text,tooltip:$tooltip}'
  else
    echo "%{F$color}$icon $limitLeft%%{F-} (%{F$weeklyColor}$weeklyLimitLeft%%{F-})"
  fi
}

mkdir -p "$stateDir"

render

while inotifywait -qq -e close_write,create,moved_to "$stateDir"; do
  render
done
