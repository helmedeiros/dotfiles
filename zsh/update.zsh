# Dotfiles update checker
# Checks for updates to the dotfiles repository and dependencies once a day

# Log file for debugging
DOTFILES_UPDATE_LOG="$HOME/.dotfiles_update.log"

# Function to log messages
function _dotfiles_log() {
  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$DOTFILES_UPDATE_LOG"
}

# Function to check when the last update check was performed
function _dotfiles_last_check() {
  local check_file="$HOME/.dotfiles_last_check"
  
  # If the file doesn't exist, create it with yesterday's date
  if [ ! -f "$check_file" ]; then
    date -j -v-1d +%Y%m%d > "$check_file"
    _dotfiles_log "Created new last check file with yesterday's date"
    return 1
  fi
  
  # Get the last check date
  local last_check=$(cat "$check_file")
  local today=$(date +%Y%m%d)
  
  # If the last check was today, return 0 (no need to check)
  if [ "$last_check" = "$today" ]; then
    _dotfiles_log "Already checked today, skipping"
    return 0
  else
    # Update the last check date
    echo "$today" > "$check_file"
    _dotfiles_log "Last check was on $last_check, updating to $today"
    return 1
  fi
}

# Function to check for dotfiles updates
function check_dotfiles_updates() {
  _dotfiles_log "Starting dotfiles update check"
  
  # Only check once per day
  if _dotfiles_last_check; then
    return 0
  fi
  
  # Check for updates
  if [ -x "$HOME/.dotfiles/bin/check-updates" ]; then
    _dotfiles_log "Running check-updates script"
    $HOME/.dotfiles/bin/check-updates >> "$DOTFILES_UPDATE_LOG" 2>&1
    _dotfiles_log "Finished check-updates script with exit code $?"
  else
    _dotfiles_log "check-updates script not found or not executable"
  fi
}

# Function to manually check for updates
function dotfiles-update-check() {
  echo "Manually checking for dotfiles updates and dependencies..."
  _dotfiles_log "Manual update check triggered"
  
  # Force check by removing the last check file
  rm -f "$HOME/.dotfiles_last_check"
  
  # Run the check
  check_dotfiles_updates
  
  # Show the log
  echo "Update check complete. Log file: $DOTFILES_UPDATE_LOG"
  echo "Last 10 log entries:"
  tail -n 10 "$DOTFILES_UPDATE_LOG"
}

# Run the update check when a new shell is started
# This is done in the background to avoid slowing down shell startup
_dotfiles_log "Shell started, triggering background update check"
(check_dotfiles_updates &) >/dev/null 2>&1 