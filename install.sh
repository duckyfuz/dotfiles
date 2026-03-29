#!/usr/bin/env bash
set -euo pipefail

OS="$(uname -s)"

echo "==> Installing core packages..."
if [[ "$OS" == "Darwin" ]]; then
    brew install stow neovim tmux
elif [[ "$OS" == "Linux" ]]; then
    sudo apt-get update -qq
    sudo apt-get install -y stow neovim tmux curl eza
fi

echo "==> Installing oh-my-zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
fi

echo "==> Installing zsh plugins..."
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

[[ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]] &&
    git clone --quiet https://github.com/zsh-users/zsh-autosuggestions \
        "$ZSH_CUSTOM/plugins/zsh-autosuggestions"

[[ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]] &&
    git clone --quiet https://github.com/zsh-users/zsh-syntax-highlighting \
        "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"

echo "==> Stowing dotfiles..."
stow */

echo "Done! Start a new shell: exec zsh"
