#!/bin/bash

if systemctl --user -q is-active foldingathome; then
  systemctl --user stop foldingathome
else
  systemctl --user start foldingathome
fi
