#!/bin/zsh
#
# KCC (Kindle Comic Converter) PATH configuration
# This ensures kcc-c2e and kcc-c2p wrapper scripts are accessible
#

# Add ~/.local/bin to PATH for KCC CLI tools
if [ -d "$HOME/.local/bin" ]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# Add Calibre CLI tools to PATH if installed
if [ -d "/Applications/calibre.app/Contents/MacOS" ]; then
    export PATH="/Applications/calibre.app/Contents/MacOS:$PATH"
fi
