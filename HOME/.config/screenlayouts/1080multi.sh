#!/bin/sh
xrandr --output HDMI-2 --off --output HDMI-1 --primary --mode ${1}x1080 --pos 0x0 --rotate normal --output DP-1 --off --output eDP-1 --mode 1920x1080 --pos ${1}x0 --rotate normal --output DP-2 --off
