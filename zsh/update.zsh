# Dotfiles update checker
# Checks for updates to the dotfiles repository once a day

# Function to check when the last update check was performed
function _dotfiles_last_check() {
  local check_file="$HOME/.dotfiles_last_check"
  
  # If the file doesn't exist, create it with yesterday's date
  if [ ! -f "$check_file" ]; then
    date -j -v-1d +%Y%m%d > "$check_file"
    return 1
  fi
  
  # Get the last check date
  local last_check=$(cat "$check_file")
  local today=$(date +%Y%m%d)
  
  # If the last check was today, return 0 (no need to check)
  if [ "$last_check" = "$today" ]; then
    return 0
  else
    # Update the last check date
    echo "$today" > "$check_file"
    return 1
  fi
}

# Function to check for dotfiles updates
function check_dotfiles_updates() {
  # Only check once per day
  if _dotfiles_last_check; then
    return 0
  fi
  
  # Check for updates
  if [ -x "$HOME/.dotfiles/bin/check-updates" ]; then
    echo "Checking for dotfiles updates..."
    $HOME/.dotfiles/bin/check-updates
  fi
}

# Run the update check when a new shell is started
# This is done in the background to avoid slowing down shell startup
(check_dotfiles_updates &) >/dev/null 2>&1 