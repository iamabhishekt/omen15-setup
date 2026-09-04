#!/usr/bin/env bash
# Omarchy-style terminal & CLI dev toolkit (all deb except starship's installer).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo ">>> Terminal & CLI toolkit"
for pkg in kitty zsh fzf ripgrep fd-find bat eza zoxide git-delta lazygit \
           neovim tmux tree duf ncdu tldr; do
    sudo apt install -y "$pkg" || echo ">>> SKIP: $pkg not available in repos"
done

echo ">>> starship prompt"
if ! command -v starship >/dev/null 2>&1; then
    curl -sS https://starship.rs/install.sh | sudo sh -s -- -y \
        || echo ">>> starship install failed"
fi

echo ">>> zsh config"
cp "$ROOT/configs/home/zshrc" "$HOME/.zshrc"
sudo chsh -s /usr/bin/zsh "$USER" || echo ">>> set zsh manually: chsh -s /usr/bin/zsh"

echo ">>> Done. Open kitty; zsh + starship start next login."
echo ">>> aliases: ll  cat(bat)  vim(nvim)  lg(lazygit)  z(zoxide)"
