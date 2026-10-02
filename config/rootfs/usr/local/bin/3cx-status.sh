#!/usr/bin/env bash
set -euo pipefail

STATUS="${1:?Usage: 3cx-status.sh <Available|Home Office>}"

ENDPOINT="https://3cx.teuto.net/MyPhone/MPWebService.asmx"
LOGIN_URL="https://3cx.teuto.net/webclient/api/Login/GetAccessToken"
REFRESH_URL="https://3cx.teuto.net/connect/token"
SESSION_URL="https://3cx.teuto.net/webclient/api/MyPhone/session"
USERNAME="cwr@teuto.net"

CRED_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/credstore.encrypted"
PASSWORD=$(systemd-creds --user --name=3cx-password decrypt "${CRED_DIR}/3cx-password")
TOTP_SECRET=$(systemd-creds --user --name=3cx-2fa-secret decrypt "${CRED_DIR}/3cx-2fa-secret")

CACHE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}"
TOKEN_FILE="${CACHE_DIR}/3cx-status-token"
TOKEN_REFRESH_FILE="${CACHE_DIR}/3cx-status-refresh-token"
SESSION_KEY_FILE="${CACHE_DIR}/3cx-status-session-key"

case "$STATUS" in
  "Available")    STATUS_BYTE="d1" ;;
  "Home Office")  STATUS_BYTE="d0" ;;
  *)
    echo "ERROR: unknown status '$STATUS'" >&2
    exit 1
    ;;
esac

generate_totp() {
  python3 -c "
import base64, hmac, hashlib, struct, time
secret = base64.b32decode('${TOTP_SECRET}')
counter = int(time.time()) // 30
msg = struct.pack('>Q', counter)
h = hmac.new(secret, msg, hashlib.sha1).digest()
offset = h[-1] & 0x0f
code = struct.unpack('>I', h[offset:offset+4])[0] & 0x7fffffff
print(str(code % 1000000).zfill(6), end='')
"
}

do_login() {
  local totp
  totp=$(generate_totp)

  local response
  response=$(curl -sf -X POST "$LOGIN_URL" \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    -d "{\"SecurityCode\":\"${totp}\",\"Password\":\"${PASSWORD}\",\"Username\":\"${USERNAME}\"}")

  echo "$response" | jq -r '.Token.access_token'  > "$TOKEN_FILE"
  echo "$response" | jq -r '.Token.refresh_token' > "$TOKEN_REFRESH_FILE"
  echo "[$(date '+%H:%M:%S')] 3CX login"
}

do_refresh() {
  [[ -f "$TOKEN_REFRESH_FILE" ]] || return 1

  local response
  if ! response=$(curl -sf -X POST "$REFRESH_URL" \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -d "grant_type=refresh_token&refresh_token=$(cat "$TOKEN_REFRESH_FILE")"); then
    return 1
  fi

  echo "$response" | jq -r '.access_token'  > "$TOKEN_FILE"
  echo "$response" | jq -r '.refresh_token' > "$TOKEN_REFRESH_FILE"
  echo "[$(date '+%H:%M:%S')] 3CX token refreshed"
  return 0
}

mint_session() {
  local token response
  token=$(cat "$TOKEN_FILE")

  response=$(curl -sf -X POST "$SESSION_URL" \
    -H "Authorization: Bearer ${token}" \
    -H 'Content-Type: application/json' \
    -H 'Accept: application/json' \
    -d '{"name":"Webclient","version":"20.0.9.0","isHuman":true}') || return 1

  echo "$response" | jq -r '.sessionKey' > "$SESSION_KEY_FILE"
}

try_status() {
  local session_key
  session_key=$(cat "$SESSION_KEY_FILE")

  local http_code
  http_code=$(curl -s -o /dev/null -w '%{http_code}' -X POST "$ENDPOINT" \
    -H 'accept: application/octet-stream' \
    -H 'content-type: application/octet-stream' \
    -H "myphonesession: ${session_key}" \
    -H 'ngsw-bypass: bypass' \
    --data-binary "$(printf '\x08g\xba\x06\x03\x08\x'"${STATUS_BYTE}"'\x02')")

  if [[ "$http_code" == "200" ]]; then
    echo "[$(date '+%H:%M:%S')] 3CX status -> $STATUS"
    return 0
  fi
  return 1
}

# Access tokens are single-use. Always refresh, fall back to login.
# The myphonesession header needs a session GUID minted via SESSION_URL,
# not the raw access_token -- MPWebService silently no-ops on the latter.
if do_refresh && mint_session && try_status; then
  exit 0
fi

do_login
mint_session
try_status