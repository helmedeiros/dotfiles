# grc overides for ls
#   Made possible through contributions from generous benefactors like
#   `brew install coreutils`
if $(gls &>/dev/null)
then
  alias ls="gls -F --color"
  alias l="gls -lAh --color"
  alias ll="gls -l --color"
  alias la='gls -A --color'
fi

# Prefer ripgrep for interactive grep usage (faster, smarter defaults).
# Scripts using piped grep are unaffected since aliases don't apply in scripts.
if command -v rg > /dev/null 2>&1; then
  alias grep='rg'
  alias fgrep='rg -F'
  alias egrep='rg'
else
  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# Google Chrome
alias chrome='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome'

# Flush Directory Service cache
alias flush="dscacheutil -flushcache && killall -HUP mDNSResponder"

# Lock the screen (when going AFK)
alias afk="pmset displaysleepnow"