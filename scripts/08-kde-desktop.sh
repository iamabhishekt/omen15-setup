#!/usr/bin/env bash
# Bazzite-style desktop polish: dark theme, wallpaper, lockscreen,
# gaming compositor settings, night color. Run INSIDE the Plasma session.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
WALL="$HOME/.local/share/wallpapers/omen-dark.png"

echo ">>> Dark global theme"
plasma-apply-lookandfeel -a org.kde.breezedark.desktop \
    || lookandfeeltool --apply org.kde.breezedark.desktop

echo ">>> Wallpaper"
mkdir -p "$HOME/.local/share/wallpapers"
cp "$ROOT/configs/wallpapers/omen-dark.png" "$HOME/.local/share/wallpapers/"
if command -v plasma-apply-wallpaper >/dev/null 2>&1; then
    plasma-apply-wallpaper "$WALL"
else
    kwriteconfig6 --file plasma-org.kde.plasma.desktop-appletsrc \
        --group Containments --group 1 --group Wallpaper --group org.kde.image \
        --group General --key Image "file://$WALL"
fi

echo ">>> Lockscreen: same wallpaper, auto-lock after 10 min, lock on suspend"
kwriteconfig6 --file kscreenlockerrc \
    --group Greeter --group Wallpaper --group org.kde.image --group General \
    --key Image "file://$WALL"
kwriteconfig6 --file kscreenlockerrc --group Daemon --key Autolock true
kwriteconfig6 --file kscreenlockerrc --group Daemon --key Timeout 10
kwriteconfig6 --file kscreenlockerrc --group Daemon --key LockOnResume true

echo ">>> KWin: allow tearing (smoothest fullscreen gaming), Night Color on"
kwriteconfig6 --file kwinrc --group Compositing --key AllowTearing true
kwriteconfig6 --file kwinrc --group NightColor --key Active true

echo ">>> Reload KWin + lock config"
qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
qdbus org.kde.kscreenlocker /org/freedesktop/ScreenSaver configure 2>/dev/null || true

echo ">>> Lockscreen shortcut stays default: Meta+L"
echo
echo ">>> Hand-arrange your panel/desktop now, then snapshot it into the repo:"
echo ">>>   ./scripts/capture-kde-config.sh"
