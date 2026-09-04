#!/usr/bin/env bash
# JetBrains Toolbox. JetBrains publishes no apt repo — this uses their official
# tarball (no snap/flatpak). The binary is installed to ~/.local/bin.
# After running, launch "jetbrains-toolbox" from the app menu / krunner and
# install your IDEs from its GUI (they land self-contained in ~/.local/share/JetBrains).
set -euo pipefail

URL="$(curl -fsSL "https://data.services.jetbrains.com/products/releases?code=TBA&latest=true&type=release" \
    | python3 -c 'import json,sys; print(json.load(sys.stdin)["TBA"][0]["downloads"]["linux"]["link"])')"
echo ">>> Latest Toolbox: $URL"

mkdir -p "$HOME/.local/bin" /tmp/jb-toolbox
cd /tmp/jb-toolbox
TARBALL="$(basename "$URL")"
curl -fsSLO "$URL"
rm -rf jetbrains-toolbox-*/ 2>/dev/null || true
tar -xzf "$TARBALL"
DIR="$(tar -tzf "$TARBALL" | head -1 | cut -d/ -f1)"
install -m 755 "$DIR/jetbrains-toolbox" "$HOME/.local/bin/jetbrains-toolbox"

echo ">>> Installed: ~/.local/bin/jetbrains-toolbox"
echo ">>> Log out/in (so ~/.local/bin is in PATH), then launch 'jetbrains-toolbox'."
echo ">>> If launched over SSH it will fail — it needs a display. Run it from the desktop."
