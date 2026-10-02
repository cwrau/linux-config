#!/bin/bash
# Generate waybar config into $XDG_RUNTIME_DIR (not the source dir) to avoid
# triggering the restart-service path unit on startup.
# Top bar: 2.5%, Bottom bar: 2% of the tallest active monitor height.

src="$(dirname "$0")/config.jsonc"
out="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/waybar.jsonc"

height=$(wlr-randr 2>/dev/null | awk '/current/{found=1} found && /px/{match($0,/[0-9]+x([0-9]+)/,a); print a[1]; found=0}' | sort -n | tail -1)

if [[ -z "$height" || "$height" -eq 0 ]]; then
  echo "generate-config.sh: could not determine monitor height, using fallback" >&2
  cp "$src" "$out"
  exit 0
fi

top_height=$(( height * 25 / 1000 ))
bot_height=$(( height * 20 / 1000 ))

sed \
  -e "s/\"height\": [0-9]*, \/\/ __TOP_HEIGHT__/\"height\": $top_height, \/\/ __TOP_HEIGHT__/" \
  -e "s/\"height\": [0-9]*, \/\/ __BOT_HEIGHT__/\"height\": $bot_height, \/\/ __BOT_HEIGHT__/" \
  "$src" > "$out"
