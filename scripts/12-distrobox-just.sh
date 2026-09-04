#!/usr/bin/env bash
# Distrobox (Bazzite's container workflow) + just (Bazzite's recipe runner).
# Distrobox uses the docker backend installed by 03-dgx-docker.sh.
set -euo pipefail

echo ">>> Distrobox"
curl -fsSL https://raw.githubusercontent.com/89luca89/distrobox/main/install | sudo sh

echo ">>> just (command runner)"
JUST_URL="$(curl -fsSL https://api.github.com/repos/casey/just/releases/latest \
    | python3 -c 'import json,sys; print([a["browser_download_url"] for a in json.load(sys.stdin)["assets"] if a["name"].endswith("_amd64.deb")][0])')"
cd /tmp
curl -fsSLO "$JUST_URL"
sudo apt install -y "./$(basename "$JUST_URL")"

echo ">>> Usage:"
echo ">>>   just --list                  # all setup recipes (same as scripts/)"
echo ">>>   distrobox create -n dev -i ubuntu:26.04 && distrobox enter dev"
