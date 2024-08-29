#!/usr/bin/env bash

set -exu
set -o pipefail

function update() {
  systemd-notify --reloading

  for glavaId in $(pactl list clients short | grep glava | cut -f 1); do
    glavaOutputId=$(pactl list source-outputs short | awk '{if ($3 == "'"$glavaId"'") print $1;}')
    pactl move-source-output "$glavaOutputId" @DEFAULT_MONITOR@
    pactl set-source-output-volume "$glavaOutputId" 75% 75%
  done

  systemd-notify --ready
}

trap 'systemd-notify --stopping' EXIT

systemd-notify --status="Waiting for glava..."

sleep 5

systemd-notify --ready
trap update SIGHUP

update

systemd-notify --status="Waiting for events..."
LANG=C pactl subscribe | grep "Event 'change' on server" --line-buffered | while read -r _; do
  sleep 1
  update
  systemd-notify --status="Waiting for events..."
done
