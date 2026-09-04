#!/usr/bin/env bash
# JetBrains Toolbox. JetBrains publishes no apt repo — this uses their official
# tarball (still no snap/flatpak; Toolbox itself installs IDEs self-contained).
# Run this INSIDE the desktop session (it needs a display on first launch).
set -euo pipefail

URL="$(curl -fsSL "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release" \
    | python3 -c 'import json,sys; print(json.load(sys.stdin)["TBA"][0]["downloads"]["linux"]["link"])')"
echo ">>> Latest Toolbox: $URL"

cd /tmp
TARBALL="$(basename "$URL")"
curl -fsSLO "$URL"
rm -rf jetbrains-toolbox-* 2>/dev/null || true
tar -xzf "$TARBALL"
DIR="$(tar -tzf "$TARBALL" | head -1 | cut -d/ -f1)"

echo ">>> Extracted to /tmp/$DIR"
echo ">>> Launch it now (from the desktop session):  /tmp/$DIR/jetbrains-toolbox"
echo ">>> Toolbox self-installs to ~/.local/share/JetBrains and adds itself to the menu."
