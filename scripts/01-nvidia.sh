#!/usr/bin/env bash
# NVIDIA driver 610 from Ubuntu repos + hybrid graphics display configs.
# Idempotent: safe to re-run.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

if command -v nvidia-smi >/dev/null 2>&1 && nvidia-smi >/dev/null 2>&1; then
    echo ">>> NVIDIA driver already working:"
    nvidia-smi | sed -n '3,5p'
else
    echo ">>> Installing nvidia-driver-610 + nvidia-prime (Ubuntu repos ONLY)"
    sudo apt update
    sudo apt install -y "linux-headers-$(uname -r)"
    sudo apt install -y nvidia-driver-610 nvidia-prime
    sudo prime-select on-demand
fi

echo ">>> Applying display configs"
sudo mkdir -p /etc/sddm.conf.d /etc/X11/xorg.conf.d /etc/modprobe.d
sudo cp "$ROOT/configs/etc/sddm.conf.d/10-force-x11.conf"         /etc/sddm.conf.d/
sudo cp "$ROOT/configs/etc/X11/xorg.conf.d/10-nvidia-primary.conf" /etc/X11/xorg.conf.d/
sudo cp "$ROOT/configs/etc/modprobe.d/nvidia-drm-modeset.conf"      /etc/modprobe.d/
sudo update-initramfs -u
sudo systemctl enable --now sddm

echo
echo ">>> If nvidia-smi fails after the next reboot, check Secure Boot:"
echo ">>>   mokutil --sb-state   (disable Secure Boot in BIOS if enabled)"
echo ">>> Reboot now:  sudo reboot"
