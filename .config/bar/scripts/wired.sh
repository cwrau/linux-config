#!/usr/bin/env bash
# Waybar wired network — shows wired + USB network status
# Outputs JSON: {"text":"...", "class":"connected|disconnected"}

wired_icon=$'\uf6ff'

get_ip() {
  local iface
  for iface in $(ip -br link show | awk '{print $1}' | grep -E "$1"); do
    local ip
    ip=$(ip -4 addr show scope global dev "$iface" 2>/dev/null | grep -oP 'inet \K[\d.]+' | head -1)
    [[ -n "$ip" ]] && echo "$ip" && return
  done
}

# All wired ethernet (PCI and USB-docked), excluding WiFi
wired_ip=$(get_ip '^en')

text=""
[[ -n "$wired_ip" ]] && text+="${wired_icon} ${wired_ip}"

if [[ -n "$text" ]]; then
  printf '{"text":"%s","class":"connected"}\n' "$text"
else
  printf '{"text":"","class":"disconnected"}\n'
fi
