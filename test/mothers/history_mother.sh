#!/bin/bash
#
# history_mother.sh
#
# Object Mother for history-related test fixtures

# Create a test zsh history file with sample entries
# Zsh history format: : <timestamp>:<duration>;<command>
a_zsh_history_file() {
  local history_file="$1"

  cat > "$history_file" <<'EOF'
: 1609459200:0;ls -la
: 1609459210:0;cd Documents
: 1609459220:0;git status
: 1609459230:0;echo "hello world"
: 1609459240:0;npm install
: 1609459250:0;export SECRET_PASSWORD=secret123
: 1609459260:0;docker ps
: 1609459270:0;kubectl get pods
: 1609459280:0;vim config.yaml
: 1609459290:0;make build
EOF
}

# Create a zsh history file with sensitive data
a_zsh_history_with_secrets() {
  local history_file="$1"

  cat > "$history_file" <<'EOF'
: 1609459200:0;ls -la
: 1609459210:0;export API_KEY=abc123def456
: 1609459220:0;git commit -m "update"
: 1609459230:0;curl -H "Authorization: Bearer token123" api.example.com
: 1609459240:0;mysql -u root -p password123
: 1609459250:0;echo "normal command"
: 1609459260:0;ssh user@server.com
: 1609459270:0;export DATABASE_PASSWORD=dbpass456
: 1609459280:0;vim file.txt
: 1609459290:0;docker login -u user -p dockerpass789
EOF
}

# Create an empty zsh history file
an_empty_zsh_history() {
  local history_file="$1"
  touch "$history_file"
}

# Create a zsh history file with special characters
a_zsh_history_with_special_characters() {
  local history_file="$1"

  cat > "$history_file" <<'EOF'
: 1609459200:0;echo "hello world"
: 1609459210:0;grep -r "pattern.*" /path
: 1609459220:0;sed 's/old/new/g' file.txt
: 1609459230:0;find . -name "*.log" -delete
: 1609459240:0;echo $PATH | tr ':' '\n'
: 1609459250:0;awk '{print $1}' data.csv
: 1609459260:0;echo "Special: !@#$%^&*()"
: 1609459270:0;test -f /path/to/file && echo "exists"
: 1609459280:0;curl "https://api.com?param=value&other=123"
: 1609459290:0;git log --pretty=format:"%h - %an, %ar : %s"
EOF
}

# Create a zsh history file with Unicode characters
a_zsh_history_with_unicode() {
  local history_file="$1"

  cat > "$history_file" <<'EOF'
: 1609459200:0;echo "Hello 世界"
: 1609459210:0;echo "Привет мир"
: 1609459220:0;echo "مرحبا العالم"
: 1609459230:0;echo "🎉 Emoji test 🚀"
: 1609459240:0;ls -la
: 1609459250:0;echo "Café naïve résumé"
: 1609459260:0;git commit -m "日本語コミット"
: 1609459270:0;echo "Greek: α β γ δ"
: 1609459280:0;echo "Math: ∑ ∫ ∂ √"
: 1609459290:0;vim file.txt
EOF
}

# Create a large zsh history file for performance testing
a_large_zsh_history() {
  local history_file="$1"
  local num_entries="${2:-100}"

  : > "$history_file"  # Clear file

  for i in $(seq 1 "$num_entries"); do
    echo ": 160945$(printf "%04d" "$i"):0;echo 'Command number $i'" >> "$history_file"
  done
}

# Count lines in a history file
count_history_lines() {
  local history_file="$1"
  wc -l < "$history_file" | tr -d ' '
}

# Verify a backup file exists
verify_backup_exists() {
  local history_file="$1"
  local backup_pattern="${history_file}.bak.*"

  # Check if any backup files exist
  if ls ${backup_pattern} 1> /dev/null 2>&1; then
    return 0
  else
    return 1
  fi
}

# Get the most recent backup file
get_latest_backup() {
  local history_file="$1"
  ls -t "${history_file}.bak."* 2>/dev/null | head -n 1
}

# Create a zsh history file with duplicate commands
a_zsh_history_with_duplicates() {
  local history_file="$1"

  cat > "$history_file" <<'EOF'
: 1609459200:0;ls -la
: 1609459210:0;git status
: 1609459220:0;ls -la
: 1609459230:0;echo "test"
: 1609459240:0;git status
: 1609459250:0;ls -la
: 1609459260:0;docker ps
: 1609459270:0;git status
: 1609459280:0;vim file.txt
: 1609459290:0;ls -la
EOF
}

# Create a minimal valid zsh history
a_minimal_zsh_history() {
  local history_file="$1"

  cat > "$history_file" <<'EOF'
: 1609459200:0;echo "first"
: 1609459210:0;echo "second"
: 1609459220:0;echo "third"
EOF
}

# Setup HISTFILE environment for tests
setup_test_histfile() {
  local test_dir="$1"
  local history_file="${test_dir}/.zsh_history"

  export HISTFILE="$history_file"
  export ZDOTDIR="$test_dir"

  echo "$history_file"
}

# Clean up history-related test environment
cleanup_test_histfile() {
  unset HISTFILE
  unset ZDOTDIR
}
