# zoxide - smarter cd with fuzzy directory jumping
# NOTE: zoxide init is at the end of zshrc (must be last per zoxide docs)
# Only load in interactive shells — non-interactive shells lack chpwd_functions
# support, causing spurious doctor warnings.
if command -v zoxide > /dev/null 2>&1 && [[ -o interactive ]]; then
  export _ZO_DOCTOR=0
  alias cd='z'
fi
