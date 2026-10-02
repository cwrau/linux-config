#!/bin/bash

set -x
set -e
set -o pipefail

stateFile="${STATE_DIRECTORY:-$HOME/.local/state/agent-limit}/usage.json"
if [[ -r "${CREDENTIALS_DIRECTORY}/homeassistant-token" ]]; then
  hasHAToken="true"
fi

usageResponse="$(claude --strict-mcp-config --resume 56e37158-06b4-4856-ba46-74c850b99f2e -p /usage 2>/dev/null)"

if ! response="$(<<<"$usageResponse" rg -S -r '$1|$2' 'current session: (\d+)% used(?: · resets (.*))?$')"; then
  exit 2
fi
IFS='|' read -r limitUsed resets <<<"$response"

weeklyLimitUsed=0
weeklyResets=""
if weeklyResponse="$(<<<"$usageResponse" rg -S -r '$1|$2' 'current week \(all models\): (\d+)% used(?: · resets (.*))?$')"; then
  IFS='|' read -r weeklyLimitUsed weeklyResets <<<"$weeklyResponse"
fi

function roundedResetDateTime() {
  local resetsText="$1"
  local epoch
  epoch="$(date --date="${resetsText/,/}" +%s)"
  epoch=$(((epoch + 150) / 300 * 300))
  date --date="@$epoch" '+%Y-%m-%d %H:%M:%S'
}

if [[ -n "$resets" ]]; then
  resetDateTime="$(roundedResetDateTime "$resets")"
  resetDate="${resetDateTime%% *}"
  resetTime="${resetDateTime#* }"
fi
if [[ -n "$weeklyResets" ]]; then
  weeklyResetDateTime="$(roundedResetDateTime "$weeklyResets")"
  weeklyResetDate="${weeklyResetDateTime%% *}"
  weeklyResetTime="${weeklyResetDateTime#* }"
fi

# push a single attribute via the raw states API, since neither
# input_number/set_value nor input_datetime/set_datetime can set attributes
function patchAttribute() {
  local entityId="$1" haToken="$2" key="$3" jsonValue="$4"
  local currentState
  currentState="$(curl -fsSL -H "Authorization: Bearer $haToken" "https://homeassistant.cwrau.de/api/states/$entityId" 2>/dev/null)"
  jq -cn --arg key "$key" --argjson value "$jsonValue" --argjson current "$currentState" \
    '{state: $current.state, attributes: ($current.attributes + {($key): $value})}' |
    curl -X POST -fsSL --out-null -H "Authorization: Bearer $haToken" -H "Content-Type: application/json" -d @- "https://homeassistant.cwrau.de/api/states/$entityId" 2>/dev/null
}

# input_datetime has no "clear" service, so an absent reset (e.g. no active
# session/week) forces the state to unknown via the raw states API instead,
# preserving the helper's existing config attributes rather than guessing them
function setResetDatetime() {
  local entityId="$1" haToken="$2" date="$3" time="$4"
  if [[ -n "$date" ]]; then
    curl -X POST -fsSL --out-null -H "Authorization: Bearer $haToken" -H "Content-Type: application/json" -d '{"entity_id": "'"$entityId"'", "date": "'"$date"'", "time": "'"$time"'"}' https://homeassistant.cwrau.de/api/services/input_datetime/set_datetime 2>/dev/null
  else
    local currentAttrs
    currentAttrs="$(curl -fsSL -H "Authorization: Bearer $haToken" "https://homeassistant.cwrau.de/api/states/$entityId" 2>/dev/null | jq -c '.attributes | {has_date,has_time,icon,friendly_name,editable}')"
    curl -X POST -fsSL --out-null -H "Authorization: Bearer $haToken" -H "Content-Type: application/json" -d "$(jq -cn --argjson attrs "$currentAttrs" '{state:"unknown",attributes:$attrs}')" "https://homeassistant.cwrau.de/api/states/$entityId" 2>/dev/null
  fi
}

if [[ "$hasHAToken" == true ]]; then
  haToken="$(cat "${CREDENTIALS_DIRECTORY}/homeassistant-token")"

  curl -X POST -fsSL --out-null -H "Authorization: Bearer $haToken" -H "Content-Type: application/json" -d '{"entity_id": "input_number.ai_limit_usage", "value": '"$limitUsed"'}' https://homeassistant.cwrau.de/api/services/input_number/set_value 2>/dev/null
  patchAttribute input_number.ai_limit_usage "$haToken" weekly_limit "$weeklyLimitUsed"
  setResetDatetime input_datetime.ai_limit_reset "$haToken" "${resetDate:-}" "${resetTime:-}"

  curl -X POST -fsSL --out-null -H "Authorization: Bearer $haToken" -H "Content-Type: application/json" -d '{"entity_id": "input_number.ai_weekly_limit_usage", "value": '"$weeklyLimitUsed"'}' https://homeassistant.cwrau.de/api/services/input_number/set_value 2>/dev/null
  setResetDatetime input_datetime.ai_weekly_limit_reset "$haToken" "${weeklyResetDate:-}" "${weeklyResetTime:-}"
fi

jq -cn --argjson limitUsed "$limitUsed" --arg resetDate "${resetDate:-}" --arg resetTime "${resetTime:-}" \
  --argjson weeklyLimitUsed "$weeklyLimitUsed" --arg weeklyResetDate "${weeklyResetDate:-}" --arg weeklyResetTime "${weeklyResetTime:-}" \
  '{
    limitUsed:$limitUsed,
    resetDate:(if $resetDate=="" then null else $resetDate end),
    resetTime:(if $resetTime=="" then null else $resetTime end),
    weeklyLimitUsed:$weeklyLimitUsed,
    weeklyResetDate:(if $weeklyResetDate=="" then null else $weeklyResetDate end),
    weeklyResetTime:(if $weeklyResetTime=="" then null else $weeklyResetTime end)
  }' >"$stateFile.tmp"
mv "$stateFile.tmp" "$stateFile"
