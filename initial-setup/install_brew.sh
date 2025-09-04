#!/bin/bash

# Exit on any error
set -e

# Function to print error messages
print_error() {
    echo -e "\033[0;31mError: $1\033[0m" >&2
}

# Function to print success messages
print_success() {
    echo -e "\033[0;32m$1\033[0m"
}

# Check if running as root
if [[ $EUID -eq 0 ]]; then
   print_error "This script should not be run as root"
   exit 1
fi

# Install build-essential
echo "Installing build-essential..."
if sudo apt update && sudo apt install build-essential -y; then
    print_success "build-essential installed successfully"
else
    print_error "Failed to install build-essential"
    exit 1
fi

# Install Homebrew
echo "Installing Homebrew..."
if /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
    print_success "Homebrew installed successfully"
else
    print_error "Failed to install Homebrew"
    exit 1
fi

# Configure shell environment
echo "Configuring shell environment..."
echo >> "/home/${USER}/.bashrc"
echo "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"" >> "/home/${USER}/.bashrc"

# Activate in current session
if eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"; then
    print_success "Homebrew configuration completed successfully"
else
    print_error "Failed to configure Homebrew environment"
    exit 1
fi

print_success "Homebrew installation and configuration completed!"
echo "Please restart your terminal or run 'source ~/.bashrc' to activate Homebrew"

