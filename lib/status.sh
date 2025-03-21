#!/bin/bash
#
# status.sh
#
# Shared library for handling status updates across dotfiles scripts

# Status file for prompt integration
DOTFILES_STATUS_FILE="${DOTFILES_STATUS_FILE:-$HOME/.dotfiles_update_status}"

# Log file for debugging
DOTFILES_STATUS_LOG="${DOTFILES_STATUS_LOG:-$HOME/.dotfiles_update.log}"

# Maximum log file size in bytes (1MB)
MAX_LOG_SIZE=1048576

# Function to check and rotate log file if needed
function status_check_log_rotation() {
  # Check if log file exists
  if [ -f "$DOTFILES_STATUS_LOG" ]; then
    # Get file size in bytes
    local file_size=$(stat -f%z "$DOTFILES_STATUS_LOG")

    # If file size exceeds the maximum, rotate the log
    if [ $file_size -gt $MAX_LOG_SIZE ]; then
      # Create a backup with timestamp
      local timestamp=$(date +%Y%m%d%H%M%S)
      local backup_file="${DOTFILES_STATUS_LOG}.${timestamp}"

      # Move the current log to backup
      mv "$DOTFILES_STATUS_LOG" "$backup_file"

      # Create a new empty log file
      touch "$DOTFILES_STATUS_LOG"

      # Keep only the 5 most recent backup files
      ls -t "${DOTFILES_STATUS_LOG}."* 2>/dev/null | tail -n +6 | xargs rm -f 2>/dev/null

      # Log the rotation
      echo "[$(date '+%Y-%m-%d %H:%M:%S')] Log file rotated. Previous log saved as $backup_file" >> "$DOTFILES_STATUS_LOG"
    fi
  fi
}

# Function to log messages
function status_log() {
  # Check if log rotation is needed before logging
  status_check_log_rotation

  echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$DOTFILES_STATUS_LOG"
}

# Function to update the status file
function status_update() {
  local status_type="$1"
  local message="$2"

  # Create or update the status file
  echo "{\"type\":\"$status_type\",\"message\":\"$message\",\"timestamp\":\"$(date '+%Y-%m-%d %H:%M:%S')\"}" > "$DOTFILES_STATUS_FILE"
  status_log "Updated status file: $status_type - $message"
}

# Function to clear the status file
function status_clear() {
  if [ -f "$DOTFILES_STATUS_FILE" ]; then
    rm -f "$DOTFILES_STATUS_FILE"
    status_log "Cleared status file"
  fi
}

# Function to check if a specific status type exists
function status_exists() {
  local status_type="$1"

  if [ -f "$DOTFILES_STATUS_FILE" ] && grep -q "\"type\":\"$status_type\"" "$DOTFILES_STATUS_FILE"; then
    return 0  # Status exists
  else
    return 1  # Status doesn't exist
  fi
}

# Function to get the current status type
function status_get_type() {
  if [ -f "$DOTFILES_STATUS_FILE" ]; then
    cat "$DOTFILES_STATUS_FILE" | jq -r '.type' 2>/dev/null || echo "unknown"
  else
    echo "none"
  fi
}

# Function to get the current status message
function status_get_message() {
  if [ -f "$DOTFILES_STATUS_FILE" ]; then
    cat "$DOTFILES_STATUS_FILE" | jq -r '.message' 2>/dev/null || echo "Unknown status"
  else
    echo "No status"
  fi
}

# Function to get formatted status for prompt
function status_get_prompt() {
  if [ -f "$DOTFILES_STATUS_FILE" ]; then
    local status_type=$(status_get_type)
    local text_indicator=""

    case "$status_type" in
      "dotfiles") text_indicator="%{$fg_bold[yellow]%}[DOTFILES UPDATE]%{$reset_color%}" ;;
      "brew") text_indicator="%{$fg_bold[green]%}[BREW UPDATE]%{$reset_color%}" ;;
      "npm") text_indicator="%{$fg_bold[blue]%}[NPM UPDATE]%{$reset_color%}" ;;
      *) text_indicator="%{$fg_bold[red]%}[SYSTEM UPDATE]%{$reset_color%}" ;;
    esac

    echo "$text_indicator"
  else
    # No updates available - use light gray to make it less prominent
    echo "%{$fg_no_bold[grey]%}[No updates]%{$reset_color%}"
  fi
}

# Function to check when the last update check was performed
function status_last_check() {
  local check_file="${DOTFILES_LAST_CHECK_FILE:-$HOME/.dotfiles_last_check}"

  # If the file doesn't exist, create it with yesterday's date
  if [ ! -f "$check_file" ]; then
    date -v-1d +%Y%m%d > "$check_file"
    status_log "Created new last check file with yesterday's date"
    return 1
  fi

  # Get the last check date
  local last_check=$(cat "$check_file")
  local today=$(date +%Y%m%d)

  # If the last check was today, return 0 (no need to check)
  if [ "$last_check" = "$today" ]; then
    status_log "Already checked today, skipping"
    return 0
  else
    # Update the last check date
    echo "$today" > "$check_file"
    status_log "Last check was on $last_check, updating to $today"
    return 1
  fi
}

# Function to force a check by resetting the last check date
function status_force_check() {
  local check_file="${DOTFILES_LAST_CHECK_FILE:-$HOME/.dotfiles_last_check}"
  rm -f "$check_file"
  status_log "Forced check by removing last check file"
}
