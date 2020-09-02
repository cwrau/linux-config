#!/usr/bin/env bash

set -ex -o pipefail

function getResolutionForMonitor() {
  xrandr | awk -v "monitor=^$1 connected" '/connected/ {p = 0}
    $0 ~ monitor {p = 1}
    p' | grep -v connected | grep 1080 | sed -r 's#^.*\s([0-9]+x[0-9]+).+#\1#g' | sort -d | tail -1
}

monitors=( $(xrandr | grep ' connected ' | sed -r 's#^([^ ]+).*$#\1#g' | tac) )

xrandr --output ${monitors[0]} --primary --mode $(getResolutionForMonitor ${monitors[0]})

for monitor in ${monitors[@]:1}
do
  xrandr --output ${monitor} --mode $(getResolutionForMonitor ${monitor})
done

systemctl --user start feh.service --wait
