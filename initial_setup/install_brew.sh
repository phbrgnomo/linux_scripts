#!/bin/bash

# Function to install Homebrew if not already installed
install_homebrew() {
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

# Check if Homebrew is already installed in the common paths
if test -d ~/.linuxbrew || test -d /home/linuxbrew/.linuxbrew; then
    echo "Homebrew is already installed. Adding to shell environment..."
else
    install_homebrew
fi

# Set up Homebrew environment variables for the current session
if test -d ~/.linuxbrew; then
    eval "$($(~/.linuxbrew/bin/brew shellenv))"
elif test -d /home/linuxbrew/.linuxbrew; then
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
fi

# Ensure Homebrew is added to the shell configuration file
if ! grep -q 'brew shellenv' ~/.bashrc; then
    echo "eval \"\$($(brew --prefix)/bin/brew shellenv)\"" >> ~/.bashrc
    echo "Homebrew environment added to .bashrc"
fi

# Reload the shell configuration
source ~/.bashrc

echo "Homebrew setup is complete!"
