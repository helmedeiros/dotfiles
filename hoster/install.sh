#!/usr/bin/env bash
#
# Hoster configuration and install.
set -e

if [[ ":$PATH:" != *"/hoster"* ]]
then
  git clone https://github.com/helmedeiros/hoster ~/.hoster
  chmod +x ~/.hoster/hoster
fi
