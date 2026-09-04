#!/usr/bin/env bash
# Install any vendor .deb (GUI IDEs like Cursor / TRAE / CodeBuddy / ZCode / Warp).
# usage: ./scripts/install-deb.sh <url-or-path-to-.deb>
set -euo pipefail
[ "${1:-}" ] || { echo "usage: install-deb.sh <url-or-path-to-.deb>"; exit 1; }
SRC="$1"

if [[ "$SRC" == http* ]]; then
    cd /tmp
    curl -fsSLO "$SRC"
    SRC="./$(basename "$SRC")"
else
    cd "$(dirname "$SRC")"
    SRC="./$(basename "$SRC")"
fi

sudo apt install -y "$SRC"
echo ">>> Installed: $SRC"
