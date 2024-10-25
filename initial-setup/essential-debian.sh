#!/bin/bash

# Check if script is run as root and prevent it
if [ "$EUID" -eq 0 ]; then 
    echo "Do not run this script as root or with sudo"
    exit 1
fi

# Minimal packages
sudo apt update && sudo apt upgrade -y
sudo apt install -y wget curl build-essential nala

# Update best mirrors
    read -p "Fetch best mirrors now?? (Y/n): " resposta
    if [[ "$resposta" == "s" || "$resposta" == "Y" ]]; then
        echo "Updating mirrors..."
        sudo nala fetch --auto
    else
        echo "Skipping mirrors update."
    fi

# Get the username and home directory of the current user
ACTUAL_USER=$(whoami)
USER_HOME=$(eval echo ~${ACTUAL_USER})


# Print a message with a given color
#
# Args:
#   color (str): The color of the message. Options are "green", "red", "yellow".
#   message (str): The message to print.
print_colored() {
    local color=$1
    local message=$2
    case $color in
        "green") echo -e "\033[0;32m${message}\033[0m" ;; # green
        "red") echo -e "\033[0;31m${message}\033[0m" ;; # red
        "yellow") echo -e "\033[1;33m${message}\033[0m" ;; # yellow
        *) echo "${message}" ;; # no color
    esac
}

log_message() { # [changed]
    local message=$1
    echo "$(date '+%Y-%m-%d %H:%M:%S') - ${message}" >> installation.log # Log with timestamp [changed]
}

# Update packages gpg keys
log_message "Updating packages gpg keys..." # [changed]
echo "Updating packages gpg keys..."
# create keyring folder (requires sudo)
sudo mkdir -p /etc/apt/keyrings
# eza keyring
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

# Update & upgrade packages (requires sudo)
log_message "Updating package list and upgrading existing packages..." # [changed]
echo "Updating package list and upgrading existing packages..."
sudo nala update && sudo nala upgrade --full -y

# Declare packages
declare -A apt_packages=(
    ["git"]="Distributed version control system"
    ["gh"]="GitHub's official command line tool"
    ["tree"]="Directory listing program showing a depth indented list of files"
    ["eza"]="Modern replacement for ls"
    ["bat"]="A cat clone with syntax highlighting"
    ["fzf"]="A general-purpose command-line fuzzy finder"
    ["bpytop"]="Terminal-based resource monitor"
    ["tldr"]="Simpler man pages"
    ["duf"]="Disk usage statistics"
    ["zsh"]="The Z shell (zsh)"
    ["neofetch"]="Shows system information in terminal"
    ["python3"]="High-level programming language"
    ["python3-pip"]="Package installer for Python"
)

declare -A brew_packages=(
    ["lazydocker"]="A simple terminal UI for both docker and docker-compose, written in Go with the gocui library."
)

# Arrays to store selected packages
declare -a selected_apt_packages=()
declare -a selected_brew_packages=()

# Function to install Homebrew
/*************  ✨ Codeium Command 🌟  *************/
install_homebrew() {
    log_message "Starting Homebrew installation..."
    print_colored "yellow" "Installing Homebrew..."

    log_message "Installing Homebrew..." # [changed]
    print_colored "yellow" "\nInstalling Homebrew..."
    if ! command -v brew &> /dev/null; then
        local install_command="/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        local install_cmd="/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        
        if eval "${install_command}"; then
            print_colored "green" "Homebrew installation succeeded!"
            log_message "Homebrew installation completed successfully."
        # Run Homebrew installation as actual user (not root)
        if eval "${install_cmd}"; then
            print_colored "green" "Homebrew installed successfully!"
            log_message "Homebrew installed successfully!" # [changed]

            local brew_shellenv="/home/linuxbrew/.linuxbrew/bin/brew shellenv"
            echo "eval \"\$(${brew_shellenv})\"" >> "/home/${ACTUAL_USER}/.profile"
            echo "eval \"\$(${brew_shellenv})\"" >> "/home/${ACTUAL_USER}/.bashrc"
            # Add Homebrew to PATH for the actual user
            echo "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"" >> "/home/${ACTUAL_USER}/.profile"
            echo "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"" >> "/home/${ACTUAL_USER}/.bashrc"
            # Source the new profile or bashrc to update the current session
            source "/home/${ACTUAL_USER}/.bashrc"

        else
            print_colored "red" "Homebrew installation failed."
            log_message "Failed to install Homebrew."
            print_colored "red" "Failed to install Homebrew"
            log_message "Failed to install Homebrew" # [changed]
            exit 1
        fi
    else
        print_colored "yellow" "Homebrew is already installed."
        print_colored "yellow" "Homebrew is already installed"
    fi
}
/******  654a477c-a79c-4db7-9ef9-b359d3928cda  *******/

# Function to clean up temporary files [changed]
cleanup() {
    log_message "Cleaning up temporary files..." # [changed]
    rm -f Miniconda3-latest-Linux-x86_64.sh # Remove Miniconda installer if exists [changed]
}

# Display all available packages
echo -e "\nAvailable packages to install:"
echo -e "\nAPT Packages:"
for package in "${!apt_packages[@]}"; do
    description="${apt_packages[$package]}"
    echo "- ${package}: ${description}"
done

if [ ${#brew_packages[@]} -gt 0 ]; then
    echo -e "\nBrew Packages:"
    for package in "${!brew_packages[@]}"; do
        description="${brew_packages[$package]}"
        echo "- ${package}: ${description}"
    done
fi

echo -e "\nDocker will also be available for installation."

# Ask if user wants to install everything with simplified prompt 
while true; do
    read -p $'\nDo you want to install all packages? [Y/n]: ' install_all
    case $install_all in
        [Yy]*|"")
            # Add all APT packages to selected
            for package in "${!apt_packages[@]}"; do
                if ! dpkg -s "$package" &> /dev/null; then
                    selected_apt_packages+=("$package")
                else
                    print_colored "yellow" "${package} is already installed, skipping..."
                fi
            done
            
            # Add all Brew packages to selected
            for package in "${!brew_packages[@]}"; do
                if ! brew list "$package" &> /dev/null 2>&1; then
                    selected_brew_packages+=("$package")
                else
                    print_colored "yellow" "${package} is already installed, skipping..."
                fi
            done
            
            break ;;
        [Nn]*)
            # Ask about each APT package with simplified prompt 
            echo -e "\nSelecting APT packages:"
            for package in "${!apt_packages[@]}"; do
                description="${apt_packages[$package]}"
                if ! dpkg -s "$package" &> /dev/null; then
                    while true; do
                        read -p "Install ${package} (${description})? [Y/n]: " yn 
                        case $yn in 
                            [Yy]*|"") 
                                selected_apt_packages+=("$package") 
                                break ;; 
                            [Nn]*) 
                                break ;; 
                            *) 
                                echo "Please answer y or n" ;; 
                        esac 
                    done 
                else 
                    print_colored "yellow" "${package} is already installed, skipping..."
                fi 
            done
            
            # Ask about each Brew package with simplified prompt 
            if [ ${#brew_packages[@]} -gt 0 ]; then 
                echo -e "\nSelecting Brew packages:" 
                for package in "${!brew_packages[@]}"; do 
                    description="${brew_packages[$package]}" 
                    if ! brew list "$package" &> /dev/null 2>&1; then 
                        while true; do 
                            read -p "Install ${package} (${description})? [Y/n]: " yn 
                            case $yn in 
                                [Yy]*|"") 
                                    selected_brew_packages+=("$package") 
                                    break ;; 
                                [Nn]*) 
                                    break ;; 
                                *) 
                                    echo "Please answer y or n" ;; 
                            esac 
                        done 
                    else 
                        print_colored "yellow" "${package} is already installed, skipping..."
                    fi 
                done 
            fi
            
            break ;;
        *) 
            echo "Please answer y or n" ;; 
    esac  
done 

# Install selected APT packages (requires sudo)
if [ ${#selected_apt_packages[@]} -gt 0 ]; then  
    log_message "\nInstalling selected APT packages..." # [changed]
    print_colored "yellow" "\nInstalling selected APT packages..."  
    for package in "${selected_apt_packages[@]}"; do  
        print_colored "yellow" "\nInstalling $package..."  
        if sudo nala install -y "$package"; then  
            print_colored "green" "$package installed successfully!"  
            log_message "$package installed successfully!" # [changed]
        else  
            print_colored "red" "Failed to install $package"  
            log_message "Failed to install $package." # [changed]
        fi  
    done  
fi  

# Install selected Brew packages with logging and cleanup after installation [changed]
if [ ${#selected_brew_packages[@]} -gt 0 ]; then  
    install_homebrew  
    log_message "\nInstalling selected Brew packages..." # [changed]
    print_colored "yellow" "\nInstalling selected Brew packages..."  
    for package in "${selected_brew_packages[@]}"; do  
        print_colored "yellow" "\nInstalling $package..."  
        if brew install "$package"; then  
            print_colored "green" "$package installed successfully!"  
            log_message "$package installed successfully!" # [changed]
        else  
            print_colored "red" "Failed to install $package"  
            log_message "Failed to install $package." # [changed]
        fi  
    done  
fi  

# Docker installation with logging and cleanup after installation [changed]
while true; do  
    read -p "Install Docker? [Y/n]: " response  
    case $response in  
        [Yy]* | "" )  
            log_message "Installing Docker..." # [changed]
            echo "Installing Docker..."  
            sudo bash -c "$(curl -sL https://raw.githubusercontent.com/phbrgnomo/linux_scripts/refs/heads/main/network/install_docker_debian.sh)" || { log_message "Failed to install Docker."; continue; } # Log failure [changed]
            break ;;  
        [Nn]* )  
            break ;;  
        * )  
            echo "Please answer y or n" ;;  
    esac  
done  

# Miniconda installation with logging and cleanup after installation [changed]
while true; do  
    read -p "Install Miniconda? [Y/n]: " response  
    case $response in  
        [Yy]* | "" )  
            log_message "Installing Miniconda..." # [changed]
            echo "Installing Miniconda..."  
            wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh || { log_message "Failed to download Miniconda."; continue; } # Log failure [changed]
            bash Miniconda3-latest-Linux-x86_64.sh || { log_message "Failed to install Miniconda."; continue; } # Log failure [changed]
            cleanup  # Call cleanup function after installation completes successfully. [changed]
            break ;;  
        [Nn]* )  
            break ;;  
        * )  
            echo "Please answer y or n" ;;  
    esac  
done  

print_colored "green" "\nInstallation process completed!"

# Summary of installations with logging.
log_message "\nInstallation process completed!" # Log completion message. [changed]

echo -e "\nInstallation Summary:"   
if [ ${#selected_apt_packages[@]} -gt 0 ]; then   
    echo "APT packages installed:"   
    printf '%s\n' "${selected_apt_packages[@]}" | sed 's/^/- /'   
fi   

if [ ${#selected_brew_packages[@]} -gt 0 ]; then   
    echo "Brew packages installed:"   
    printf '%s\n' "${selected_brew_packages[@]}" | sed 's/^/- /'   
fi   