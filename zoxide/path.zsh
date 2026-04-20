# zoxide - smarter cd with fuzzy directory jumping
# NOTE: zoxide init is at the end of zshrc (must be last per zoxide docs)
if command -v zoxide > /dev/null 2>&1; then
  export _ZO_DOCTOR=0
  alias cd='z'
fi
