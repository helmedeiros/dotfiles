#!/bin/bash

# Install aider using Homebrew
echo "Installing aider..."
brew install aider

# Verify installation
if command -v aider &> /dev/null; then
    echo "✅ aider installed successfully"
    echo "Version: $(aider --version)"
else
    echo "❌ aider installation failed"
    exit 1
fi

# Create a configuration directory if it doesn't exist
mkdir -p ~/.config/aider

# Add any additional configuration steps here
# For example, you might want to create a default config file
# or set up API keys if needed

echo "✨ aider setup complete"
