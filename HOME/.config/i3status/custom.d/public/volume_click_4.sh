#!/bin/bash

pactl set-sink-volume @DEFAULT_SINK@ +5%
pactl set-sink-mute @DEFAULT_SINK@ false #increase sound volume
