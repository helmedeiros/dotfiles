# Use dynamic path instead of hardcoded user path
if [ -d "$HOME/.tracer" ]; then
  export TRACER_HOME="$HOME/.tracer"
  export PATH="$TRACER_HOME:$PATH"

  # Add completion path if it exists
  if [ -d "$TRACER_HOME/completion/zsh" ]; then
    fpath=($TRACER_HOME/completion/zsh $fpath)
  fi
fi
