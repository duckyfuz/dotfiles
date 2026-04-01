#!/usr/bin/env bash
set -euo pipefail

OS="$(uname -s)"

have_cmd() {
    command -v "$1" >/dev/null 2>&1
}

echo "==> Installing core packages..."
if [[ "$OS" == "Darwin" ]]; then
    brew install stow neovim tmux jenv
    sudo chsh -s "$(which zsh)" "$USER"
elif [[ "$OS" == "Linux" ]]; then
    if have_cmd apt-get; then
        sudo apt-get update -qq
        sudo apt-get install -y stow tmux curl eza zsh git
    elif have_cmd dnf; then
        sudo dnf install -y stow tmux curl zsh git tar gzip

        if sudo dnf install -y eza; then
            :
        else
            echo "==> Skipping eza install: package not available in the configured dnf repositories."
        fi
    else
        echo "Error: unsupported Linux package manager. Expected apt-get or dnf." >&2
        exit 1
    fi

    sudo chsh -s "$(which zsh)" "$USER"

    echo "==> Installing latest Neovim..."
    NVIM_URL="$(
        curl -fsSL https://api.github.com/repos/neovim/neovim/releases/latest |
            grep 'browser_download_url.*nvim-linux-x86_64\.tar\.gz"' |
            cut -d'"' -f4
    )"
    curl -fsSL "$NVIM_URL" | sudo tar -xz -C /opt
    sudo ln -sf /opt/nvim-linux-x86_64/bin/nvim /usr/local/bin/nvim

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
