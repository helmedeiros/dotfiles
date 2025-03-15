# Dotfiles update checker
# Checks for updates to the dotfiles repository and dependencies once a day

# Source the shared status library
if [ -f "$HOME/.dotfiles/lib/status.sh" ]; then
  source "$HOME/.dotfiles/lib/status.sh"
fi

# Function to check for dotfiles updates
function check_dotfiles_updates() {
  status_log "Starting dotfiles update check"
  
  # Only check once per day
  if status_last_check; then
    return 0
  fi
  
  # Check for updates
  if [ -x "$HOME/.dotfiles/bin/check-updates" ]; then
    status_log "Running check-updates script"
    
    # Create a temporary file to capture the output
    local temp_output=$(mktemp)
    
    # Run the check-updates script and capture its output
    $HOME/.dotfiles/bin/check-updates > "$temp_output" 2>&1
    local exit_code=$?
    status_log "Finished check-updates script with exit code $exit_code"
    
    # Check if updates are available by looking for specific patterns in the output
    if grep -q "Your dotfiles are behind by" "$temp_output"; then
      # Extract the number of commits behind
      local commits_behind=$(grep "Your dotfiles are behind by" "$temp_output" | sed -E 's/.*behind by ([0-9]+) commit.*/\1/')
      status_update "dotfiles" "Dotfiles updates available ($commits_behind commits)"
    # Check for Homebrew updates - look for the specific pattern from check-updates
    elif grep -q "The following Homebrew packages are outdated" "$temp_output"; then
      # Count the number of outdated packages - improved counting logic
      local outdated_count=$(grep -A 100 "The following Homebrew packages are outdated" "$temp_output" | grep -v "The following" | grep -v "^$" | grep -v "Would you like" | wc -l | tr -d ' ')
      status_update "brew" "Homebrew updates available ($outdated_count packages)"
    elif grep -q "You have outdated global npm packages" "$temp_output"; then
      status_update "npm" "npm updates available"
    else
      # No updates needed, clear the status file
      status_clear
    fi
    
    # Append the output to the log file
    cat "$temp_output" >> "$DOTFILES_STATUS_LOG"
    
    # Clean up
    rm -f "$temp_output"
  else
    status_log "check-updates script not found or not executable"
  fi
}

# Function to manually check for updates
function dotfiles-update-check() {
  echo "Manually checking for dotfiles updates and dependencies..."
  status_log "Manual update check triggered"
  
  # Force check by removing the last check file
  status_force_check
  
  # Run the check
  check_dotfiles_updates
  
  # Show the log
  echo "Update check complete. Log file: $DOTFILES_STATUS_LOG"
  echo "Last 10 log entries:"
  tail -n 10 "$DOTFILES_STATUS_LOG"
  
  # Show status if available
  if [ -f "$DOTFILES_STATUS_FILE" ]; then
    echo ""
    echo "Update status:"
    cat "$DOTFILES_STATUS_FILE" | jq -r '"\(.type): \(.message)"'
  fi
}

# Function to check if updates are available (for use in prompt)
function dotfiles_update_status() {
  status_get_prompt
}

# Function to apply updates and clear the status
function dotfiles-apply-updates() {
  if [ -f "$DOTFILES_STATUS_FILE" ]; then
    echo "Applying pending updates..."
    $HOME/.dotfiles/bin/dot
    status_clear
    echo "Updates applied and status cleared."
  else
    echo "No pending updates found."
  fi
}

# Function to clean up old log files
function dotfiles-cleanup-logs() {
  echo "Cleaning up dotfiles log files..."
  
  # Remove all but the 5 most recent log backups
  local backup_count=$(ls -1 "${DOTFILES_STATUS_LOG}."* 2>/dev/null | wc -l)
  if [ $backup_count -gt 5 ]; then
    echo "Removing old log backups..."
    ls -t "${DOTFILES_STATUS_LOG}."* | tail -n +6 | xargs rm -f
    echo "Kept the 5 most recent log backups."
  else
    echo "No cleanup needed. Found $backup_count log backups."
  fi
  
  # Rotate current log if it's too large
  status_check_log_rotation
  
  echo "Log cleanup complete."
}

# Function to manually clear the update status
function dotfiles-clear-status() {
  echo "Manually clearing dotfiles update status..."
  status_clear
  echo "Status cleared. The prompt will show [No updates] in the next shell session."
}

# Run the update check when a new shell is started
# This is done in the background to avoid slowing down shell startup
status_log "Shell started, triggering background update check"
(check_dotfiles_updates &) >/dev/null 2>&1 