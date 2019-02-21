#!/bin/sh
xrandr --output HDMI2 --off --output HDMI1 --primary --mode ${1}x1080 --pos 0x0 --rotate normal --output DP1 --off --output eDP1 --mode 1920x1080 --pos ${1}x0 --rotate normal --output DP2 --off
