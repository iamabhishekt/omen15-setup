#!/usr/bin/env bash
# Base packages. No snap, no flatpak — deb only.
set -euo pipefail

echo ">>> Removing snap & flatpak (if present)"
sudo apt purge -y snapd flatpak 2>/dev/null || true
sudo apt-mark hold snapd 2>/dev/null || true

echo ">>> Base packages"
sudo apt update
sudo apt install -y build-essential git curl wget tmux htop nvtop jq unzip \
    mesa-utils python3-venv python3-pip python3-dev

echo ">>> Cleaning old kernels"
sudo apt autoremove -y

echo ">>> Done."
