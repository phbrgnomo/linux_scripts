#!/bin/bash

apt install build-essential -y

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

echo >> "/home/${USER}/.bashrc"
echo "eval \"\$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)\"" >> "/home/${USER}/.bashrc"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"

