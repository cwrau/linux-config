#!/usr/bin/env bash

DIR=/tmp/polybar/updates
mkdir -p $DIR

UPDATES=$(checkupdates 2>/dev/null | wc -l)

if (( UPDATES == 1 ))
then
  echo " $UPDATES"
elif (( UPDATES > 1 ))
then
  echo " $UPDATES"
else
  echo
fi

echo $UPDATES > $DIR/count
