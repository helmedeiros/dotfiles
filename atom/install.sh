#!/bin/sh
#
# Atom
set -e

declare -r -i installed=$(apm list -i| awk -F '[()]' '{print $2}')

# Update ATOM Packages
if [[ $(which apm) && $installed > 0 ]]
then
  echo "  Configuring Atom Packages."
  apm stars
  apm star --installed
  apm stars --install
else
  echo "  Create Atom Packages Token."
  apm login
fi
