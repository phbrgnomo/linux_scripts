#!/bin/bash

# Function to install Homebrew if not already installed
install_homebrew() {
    echo "Homebrew not found. Installing Homebrew..."
    test -d ~/.linuxbrew && eval "$(~/.linuxbrew/bin/brew shellenv)"
    test -d /home/linuxbrew/.linuxbrew && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bashrc
}

# Check if Homebrew is already installed in the common paths
if test -d ~/.linuxbrew || test -d /home/linuxbrew/.linuxbrew; then
    echo "Homebrew is already installed. Adding to shell environment..."
else
    install_homebrew
fi

# Reload the shell configuration
source ~/.bashrc

echo "Homebrew setup is complete!"
