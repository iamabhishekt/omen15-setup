#!/usr/bin/env bash
# Snapshot your CURRENT KDE desktop arrangement into the repo.
# Run after you've arranged panels, pinned apps, wallpapers, shortcuts —
# the captured files are what apply-kde-config.sh restores anywhere.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

FILES=(
    plasma-org.kde.plasma.desktop-appletsrc   # panels, desktop layout, pinned apps, wallpaper
    kscreenlockerrc                            # lockscreen
    kwinrc                                      # compositor, shortcuts, night color
    kdeglobals                                  # colors, fonts, widget style
    plasmarc                                    # plasma theme
    kglobalshortcutsrc                          # global shortcuts
    kcminputrc                                  # mouse/keyboard
    breezerc                                    # window decoration details
)

mkdir -p "$ROOT/configs/kde"
for f in "${FILES[@]}"; do
    if [ -f "$HOME/.config/$f" ]; then
        cp "$HOME/.config/$f" "$ROOT/configs/kde/$f"
        echo "captured: $f"
    fi
done
echo
echo ">>> Now commit + push so your arrangement is versioned:"
echo ">>>   cd $ROOT && git add -A && git commit -m 'kde: capture desktop arrangement' && git push"
