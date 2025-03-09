# Dotfiles update checker
# Checks for updates to the dotfiles repository and dependencies once a day

# Log file for debugging
DOTFILES_UPDATE_LOG="$HOME/.dotfiles_update.log"

# Status file for prompt integration
DOTFILES_UPDATE_STATUS="$HOME/.dotfiles_update_status"

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

# Function to update the status file for prompt integration
function _update_status_file() {
  local status_type="$1"
  local message="$2"
  
  # Create or update the status file
  echo "{\"type\":\"$status_type\",\"message\":\"$message\",\"timestamp\":\"$(date '+%Y-%m-%d %H:%M:%S')\"}" > "$DOTFILES_UPDATE_STATUS"
  _dotfiles_log "Updated status file: $status_type - $message"
}

# Function to clear the status file
function _clear_status_file() {
  if [ -f "$DOTFILES_UPDATE_STATUS" ]; then
    rm -f "$DOTFILES_UPDATE_STATUS"
    _dotfiles_log "Cleared status file"
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
    
    # Create a temporary file to capture the output
    local temp_output=$(mktemp)
    
    # Run the check-updates script and capture its output
    $HOME/.dotfiles/bin/check-updates > "$temp_output" 2>&1
    local exit_code=$?
    _dotfiles_log "Finished check-updates script with exit code $exit_code"
    
    # Check if updates are available by looking for specific patterns in the output
    if grep -q "Your dotfiles are behind by" "$temp_output"; then
      # Extract the number of commits behind
      local commits_behind=$(grep "Your dotfiles are behind by" "$temp_output" | sed -E 's/.*behind by ([0-9]+) commit.*/\1/')
      _update_status_file "dotfiles" "Dotfiles updates available ($commits_behind commits)"
    elif grep -q "The following Homebrew packages are outdated" "$temp_output"; then
      # Count the number of outdated packages
      local outdated_count=$(grep -A 100 "The following Homebrew packages are outdated" "$temp_output" | grep -v "The following" | grep -v "^$" | grep -v "Would you like" | wc -l | tr -d ' ')
      _update_status_file "brew" "Homebrew updates available ($outdated_count packages)"
    elif grep -q "You have outdated global npm packages" "$temp_output"; then
      _update_status_file "npm" "npm updates available"
    else
      # No updates needed, clear the status file
      _clear_status_file
    fi
    
    # Append the output to the log file
    cat "$temp_output" >> "$DOTFILES_UPDATE_LOG"
    
    # Clean up
    rm -f "$temp_output"
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
  
  # Show status if available
  if [ -f "$DOTFILES_UPDATE_STATUS" ]; then
    echo ""
    echo "Update status:"
    cat "$DOTFILES_UPDATE_STATUS" | jq -r '"\(.type): \(.message)"'
  fi
}

# Function to check if updates are available (for use in prompt)
function dotfiles_update_status() {
  if [ -f "$DOTFILES_UPDATE_STATUS" ]; then
    local status_type=$(cat "$DOTFILES_UPDATE_STATUS" | jq -r '.type')
    local text_indicator=""
    
    case "$status_type" in
      "dotfiles") text_indicator="%{$fg_bold[yellow]%}[DOTFILES UPDATE]%{$reset_color%}" ;; 
      "brew") text_indicator="%{$fg_bold[green]%}[BREW UPDATE]%{$reset_color%}" ;; 
      "npm") text_indicator="%{$fg_bold[blue]%}[NPM UPDATE]%{$reset_color%}" ;; 
      *) text_indicator="%{$fg_bold[red]%}[SYSTEM UPDATE]%{$reset_color%}" ;; 
    esac
    
    echo "$text_indicator"
  else
    # No updates available
    echo "%{$fg[green]%}[No updates]%{$reset_color%}"
  fi
}

# Function to apply updates and clear the status
function dotfiles-apply-updates() {
  if [ -f "$DOTFILES_UPDATE_STATUS" ]; then
    echo "Applying pending updates..."
    $HOME/.dotfiles/bin/dot
    _clear_status_file
    echo "Updates applied and status cleared."
  else
    echo "No pending updates found."
  fi
}

# Run the update check when a new shell is started
# This is done in the background to avoid slowing down shell startup
_dotfiles_log "Shell started, triggering background update check"
(check_dotfiles_updates &) >/dev/null 2>&1 