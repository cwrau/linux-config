#!/bin/bash

name=${1}

if systemctl --user -q is-active "${name}"; then
  systemctl --user stop "${name}"
else
  systemctl --user start "${name}"
fi
