#!/usr/bin/env bash

# Check if Ollama is installed via Homebrew
if ! command -v ollama &> /dev/null; then
    echo "Ollama is not installed. Please run 'bin/dot' first to install it via Homebrew."
    exit 1
fi

# Check if Ollama service is running
if ! brew services list | grep -q "ollama.*started"; then
    echo "Starting Ollama service..."
    brew services start ollama
    sleep 5
fi

# Check if llama3 model is already pulled
if ! ollama list | grep -q "llama3"; then
    echo "Pulling llama3 model..."
    ollama pull llama3
else
    echo "llama3 model is already installed"
fi

echo "Ollama is ready to use! You can run 'ollama run llama3' to start using it."
