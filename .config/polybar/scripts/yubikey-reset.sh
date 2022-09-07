#!/bin/bash

while :; do
  current_time=$(date +%s.%N)
  next_time=$(date -d "+ 10 seconds" +%s.%N)
  target_time=$(date -d @"$( echo "$next_time - ($next_time % 10 )" | bc)" +%s.%N)

  sleep_seconds=$(echo "$target_time - $current_time" | bc)

  sleep "$sleep_seconds"

  if rg '^#' /etc/udev/rules.d/20-yubikey.rules &> /dev/null; then
    sudo sed -i -r 's/^#//g' /etc/udev/rules.d/20-yubikey.rules
    sudo udevadm control --reload-rules
  fi
done