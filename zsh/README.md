# ZSH Configuration

This directory contains ZSH-specific configuration files and features.

## Update Status Indicator

The prompt includes an update status indicator that shows when updates are available for your dotfiles or dependencies. The indicator appears in your prompt when updates are detected.

### Indicators

The following indicators may appear in your prompt:

- **[DOTFILES UPDATE]** - Dotfiles updates are available
- **[BREW UPDATE]** - Homebrew package updates are available
- **[NPM UPDATE]** - npm global package updates are available
- **[SYSTEM UPDATE]** - Other updates are available
- **[No updates]** - No updates are available

Each indicator is color-coded for better visibility:
- Dotfiles updates: Yellow
- Brew updates: Green
- NPM updates: Blue
- System updates: Red
- No updates: Light gray (less prominent)

### Commands

- `dotfiles-update-check` - Manually check for updates and show the status
- `dotfiles-apply-updates` - Apply pending updates and clear the status
- `dotfiles-cleanup-logs` - Clean up old log files and rotate logs if needed

### How It Works

1. The update checker runs once per day when you open a new shell
2. It checks for updates to your dotfiles repository and dependencies
3. If updates are found, it creates a status file with details
4. The prompt reads this status file and displays the appropriate indicator
5. After updates are applied, the status is cleared

### Configuration

The update checker is configured in `zsh/update.zsh` and the prompt integration is in `zsh/prompt.zsh`. You can customize the indicators or behavior by editing these files.

### Logs

Logs are stored in `~/.dotfiles_update.log` for troubleshooting. The log system includes:

- Automatic log rotation when the file exceeds 1MB
- Retention of the 5 most recent log backups
- Timestamped log entries for easy tracking
- Log cleanup command to manage disk space

Log backups are stored as `~/.dotfiles_update.log.TIMESTAMP` where TIMESTAMP is the date and time of rotation. 