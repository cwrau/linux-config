#!/usr/bin/env bash
# Waybar player-info — ported from polybar player-info using pctl
# Outputs JSON: {"text":"...", "tooltip":"...", "class":"playing|paused|stopped"}

function update() {
  local status artist title position duration text tooltip class

  status=$(pctl status 2>/dev/null || echo "Stopped")
  artist=$(pctl metadata artist 2>/dev/null || echo "")
  title=$(pctl metadata title 2>/dev/null || echo "")
  position=$(pctl position 2>/dev/null || echo "")
  duration=$(pctl metadata mpris:length 2>/dev/null || echo "")

  case "$status" in
    Playing)
      class="playing"
      text="  ${artist:+${artist} - }${title}"
      ;;
    Paused)
      class="paused"
      text="  ${artist:+${artist} - }${title}"
      ;;
    *)
      class="stopped"
      text=""
      ;;
  esac

  # Truncate long text
  if ((${#text} > 60)); then
    text="${text:0:57}..."
  fi

  tooltip="${artist:+${artist}\n}${title}${position:+\n${position}}"

  printf '{"text":"%s","tooltip":"%s","class":"%s"}\n' "$text" "$tooltip" "$class"
}

# Use playerctl to monitor status changes
playerctl -F metadata -f '{{status}}' 2>/dev/null | while read -r _; do
  update
done &

# Initial update
update

# Periodic position updates
while true; do
  sleep 1
  update
done
