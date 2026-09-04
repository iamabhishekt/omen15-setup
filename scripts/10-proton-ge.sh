#!/usr/bin/env bash
# Install latest GE-Proton (custom Proton build) into Steam's compatibilitytools.
# After running: restart Steam, then per-game Properties -> Compatibility -> GE-Proton.
set -euo pipefail

API="https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest"
URL="$(curl -fsSL "$API" | python3 -c 'import json,sys; r=json.load(sys.stdin); print([a["browser_download_url"] for a in r["assets"] if a["name"].endswith(".tar.gz")][0])')"
NAME="$(basename "$URL")"          # e.g. GE-Proton10-4.tar.gz
DIR="${NAME%.tar.gz}"

# Steam install location varies; prefer the one that exists
if [ -d "$HOME/.local/share/Steam" ]; then
    CTD="$HOME/.local/share/Steam/compatibilitytools.d"
else
    CTD="$HOME/.steam/root/compatibilitytools.d"
fi
mkdir -p "$CTD"

echo ">>> Installing $DIR into $CTD"
cd /tmp
curl -fsSLO "$URL"
tar -xzf "$NAME" -C "$CTD"
rm -f "$NAME"

echo ">>> Restart Steam fully, then per-game: Properties -> Compatibility -> force $DIR"
