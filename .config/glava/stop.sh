#!/usr/bin/env bash

type=${1:?Must provide type: bar/radial}

set -exu

systemctl --user reset-failed glava-$type.slice
systemctl --user stop glava-$type.slice
