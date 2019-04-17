#!/bin/bash

orders="$(curl --silent https://ultimatehackingkeyboard.com/delivery-estimator/orders.js | cut -c 18- | sed 's#;$##g')"
lastBatch="$(echo -ne "$orders" | jq -r 'max_by(.batch) | .batch')"
myBatch="$(echo -ne "$orders" | jq -r '.[] | select(.orderId == "#2096") | .batch')"

if [[ "$myBatch" == "null" ]]
then
  echo "TBD"
  echo "$color_bad"
elif [[ "$myBatch" == "$lastBatch" ]]
then
  echo "In production"
  echo "$color_degraded"
  echo "It's in production!!!"
else
  echo "Shipping!"
  echo "$color_good"
  echo "It's finally shipping!!!"
fi
