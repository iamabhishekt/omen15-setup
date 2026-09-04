#!/usr/bin/env bash
# Lid-close behavior (keep using external monitor) + KDE dark theme.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

echo ">>> Lid switch: ignore close events system-wide"
sudo mkdir -p /etc/systemd/logind.conf.d
sudo cp "$ROOT/configs/etc/systemd/logind.conf.d/99-lid.conf" /etc/systemd/logind.conf.d/
sudo systemctl restart systemd-logind   # may end your graphical session; re-login is fine

echo ">>> KDE dark theme"
if command -v lookandfeeltool >/dev/null 2>&1 && [ -n "${DISPLAY:-}${WAYLAND_DISPLAY:-}" ]; then
    lookandfeeltool --apply org.kde.breezedark.desktop
else
    echo ">>> No display here — run this inside a Plasma session:"
    echo ">>>   lookandfeeltool --apply org.kde.breezedark.desktop"
fi

echo ">>> Also set manually in Plasma once:"
echo ">>>   System Settings -> Power Management -> 'When laptop lid closed' = Do nothing"
