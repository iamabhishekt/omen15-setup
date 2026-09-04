#!/usr/bin/env bash
# Restore the captured KDE desktop arrangement (see capture-kde-config.sh).
# WARNING: overwrites current KDE settings. Run inside the Plasma session.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if [ ! -f "$ROOT/configs/kde/plasma-org.kde.plasma.desktop-appletsrc" ]; then
    echo ">>> Nothing captured yet — run capture-kde-config.sh first"
    exit 1
fi

for f in "$ROOT"/configs/kde/*; do
    cp "$f" "$HOME/.config/$(basename "$f")"
    echo "applied: $(basename "$f")"
done

echo ">>> Restarting shell to apply"
kquitapp6 plasmashell 2>/dev/null || kquitapp5 plasmashell 2>/dev/null || true
sleep 1
kstart plasmashell 2>/dev/null || plasmashell --replace >/dev/null 2>&1 &
qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
echo ">>> Done. Log out/in if anything looks off."
