#!/bin/bash

apt install build-essential -y

/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Append brew environment initialization to the current user's bashrc
echo >>"$HOME/.bashrc"
# shellcheck disable=SC2016
echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >>"$HOME/.bashrc"
eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
