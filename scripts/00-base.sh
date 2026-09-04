#!/usr/bin/env bash
# Base packages. No snap, no flatpak — deb only.
set -euo pipefail

echo ">>> Removing snap & flatpak (if present)"
sudo apt purge -y snapd flatpak 2>/dev/null || true
sudo apt-mark hold snapd 2>/dev/null || true

echo ">>> Base packages"
sudo apt update
sudo apt install -y build-essential git curl wget tmux htop nvtop jq unzip \
    mesa-utils python3-venv python3-pip python3-dev systemsettings

echo ">>> Firefox from Mozilla's official apt repo (real deb, not snap)"
# Key must be DEARMORED (binary gpg) — an armored key makes apt fail with
# "the key is not signed / cannot be verified".
curl -fsSL https://packages.mozilla.org/apt/repo-signing-key.gpg \
    | sudo gpg --dearmor -o /usr/share/keyrings/mozilla.gpg
sudo chmod a+r /usr/share/keyrings/mozilla.gpg
echo "deb [signed-by=/usr/share/keyrings/mozilla.gpg] https://packages.mozilla.org/apt mozilla main" \
    | sudo tee /etc/apt/sources.list.d/mozilla.list >/dev/null
printf 'Package: *\nPin: origin packages.mozilla.org\nPin-Priority: 1000\n' \
    | sudo tee /etc/apt/preferences.d/mozilla-firefox >/dev/null
sudo apt update
sudo apt install -y firefox

echo ">>> Cleaning old kernels"
sudo apt autoremove -y

echo ">>> Done."
