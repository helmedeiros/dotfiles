#!/bin/sh
#
if test ! $(which zsh)
then
 curl -L https://github.com/robbyrussell/oh-my-zsh/raw/master/tools/install.sh | sh
 chsh -s /bin/zsh
fi
