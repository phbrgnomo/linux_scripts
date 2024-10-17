#!/bin/bash

# Script to install Oh My Zsh with Powerlevel10k and useful plugins

# Function to print messages
print_message() {
    echo -e "\n\033[1;34m$1\033[0m"  # Print message in blue
}

# Update package list and upgrade existing packages
print_message "Updating package list and upgrading existing packages..."
sudo apt update && sudo apt upgrade -y

# Install necessary packages
print_message "Installing required packages: curl, git, and zsh..."
sudo apt install -y curl git zsh

# Check if Zsh is set as the default shell
if [[ "$SHELL" != *"/zsh" ]]; then
    # Install Oh My Zsh without switching shell or prompting
    print_message "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

    # Define the custom directory for themes and plugins
    ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

    # Install Powerlevel10k theme
    print_message "Cloning Powerlevel10k theme..."
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git $ZSH_CUSTOM/themes/powerlevel10k

    # Install useful plugins
    print_message "Cloning useful plugins..."
    git clone https://github.com/zsh-users/zsh-syntax-highlighting.git $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
    git clone https://github.com/zsh-users/zsh-autosuggestions.git $ZSH_CUSTOM/plugins/zsh-autosuggestions
    git clone https://github.com/MichaelAquilina/zsh-you-should-use.git $ZSH_CUSTOM/plugins/you-should-use

    # Update .zshrc to use the Powerlevel10k theme and plugins
    print_message "Updating .zshrc configuration..."
    sed -i 's/plugins=(git)/plugins=(git zsh-syntax-highlighting zsh-autosuggestions you-should-use)/g' ~/.zshrc
    sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ~/.zshrc

    # Change default shell to Zsh
    print_message "Changing default shell to Zsh..."
    chsh -s $(which zsh)
else
    print_message "Zsh is already set as the default shell."
fi

# Inform the user about the completion of the installation
print_message "Installation completed successfully!"
echo -e "Please log out and log back in, or restart your terminal session to use Zsh."

# Start a new Zsh session immediately
exec zsh
