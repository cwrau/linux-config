#!/usr/bin/env bash

type=${1:?Must provide type: bar/radial}

set -exu

systemctl --user stop glava-$type.slice
