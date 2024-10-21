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
sudo nala fetch --auto

# Get the username and home directory of the current user
ACTUAL_USER=$(whoami)
# USER_HOME=$(eval echo ~${ACTUAL_USER})

print_colored() {
    local color=$1
    local message=$2
    case $color in
        "green") echo -e "\033[0;32m${message}\033[0m" ;;
        "red") echo -e "\033[0;31m${message}\033[0m" ;;
        "yellow") echo -e "\033[1;33m${message}\033[0m" ;;
        *) echo "${message}" ;;
    esac
}

# Update packages gpg keys
echo "Updating packages gpg keys..."
# create keyring folder (requires sudo)
sudo mkdir -p /etc/apt/keyrings
# eza keyring
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor --yes -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
sudo chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

# Update & upgrade packages (requires sudo)
echo "Updating package list and upgrading existing packages..."
sudo nala update && sudo nala upgrade --full -y

# Declare packages
declare -A apt_packages=(
    # git tools
    ["git"]="Distributed version control system"
    ["gh"]="GitHub's official command line tool"
    # cli tools
    ["tree"]="Directory listing program showing a depth indented list of files"
    ["eza"]="Modern replacement for ls"
    ["bat"]="A cat clone with syntax highlighting"
    ["fzf"]="A general-purpose command-line fuzzy finder"
    ["bpytop"]="Terminal-based resource monitor"
    ["tldr"]="Simpler man pages"
    ["duf"]="Disk usage statistics"
    # terminal interface
    ["zsh"]="The Z shell (zsh)"
    # fancy stuff
    ["neofetch"]="Shows system information in terminal"    
    # code interpreters
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
install_homebrew() {
    print_colored "yellow" "\nInstalling Homebrew..."
    if ! command -v brew &> /dev/null; then
        local install_cmd="/bin/bash -c \"\$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)\""
        # Add Homebrew to PATH for the actual user
        if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
            echo "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"" >> "/home/${ACTUAL_USER}/.profile"
            echo "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"" >> "/home/${ACTUAL_USER}/.bashrc"
            print_colored "green" "Homebrew added to PATH"
        fi

        fi
        # Run Homebrew installation as actual user (not root)
        if bash -c "${install_cmd}"; then
            print_colored "green" "Homebrew installed successfully!"
        else
            print_colored "red" "Failed to install Homebrew"
            exit 1
        fi
    else
        print_colored "yellow" "Homebrew is already installed"
    fi
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

# Ask if user wants to install everything
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
            break
            ;;
        [Nn]*)
            # Ask about each APT package
            echo -e "\nSelecting APT packages:"
            for package in "${!apt_packages[@]}"; do
                description="${apt_packages[$package]}"
                if ! dpkg -s "$package" &> /dev/null; then
                    while true; do
                        read -p "Install ${package} (${description})? [Y/n]: " yn
                        case $yn in
                            [Yy]*|"")
                                selected_apt_packages+=("$package")
                                break
                                ;;
                            [Nn]*)
                                break
                                ;;
                            *)
                                echo "Please answer y or n"
                                ;;
                        esac
                    done
                else
                    print_colored "yellow" "${package} is already installed, skipping..."
                fi
            done

            # Ask about each Brew package
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
                                    break
                                    ;;
                                [Nn]*)
                                    break
                                    ;;
                                *)
                                    echo "Please answer y or n"
                                    ;;
                            esac
                        done
                    else
                        print_colored "yellow" "${package} is already installed, skipping..."
                    fi
                done
            fi
            break
            ;;
        *)
            echo "Please answer y or n"
            ;;
    esac
done

# Install selected APT packages (requires sudo)
if [ ${#selected_apt_packages[@]} -gt 0 ]; then
    print_colored "yellow" "\nInstalling selected APT packages..."
    for package in "${selected_apt_packages[@]}"; do
        print_colored "yellow" "\nInstalling $package..."
        if sudo nala install -y "$package"; then
            print_colored "green" "$package installed successfully!"
        else
            print_colored "red" "Failed to install $package"
        fi
    done
fi

# Install selected Brew packages
if [ ${#selected_brew_packages[@]} -gt 0 ]; then
    install_homebrew
    print_colored "yellow" "\nInstalling selected Brew packages..."
    for package in "${selected_brew_packages[@]}"; do
        print_colored "yellow" "\nInstalling $package..."
        if brew install "$package"; then
            print_colored "green" "$package installed successfully!"
        else
            print_colored "red" "Failed to install $package"
        fi
    done
fi

# Docker installation
# https://docs.docker.com/engine/install/debian/
while true; do
    read -p "Install Docker? [Y/n]: " response
    case $response in
        [Yy]* | "" )
            echo "Installing Docker..."
            sudo bash -c "$(curl -sL https://raw.githubusercontent.com/phbrgnomo/linux_scripts/refs/heads/main/network/install_docker_debian.sh)"
            break
            ;;
        [Nn]* )
            break
            ;;
        * )
            echo "Please answer y or n"
            ;;
    esac
done

# Miniconda installation


while true; do
    read -p "Install Miniconda? [Y/n]: " response
    case $response in
        [Yy]* | "" )
            echo "Installing Miniconda..."
            wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
            bash Miniconda3-latest-Linux-x86_64.sh
            rm Miniconda3-latest-Linux-x86_64.sh
            break
            ;;
        [Nn]* )
            break
            ;;
        * )
            echo "Please answer y or n"
            ;;
    esac
done

print_colored "green" "\nInstallation process completed!"

# Summary
echo -e "\nInstallation Summary:"
if [ ${#selected_apt_packages[@]} -gt 0 ]; then
    echo "APT packages installed:"
    printf '%s\n' "${selected_apt_packages[@]}" | sed 's/^/- /'
fi

if [ ${#selected_brew_packages[@]} -gt 0 ]; then
    echo "Brew packages installed:"
    printf '%s\n' "${selected_brew_packages[@]}" | sed 's/^/- /'
fi