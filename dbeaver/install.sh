#!/usr/bin/env bash
#
# dbeaver-community configuration and install.
source $(dirname $0)/../secrets/dots.sh

set -e

function move_dbeaver_connections_from() {
  local -r dbeaver="~/.dbeaver4"

  if [[ -d "${dbeaver}" || -L "${dbeaver}" ]]; then
    if [ -f ~/.dbeaver4/General/.dbeaver-data-sources.xml ]; then
      mv ~/.dbeaver4/General/.dbeaver-data-sources.xml  ~/.dbeaver4/General/.dbeaver-data-sources.xml.original
    fi

    cp $1/dbeaver/dbeaver-data-sources.xml ~/.dbeaver4/General/.dbeaver-data-sources.xml
  fi
}

setup_secret_dotfiles;

move_dbeaver_connections_from "$HOME/.dot-secrets";

if test ! $(pgrep -f "DBeaver")
then
  open "/Applications/DBeaver.app"
fi
