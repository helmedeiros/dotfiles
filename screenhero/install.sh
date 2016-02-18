#!/bin/sh
if test ! $(pgrep -f "screenhero")
then
  open "/Applications/screenhero.app"
fi
