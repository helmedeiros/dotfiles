#!/bin/sh
#
if test ! $(which zsh)
then
 curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh

 cd /usr/local/share/
 sudo chmod -R 755 zsh
 sudo chown -R root:staff zsh

 chsh -s /bin/zsh
fi
