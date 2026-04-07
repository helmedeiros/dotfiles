# zoxide - smarter cd with fuzzy directory jumping
if command -v zoxide > /dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi
