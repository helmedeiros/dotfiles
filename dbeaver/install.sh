#!/usr/bin/env bash
#
# dbeaver-community configuration and install.
source $(dirname $0)/../secrets/dots.sh

set -e

function move_dbeaver_connections_from() {
  mv ~/.dbeaver4/General/.dbeaver-data-sources.xml  ~/.dbeaver4/General/.dbeaver-data-sources.xml.original
  cp $1/dbeaver/dbeaver-data-sources.xml ~/.dbeaver4/General/.dbeaver-data-sources.xml
}

if test ! $(pgrep -f "DBeaver")
then
  open "/Applications/DBeaver.app"
fi

setup_secret_dotfiles;

move_dbeaver_connections_from "$HOME/.dot-secrets";
