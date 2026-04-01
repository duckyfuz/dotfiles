#!/usr/bin/env bash
set -euo pipefail

OS="$(uname -s)"

echo "==> Installing core packages..."
if [[ "$OS" == "Darwin" ]]; then
    brew install stow neovim tmux jenv
    sudo chsh -s "$(which zsh)" "$USER"
elif [[ "$OS" == "Linux" ]]; then
    sudo add-apt-repository -y --no-update ppa:neovim-ppa/stable
    sudo apt update -qq
    sudo apt install -y stow tmux curl neovim eza zsh
    sudo chsh -s "$(which zsh)" "$USER"

    if [[ ! -e "$HOME/.jenv" ]]; then
        git clone https://github.com/jenv/jenv.git "$HOME/.jenv"
    elif [[ -d "$HOME/.jenv/.git" ]]; then
        echo "==> Reusing existing jenv checkout at $HOME/.jenv"
    else
        echo "Error: $HOME/.jenv already exists but is not a jenv git checkout." >&2
        exit 1
    fi
fi

echo "==> Installing oh-my-zsh..."
if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    rm ~/.zshrc
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

echo "Done! Please log out and back in for the default shell change to take effect."
