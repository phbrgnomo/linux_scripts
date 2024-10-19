#!/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (with sudo)"
    exit 1
fi

# Get the username of the user who invoked sudo
ACTUAL_USER=$(logname || who am i | awk '{print $1}')
USER_HOME=$(eval echo ~${ACTUAL_USER})

# Update packages gpg keys
echo "Updating packages gpg keys..."
mkdir -p /etc/apt/keyrings
wget -qO- https://raw.githubusercontent.com/eza-community/eza/main/deb.asc | sudo gpg --dearmor -o /etc/apt/keyrings/gierens.gpg
echo "deb [signed-by=/etc/apt/keyrings/gierens.gpg] http://deb.gierens.de stable main" | sudo tee /etc/apt/sources.list.d/gierens.list
chmod 644 /etc/apt/keyrings/gierens.gpg /etc/apt/sources.list.d/gierens.list

# Update & upgrade packages
echo "Updating package list and upgrading existing packages..."
apt update && apt upgrade -y

declare -A apt_packages=(
    ["curl"]="Command line tool for transferring data with URLs"
    ["git"]="Distributed version control system"
    ["htop"]="Interactive process viewer"
    ["tree"]="Directory listing program showing a depth indented list of files"
    ["python3"]="High-level programming language"
    ["python3-pip"]="Package installer for Python"
    ["gh"]="GitHub's official command line tool"
    ["eza"]="Modern replacement for ls"
    ["build-essential"]="Informational list of build-essential packages"
    ["neofetch"]="Shows system information in terminal"
    ["gcc"]="GNU C compiler"
)

declare -A brew_packages=(
    ["bat"]="A cat clone with syntax highlighting"
    ["fd"]="A simple, fast and user-friendly alternative to find"
    ["fzf"]="A general-purpose command-line fuzzy finder"
)

# Arrays to store selected packages
declare -a selected_apt_packages=()
declare -a selected_brew_packages=()

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

# Function to install Homebrew as a non-root user
install_homebrew() {
    print_colored "yellow" "\nInstalling Homebrew..."
    if ! sudo -u "$ACTUAL_USER" command -v brew &> /dev/null; then
        # Temporarily drop root privileges and run as the actual user
        local install_cmd='/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        
        # Exit sudo temporarily to run the Homebrew installation as the user
        if sudo -u "${ACTUAL_USER}" bash -c "${install_cmd}"; then
            print_colored "green" "Homebrew installed successfully!"
            
            # Add Homebrew to PATH for the actual user
            if [[ -f "/home/linuxbrew/.linuxbrew/bin/brew" ]]; then
                sudo -u "${ACTUAL_USER}" bash -c 'echo "eval \$($(brew --prefix)/bin/brew shellenv)" >> "$HOME/.profile"'
                sudo -u "${ACTUAL_USER}" bash -c 'echo "eval \$($(brew --prefix)/bin/brew shellenv)" >> "$HOME/.bashrc"'
                print_colored "green" "Homebrew added to PATH for ${ACTUAL_USER}"
            fi
        else
            print_colored "red" "Failed to install Homebrew"
            exit 1
        fi
    else
        print_colored "yellow" "Homebrew is already installed for ${ACTUAL_USER}"
    fi
}

# Ask user about each APT package
echo -e "\nSelecting APT packages:"
for package in "${!apt_packages[@]}"; do
    description="${apt_packages[$package]}"
    if ! dpkg -s "$package" &> /dev/null; then
        while true; do
            read -p "Install ${package} (${description})? [Y/n]: " yn
            case $yn in
                [Yy]*|[Nn]*)
                    if [[ $yn == [Nn]* ]]; then
                        break
                    else
                        selected_apt_packages+=("$package")
                        break
                    fi
                    ;;
                "")
                    selected_apt_packages+=("$package")
                    break
                    ;;
                * )
                    echo "Please answer y or n"
                    ;;
            esac
        done
    else
        print_colored "yellow" "${package} is already installed, skipping..."
    fi
done

# Ask user about each Brew package
echo -e "\nSelecting Brew packages:"
for package in "${!brew_packages[@]}"; do
    description="${brew_packages[$package]}"
    if ! brew list "$package" &> /dev/null; then
        while true; do
            read -p "Install ${package} (${description})? [Y/n]: " yn
            case $yn in
                [Yy]*|[Nn]*)
                    if [[ $yn == [Nn]* ]]; then
                        break
                    else
                        selected_brew_packages+=("$package")
                        break
                    fi
                    ;;
                "")
                    selected_brew_packages+=("$package")
                    break
                    ;;
                * )
                    echo "Please answer y or n"
                    ;;
            esac
        done
    else
        print_colored "yellow" "${package} is already installed, skipping..."
    fi
done

# Install selected APT packages
if [ ${#selected_apt_packages[@]} -gt 0 ]; then
    print_colored "yellow" "\nInstalling selected APT packages..."
    for package in "${selected_apt_packages[@]}"; do
        print_colored "yellow" "\nInstalling $package..."
        if apt install -y "$package"; then
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
        if sudo -u "${ACTUAL_USER}" brew install "$package"; then
            print_colored "green" "$package installed successfully!"
        else
            print_colored "red" "Failed to install $package"
        fi
    done
fi

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





# # Install package managers
# # Install brew
# echo "Installing Homebrew..."
# /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# # Adding brew to .bashrc
# echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/phbr/.bashrc
# eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"



# # Install apt-packages
# for package in "${apt-packages[@]}"; do
#     echo "(Apt-get) Installing $package..."
#     apt install -y "$package"
# done

# # Install brew-packages
# for package in "${brew-packages[@]}"; do
#     echo "(Homebrew) Installing $package..."
#     brew install "$package"
# done


# echo "All apt-packages installed successfully!"
