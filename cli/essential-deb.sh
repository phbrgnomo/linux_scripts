# !/bin/bash

# Check if script is run as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (with sudo)"
    exit 1
fi

# Get the username of the user who  invoked sudo
ACTUAL_USER=$(logname || who am i | awk '{print $1}')
USER_HOME=$(eval echo ~${ACTUAL_USER})

# Update & upgrage packages
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

# Function to install Homebrew
install_homebrew() {
    print_colored "yellow" "\nInstalling Homebrew..."
    if ! command -v brew &> /dev/null; then
        # Install Homebrew as the actual user, not as root
        su - ${ACTUAL_USER} -c '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
        if [ $? -eq 0 ]; then
            print_colored "green" "Homebrew installed successfully!"
        else
            print_colored "red" "Failed to install Homebrew"
            exit 1
        fi
    else
        print_colored "yellow" "Homebrew is already installed"
    fi
}

# Ask user about each package
echo -e "\nSelecting APT packages:"
for package in "${!apt_packages[@]}"; do
    description="${apt_packages[$package]}"
    while true; do
        read -p "Install ${package} (${description})? [y/n]: " yn
        case $yn in
            [Yy]* )
                selected_apt_packages+=("$package")
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
done

echo -e "\nSelecting Brew packages:"
for package in "${!brew_packages[@]}"; do
    description="${brew_packages[$package]}"
    while true; do
        read -p "Install ${package} (${description})? [y/n]: " yn
        case $yn in
            [Yy]* )
                selected_brew_packages+=("$package")
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
done

# Install selected packages
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

if [ ${#selected_brew_packages[@]} -gt 0 ]; then
    install_homebrew
    print_colored "yellow" "\nInstalling selected Brew packages..."
    for package in "${selected_brew_packages[@]}"; do
        print_colored "yellow" "\nInstalling $package..."
        if su - ${ACTUAL_USER} -c "brew install $package"; then
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





# Install package managers
# Install brew
echo "Installing Homebrew..."
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
# Adding brew to .bashrc
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> /home/phbr/.bashrc
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"



# Install apt-packages
for package in "${apt-packages[@]}"; do
    echo "(Apt-get) Installing $package..."
    apt install -y "$package"
done

# Install brew-packages
for package in "${brew-packages[@]}"; do
    echo "(Homebrew) Installing $package..."
    brew install "$package"
done


echo "All apt-packages installed successfully!"
