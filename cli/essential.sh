# !/bin/bash

# Update package list
sudo apt update

# List of packages to install
packages=(
    curl
    git
    htop
    tree
    build-essential
    python3
    python3-pip
    gh
)

# Install packages
for package in "${packages[@]}"; do
    echo "Installing $package..."
    sudo apt install -y "$package"
done

echo "All packages installed successfully!"
