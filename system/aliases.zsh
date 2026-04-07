# Prefer eza (modern ls) when available, fall back to gls (GNU coreutils).
if command -v eza > /dev/null 2>&1; then
  alias ls="eza --icons=always --group-directories-first"
  alias l="eza -lah --icons=always --group-directories-first"
  alias ll="eza -l --icons=always --group-directories-first"
  alias la="eza -a --icons=always --group-directories-first"
elif $(gls &>/dev/null)
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