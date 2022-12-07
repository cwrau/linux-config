#!/usr/bin/env bash

set -exu

function update() {
  for glavaId in $(pactl list clients short | grep glava | cut -f 1); do
    glavaOutputId=$(pactl list source-outputs short | awk '{if ($3 == "'"$glavaId"'") print $1;}')
    echo "Moving $glavaOutputId to @DEFAULT_MONITOR@"
    pactl move-source-output $glavaOutputId @DEFAULT_MONITOR@
    pactl set-source-output-volume $glavaOutputId 75% 75%
  done

  pkill -0 -x glava
}

sleep 5

update

LANG=C pactl subscribe | grep "Event 'change' on server" --line-buffered | while read p; do
  update
  update
done
