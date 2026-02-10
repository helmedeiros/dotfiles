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

# Models to install
MODELS=("llama3" "llama4")

for model in "${MODELS[@]}"; do
    if ! ollama list | grep -q "$model"; then
        echo "Pulling $model model..."
        ollama pull "$model"
    else
        echo "$model model is already installed"
    fi
done

echo "Ollama is ready to use! Run 'ollama run llama3' or 'ollama run llama4' to start."
