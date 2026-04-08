# Lazy-load rbenv (~0.1s savings)
if (( $+commands[rbenv] )); then
  export PATH="$HOME/.rbenv/shims:$PATH"
  rbenv() {
    unset -f rbenv
    eval "$(command rbenv init -)"
    rbenv "$@"
  }
fi
