#!/bin/bash

# Script to install Oh My Zsh with Powerlevel10k, useful plugins, and Oh My Posh

# Function to print messages
print_message() {
    echo -e "\n\033[1;34m$1\033[0m"  # Print message in blue
}

# Function to check if a command was successful
check_command_success() {
    if [[ $? -ne 0 ]]; then
        print_message "Failed to execute: $1"
        exit 1
    fi
}

# Update package list and upgrade existing packages
print_message "Updating package list and upgrading existing packages..."
sudo apt update && sudo apt upgrade -y

# Check if nala is installed; if not, install it
if ! command -v nala &> /dev/null; then
    print_message "Nala is not installed. Installing using apt..."
    sudo apt update
    if sudo apt install -y nala; then
        print_message "Nala installed successfully!"
    else
        print_message "Failed to install Nala. Exiting."
        exit 1
    fi
else
    print_message "Nala is already installed."
fi

# Install necessary packages
print_message "Installing required packages: curl, git, and zsh..."
sudo nala install -y curl git zsh

# Check if Zsh is set as the default shell
if [[ "$SHELL" != *"/zsh" ]]; then
    # Install Oh My Zsh without switching shell or prompting
    print_message "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    check_command_success "Oh My Zsh installation"

    # Define the custom directory for themes and plugins
    ZSH_CUSTOM=${ZSH_CUSTOM:-~/.oh-my-zsh/custom}

    # # Install Powerlevel10k theme
    # print_message "Cloning Powerlevel10k theme..."
    # git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH_CUSTOM/themes/powerlevel10k"
    # check_command_success "Powerlevel10k theme cloning"

    # Install useful plugins
    print_message "Cloning plugins..."
    plugins=(
        "zsh-users/zsh-syntax-highlighting"
        "zsh-users/zsh-autosuggestions"
        "MichaelAquilina/zsh-you-should-use"
        "Tarrasch/zsh-autoenv"
        "colored-man-pages/colored-man-pages"
        "Colorize/colorize"
        "command-not-found/command-not-found"
        "joelcoulter/gitignore"
        "jasonm23/jsontools"
        "pschmitt/poetry-zsh-plugin"
        "junegunn/fzf"
    )
    for plugin in "${plugins[@]}"; do
        git clone "https://github.com/${plugin}.git" "$ZSH_CUSTOM/plugins/${plugin##*/}"
        check_command_success "Cloning ${plugin##*/} plugin"
    done

    # Install Oh My Posh
    print_message "Installing Oh My Posh..."
    sudo curl -s https://ohmyposh.dev/install.sh | bash -s
    check_command_success "Oh My Posh installation"

    # Prompt the user to install all themes
    read -p "Do you want to download and install all Oh My Posh themes? (yes/no): " install_choice



    if [[ "$install_choice" == "yes" ]]; then
        # Download all themes
        mkdir -p .poshthemes/
        cd .poshthemes/

        for theme in $(curl -s https://api.github.com/repos/JanDeDobbeleer/oh-my-posh/contents/themes | jq -r '.[].name'); do
            curl -O https://raw.githubusercontent.com/JanDeDobbeleer/oh-my-posh/main/themes/$theme
            check_command_success "Downloading theme: $theme"
        done
        echo "All Oh My Posh themes downloaded successfully."
        cd ..
    else
        echo "You can check all available themes at: https://github.com/JanDeDobbeleer/oh-my-posh/tree/main/themes"
    fi

    # Print the command to change the theme
    echo "To change the theme, use the following command:"
    echo "oh-my-posh --config '/home/yourusername/.poshthemes/<Theme_Name>.omp.json'"
    echo "Replace <ThemeName> with the name of the theme you want to use."
    echo "Ass 'eval "$(oh-my-posh init zsh --config ~/.poshthemes/<Theme_Name>.omp.json)"' to ~/.zshrc to persist the chosen theme"
    

    oh-my-posh font install meslo

    
    # Update .zshrc to use the Powerlevel10k theme and plugins
    print_message "Updating .zshrc configuration..."
    sed -i 's/plugins=(git)/plugins=(git autoenv colored-man-pages colorize command-not-found gitignore jsontools pip poetry themes zsh-autosuggestions you-should-use fzf)/g' ~/.zshrc
    # sed -i 's/ZSH_THEME=".*"/ZSH_THEME="powerlevel10k\/powerlevel10k"/g' ~/.zshrc

# Add Oh My Posh initialization to .zshrc
    print_message "Adding Oh My Posh initialization to ~/.zshrc..."
    echo 'eval "$(oh-my-posh init zsh)"' >> ~/.zshrc
    check_command_success "Adding Oh My Posh initialization to .zshrc"

    # Change default shell to Zsh
    print_message "Changing default shell to Zsh..."
    chsh -s "$(which zsh)"
else
    print_message "Zsh is already set as the default shell."
fi

# Inform the user about the completion of the installation
print_message "Installation completed successfully!"
echo -e "Please log out and log back in, or restart your terminal session to use Zsh."

# Start a new Zsh session immediately
exec zsh
