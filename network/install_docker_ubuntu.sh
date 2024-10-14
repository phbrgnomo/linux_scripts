#!/bin/bash

# Function to print messages in a formatted way
print_message() {
    echo -e "\n\033[1;34m$1\033[0m"
}

# Update the package index
print_message "Updating package index..."
sudo apt-get update

# Install prerequisites for Docker
print_message "Installing prerequisites for Docker..."
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release

# Add Docker’s official GPG key
print_message "Adding Docker's official GPG key..."
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg

# Set up the stable Docker repository
print_message "Setting up the Docker repository..."
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update the package index again to include Docker's packages
print_message "Updating package index again..."
sudo apt-get update

# Install Docker Engine
print_message "Installing Docker Engine..."
sudo apt-get install -y docker-ce docker-ce-cli containerd.io

# Start and enable the Docker service
print_message "Starting Docker service..."
sudo systemctl start docker
sudo systemctl enable docker

# Verify Docker installation
print_message "Verifying Docker installation..."
docker --version

# Verify installation of Docker Compose (CLI plugin)
print_message "Verifying installation of Docker Compose (CLI plugin)..."
docker compose version

# Completion message
print_message "Docker and Docker Compose have been installed successfully."
echo "You can now use 'docker compose up' to run your containers."
