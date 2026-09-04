#!/usr/bin/env bash
# Bazzite gaming layer: OBS, CoreCtrl (hardware control), OpenRGB,
# gamescope, system monitors. All deb from Ubuntu universe.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo ">>> Installing gaming/desktop tools (skips any not in repos)"
for pkg in gamescope obs-studio corectrl openrgb btop fastfetch jstest-gtk; do
    sudo apt install -y "$pkg" || echo ">>> SKIP: $pkg not available"
done

echo ">>> CoreCtrl polkit rule (lets it control hardware without asking password)"
sudo mkdir -p /etc/polkit-1/rules.d
sudo cp "$ROOT/configs/etc/polkit-1/rules.d/90-corectrl.rules" /etc/polkit-1/rules.d/ 2>/dev/null || true

echo ">>> Add yourself to 'video' group for OpenRGB device access (log out/in after):"
sudo usermod -aG video "$USER" || true
echo ">>> Done. Extras:"
echo ">>>   gamescope      -> run any game inside:  gamescope -- %command%"
echo ">>>   mangohud       -> overlay:              mangohud %command%"
echo ">>>   gamemoderun    -> performance governor: gamemoderun %command%"
echo ">>>   corectrl / openrgb / btop / fastfetch"
