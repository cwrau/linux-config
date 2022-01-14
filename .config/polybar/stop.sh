#!/usr/bin/env sh

location=${1:?Must provice location: top/bottom}

set -exu

systemctl --user stop polybar-$location.slice
