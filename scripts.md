# Scripts Description

This document provides an overview of all available scripts in this repository.

## CLI Tools

### install-ohmyzsh.sh
**Location:** `cli/install-ohmyzsh.sh`  
**Purpose:** Installs Oh My Zsh with Powerlevel10k, useful plugins, and Oh My Posh  
**Features:**
- Installs Oh My Zsh with essential plugins
- Sets up zsh-syntax-highlighting, zsh-autosuggestions, and other useful plugins
- Installs Oh My Posh for enhanced shell prompts
- Option to download all Oh My Posh themes

**Usage:**
```bash
bash -c "$(curl -sL https://raw.githubusercontent.com/phbrgnomo/linux_scripts/refs/heads/main/cli/install-ohmyzsh.sh)"
```

## GitHub Tools

### github-cloneallrepos.sh
**Location:** `github/github-cloneallrepos.sh`  
**Purpose:** Clone all repositories from your GitHub account  
**Features:**
- Separates private and public repositories into different folders
- Handles existing repositories by pulling latest changes
- Progress tracking and error logging
- Handles deleted repositories gracefully

**Usage:**
```bash
./github-cloneallrepos.sh <destination_folder>
```

**Requirements:** 
- GitHub CLI (`gh`) must be installed and authenticated
- `jq` for JSON parsing

## Initial Setup Scripts

### essential-debian.sh
**Location:** `initial-setup/essential-debian.sh`  
**Purpose:** Comprehensive Debian/Ubuntu system setup script  
**Features:**
- Interactive package selection
- Installs essential development tools
- Option to install Homebrew packages
- Docker installation option
- Miniconda installation option
- Oh My Zsh installation option

**Usage:**
```bash
bash -c "$(curl -sL https://raw.githubusercontent.com/phbrgnomo/linux_scripts/refs/heads/main/initial-setup/essential-debian.sh)"
```

### install_brew.sh
**Location:** `initial-setup/install_brew.sh`  
**Purpose:** Simple Homebrew installation script for Linux  
**Features:**
- Installs build-essential dependencies
- Installs Homebrew
- Configures shell environment

**Usage:**
```bash
bash -c "$(curl -sL https://raw.githubusercontent.com/phbrgnomo/linux_scripts/refs/heads/main/initial-setup/install_brew.sh)"
```

## Network/Container Tools

### install_docker_debian.sh
**Location:** `network/install_docker_debian.sh`  
**Purpose:** Install Docker and Docker Compose on Debian-based systems  
**Features:**
- Installs Docker Engine and Docker Compose
- Adds user to docker group
- Progress indicators
- Verification of installation

**Usage:**
```bash
bash -c "$(curl -sL https://raw.githubusercontent.com/phbrgnomo/linux_scripts/refs/heads/main/network/install_docker_debian.sh)"
```

### install_docker_ubuntu.sh
**Location:** `network/install_docker_ubuntu.sh`  
**Purpose:** Install Docker and Docker Compose on Ubuntu systems  
**Features:**
- Similar to Debian version but optimized for Ubuntu
- Enhanced error handling
- Better progress reporting

**Usage:**
```bash
bash -c "$(curl -sL https://raw.githubusercontent.com/phbrgnomo/linux_scripts/refs/heads/main/network/install_docker_ubuntu.sh)"
```

## Notes

- All scripts include error handling and progress reporting
- Scripts are designed to be idempotent where possible
- Always review scripts before running them with curl | bash
- Some scripts require sudo privileges
- For development, clone the repository and run scripts locally
