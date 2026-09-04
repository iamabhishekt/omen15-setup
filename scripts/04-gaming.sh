#!/usr/bin/env bash
# Gaming: Steam from Valve's official .deb (no snap/flatpak) + Proton + tools.
set -euo pipefail

echo ">>> Enabling 32-bit architecture (Steam + Proton need it)"
sudo dpkg --add-architecture i386
sudo apt update

echo ">>> Steam from Valve's official .deb"
cd /tmp
curl -fsSLO https://repo.steampowered.com/steam/archive/stable/steam_latest.deb
sudo apt install -y ./steam_latest.deb

echo ">>> Performance & Vulkan tools"
sudo apt install -y gamemode mangohud vulkan-tools mesa-utils

echo
echo ">>> Proton ships inside Steam. Enable it:"
echo ">>>   Steam -> Settings -> Compatibility -> 'Enable Steam Play for all other titles'"
echo ">>> Launch games with performance overlay:  mangohud %command%   (Steam launch options)"
echo ">>> Launch games with governor boost:       gamemoderun %command%"
