#!/usr/bin/env bash
# Apps: Homebrew, Google Chrome (apt repo), qBittorrent, Warp terminal.
# (zsh is in 13-dev-cli.sh; Firefox is in 00-base.sh via Mozilla apt.)
set -euo pipefail

echo ">>> Homebrew (Linuxbrew)"
if ! command -v brew >/dev/null 2>&1; then
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    for rc in ~/.bashrc ~/.zshrc; do
        [ -f "$rc" ] && grep -q linuxbrew "$rc" || \
            echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$rc"
    done
else
    echo ">>> brew already installed"
fi

echo ">>> Google Chrome (official apt repo)"
curl -fsSL https://dl.google.com/linux/linux_signing_key.pub \
    | sudo gpg --dearmor -o /usr/share/keyrings/google-chrome.gpg
sudo chmod a+r /usr/share/keyrings/google-chrome.gpg
echo "deb [arch=amd64 signed-by=/usr/share/keyrings/google-chrome.gpg] http://dl.google.com/linux/chrome/deb/ stable main" \
    | sudo tee /etc/apt/sources.list.d/google-chrome.list >/dev/null
sudo apt update
sudo apt install -y google-chrome-stable

echo ">>> qBittorrent"
sudo apt install -y qbittorrent

echo ">>> Warp terminal (official .deb)"
cd /tmp
curl -fsSLo warp.deb "https://app.warp.dev/download?package=deb"
sudo apt install -y ./warp.deb
rm -f warp.deb

echo ">>> Done. Unsloth is installed by 02-ml.sh (pip into ~/ml)."
