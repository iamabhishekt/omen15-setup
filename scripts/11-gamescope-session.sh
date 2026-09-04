#!/usr/bin/env bash
# Bazzite's signature: a console-like Steam session driven by gamescope.
# Adds a "Steam Console (Gamescope)" entry to the SDDM session list.
# EXPERIMENTAL on this hybrid-NVIDIA X11 setup — your normal Plasma session
# is untouched. Remove with: sudo rm /usr/share/xsessions/steam-gamescope.desktop
set -euo pipefail

sudo tee /usr/share/xsessions/steam-gamescope.desktop >/dev/null <<'EOF'
[Desktop Entry]
Name=Steam Console (Gamescope)
Comment=Big Picture Steam inside gamescope — experimental
Exec=gamescope --rt --adaptive-sync --fullscreen -W 1920 -H 1080 -- /usr/bin/steam -tenfoot
Type=Application
DesktopNames=Steam
EOF

echo ">>> Added. Log out, pick 'Steam Console (Gamescope)' at the SDDM login screen."
echo ">>> To remove:  sudo rm /usr/share/xsessions/steam-gamescope.desktop"
