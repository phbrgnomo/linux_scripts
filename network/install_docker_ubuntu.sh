#!/bin/bash

# Function to print messages in a formatted way
print_message() {
    echo -e "\n\033[1;34m$1\033[0m"
}

# Function to show a progress bar
show_progress() {
    local duration=$1
    echo -ne "\033[1;32m["  # Green color
    for ((i=0; i<50; i++)); do
        sleep $(bc <<< "scale=2; $duration / 50")  # Adjust sleep time
        echo -ne "="
    done
    echo -e "]\033[0m"  # Reset color
}

# Exit script if any command fails
set -e

# Update the package index
print_message "Updating package index..."
show_progress 5
sudo apt-get update -y > /dev/null 2>&1
print_message "Package index updated."

# Install prerequisites for Docker
print_message "Installing prerequisites for Docker..."
show_progress 5
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg \
    lsb-release > /dev/null 2>&1
print_message "Prerequisites installed."

# Add Docker’s official GPG key
print_message "Adding Docker's official GPG key..."
show_progress 3
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg > /dev/null 2>&1
print_message "Docker's GPG key added."

# Set up the stable Docker repository
print_message "Setting up the Docker repository..."
show_progress 3
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
print_message "Docker repository set up."

# Update the package index again to include Docker's packages
print_message "Updating package index again for Docker packages..."
show_progress 5
sudo apt-get update -y > /dev/null 2>&1
print_message "Package index updated for Docker."

# Install Docker Engine
print_message "Installing Docker Engine..."
show_progress 5
sudo apt-get install -y docker-ce docker-ce-cli containerd.io > /dev/null 2>&1
print_message "Docker Engine installed."

# Start and enable the Docker service
print_message "Starting Docker service..."
show_progress 3
sudo systemctl start docker > /dev/null 2>&1
sudo systemctl enable docker > /dev/null 2>&1
print_message "Docker service started and enabled."

# Add the current user to the docker group
print_message "Adding the user to the docker group..."
sudo usermod -aG docker $USER
print_message "User added to the docker group."

# Verify Docker installation
print_message "Verifying Docker installation..."
if docker --version > /dev/null 2>&1; then
    print_message "Docker version: $(docker --version)"
else
    echo -e "\033[1;31mDocker installation failed.\033[0m"  # Red error message
    exit 1
fi

# Verify installation of Docker Compose (CLI plugin)
print_message "Verifying installation of Docker Compose (CLI plugin)..."
if docker compose version > /dev/null 2>&1; then
    print_message "Docker Compose version: $(docker compose version)"
else
    echo -e "\033[1;31mDocker Compose installation failed.\033[0m"  # Red error message
    exit 1
fi

# Completion message
print_message "Docker and Docker Compose have been installed successfully."
echo -e "\033[1;32mYou can now use 'docker compose up' to run your containers.\033[0m"
echo -e "\033[1;33mYou may need to log out and back in for group changes to take effect.\033[0m"
