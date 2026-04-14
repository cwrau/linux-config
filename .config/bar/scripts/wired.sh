#!/usr/bin/env bash
# Waybar wired network — shows wired + USB network status
# Outputs JSON: {"text":"...", "class":"connected|disconnected"}

wired_ip=$(ip -4 addr show scope global dev eth0 2>/dev/null | grep -oP 'inet \K[\d.]+' | head -1)
usb_ip=$(ip -4 addr show scope global dev usb0 2>/dev/null | grep -oP 'inet \K[\d.]+' | head -1)

text=""
[[ -n "$wired_ip" ]] && text+=" ${wired_ip}"
[[ -n "$usb_ip" ]] && text+="  ${usb_ip}"

if [[ -n "$text" ]]; then
  printf '{"text":"%s","class":"connected"}\n' "$text"
else
  printf '{"text":"","class":"disconnected"}\n'
fi
