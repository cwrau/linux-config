#!/bin/bash

if systemctl --user -q is-active docker-db; then
  systemctl --user stop docker-db
else
  systemctl --user start docker-db
fi
