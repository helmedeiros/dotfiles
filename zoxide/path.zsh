# zoxide - smarter cd with fuzzy directory jumping
# _ZO_DOCTOR=0 suppresses a false-positive warning that fires when compinit
# is called after zoxide init (e.g. by Docker Desktop appending to zshrc).
# This is the zoxide-documented fix and is load-order-independent.
export _ZO_DOCTOR=0
if command -v zoxide > /dev/null 2>&1; then
  eval "$(zoxide init zsh)"
  alias cd='z'
fi
