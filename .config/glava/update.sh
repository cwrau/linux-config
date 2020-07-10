#!/usr/bin/env bash

set -eu

function update() {
  for GLAVA in $(pactl list short clients | grep glava | cut -f 1)
  do
    FROM=$(pactl list source-outputs short | awk '{if ($3 == "'"$GLAVA"'") print $1;}')
    pactl move-source-output $FROM @DEFAULT_MONITOR@
  done
}

echo

update

LANG=C pactl subscribe | grep "Event 'change' on server" --line-buffered | while read p
do
  update
done
