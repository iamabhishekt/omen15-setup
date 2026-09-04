# HP Omen 15 — Ubuntu 26.04 "DGX-style" ML + Gaming Workstation

Debloated Ubuntu Server 26.04 + minimal KDE Plasma + NVIDIA RTX 3070 + CUDA 13.3.
No snap. No flatpak. Debian packages only (Steam/JetBrains where no deb exists use
the vendor's own official distribution).

## Hardware

| Part | Value |
|---|---|
| Laptop | HP Omen 15 |
| CPU | Intel i7 (Comet Lake, i915 iGPU) |
| dGPU | NVIDIA RTX 3070 Laptop GPU (GA104M) |
| RAM | 64 GB |
| Disks | 1 TB NVMe (OS) + 512 GB NVMe (/games) |
| Displays | Internal panel + external HP monitor on DP-1 |

**Important hardware quirk:** the panel and the external DP monitor are wired
directly to the RTX 3070 (MUX / dGPU-direct mode), NOT through the Intel iGPU.
All display config below follows from that.

## Architecture (the decisions that matter)

1. **NVIDIA driver comes from Ubuntu repos ONLY** (`nvidia-driver-610`).
   The NVIDIA CUDA repo's `cuda-drivers` does *not* ship `xserver-xorg-video-nvidia`,
   which caused "Starting the display server on vt 1 failed" and
   "modeset(0): Failed to create pixmap" crashes.
2. **CUDA toolkit comes from NVIDIA's repo** (`/usr/local/cuda`), but the CUDA apt
   repo is **disabled after install** so apt can never mix the two driver versions
   again (that mix wedges dpkg with `libnvidia-cfg.so.1` file conflicts).
3. **SDDM runs an X11 greeter** (`DisplayServer=x11`) — the Wayland greeter was
   part of the original failure loop.
4. **NVIDIA is the primary X GPU** — panel + monitor are on the 3070.
5. **PRIME on-demand** — Intel handles the desktop, 3070 wakes for offload +
   is the display GPU. `nvidia-drm modeset=1` is required.

## Layout

```
scripts/
  00-base.sh        essentials, purge snap/flatpak, old-kernel cleanup
  01-nvidia.sh      driver 610 + all display configs (idempotent)
  02-ml.sh          CUDA PATH + ~/ml venv + PyTorch
  03-dgx-docker.sh  Docker CE + NVIDIA Container Toolkit + GPU container test
  04-gaming.sh       Steam (official .deb) + gamemode + mangohud + Vulkan
  05-jetbrains.sh   JetBrains Toolbox (official tarball, self-contained)
  06-devtools.sh    gh CLI (apt) + Node.js (NodeSource)
  07-desktop.sh     lid-close config + KDE dark theme
  verify.sh         PASS/FAIL checklist of the whole machine
configs/etc/        the exact files applied to /etc (sddm, xorg, modprobe, logind)
```

## Fresh-install bootstrap order

After installing Ubuntu Server 26.04 (no snaps selected, OpenSSH server on):

```bash
sudo apt update && sudo apt full-upgrade -y
sudo apt install -y --no-install-recommends kde-plasma-desktop sddm \
    konsole dolphin xserver-xorg sddm-theme-breeze

# CUDA toolkit from NVIDIA repo (one time; repo gets disabled afterwards):
#   see README section "CUDA toolkit install" below
git clone https://github.com/iamabhishekt/omen15-setup && cd omen15-setup
./scripts/00-base.sh
./scripts/01-nvidia.sh
sudo reboot
./scripts/02-ml.sh
./scripts/03-dgx-docker.sh
./scripts/04-gaming.sh
./scripts/06-devtools.sh
./scripts/07-desktop.sh
./scripts/verify.sh
./scripts/05-jetbrains.sh   # run inside the desktop session
```

## CUDA toolkit install (NVIDIA repo, one time)

```bash
cd /tmp
wget https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2604/x86_64/cuda-keyring_1.1-1_all.deb
sudo dpkg -i cuda-keyring_1.1-1_all.deb
sudo apt update && sudo apt install -y cuda-toolkit
# Then DISABLE the repo so it can never mix driver packages again:
for f in /etc/apt/sources.list.d/cuda*.list; do sudo mv "$f" "$f.disabled"; done
sudo apt update
```

## Manual finishing steps

- **Steam → Settings → Compatibility → "Enable Steam Play for all other titles"**
  (this is Proton; it ships inside Steam, nothing extra to install).
- **Lid close:** logind already ignores it. Also open
  *System Settings → Power Management → Energy Saving* and set
  "When lid closed" to *Do nothing* so Plasma doesn't suspend either.
- **Dark theme:** `lookandfeeltool --apply org.kde.breezedark.desktop`
  inside the session (07-desktop.sh does this).
- **Docker group:** log out/in once (`newgrp docker` or reboot) to use docker
  without sudo.

## Verification

```bash
./scripts/verify.sh
```
Green across the board = driver, display, containers, ML stack all healthy.

## Debug playbook (everything that already bit us)

| Symptom | Cause | Fix |
|---|---|---|
| SDDM loops "Starting the display server on vt 1 failed" | Wayland greeter broken on hybrid NVIDIA; or X driver missing | `configs/etc/sddm.conf.d/10-force-x11.conf` + install `nvidia-driver-610` |
| Xorg log: `Failed to load module "nvidia"` | `cuda-drivers` repo lacks `xserver-xorg-video-nvidia` | install Ubuntu's `nvidia-driver-610` |
| Xorg log: `modeset(G0): Failed to create pixmap` | modesetting driver on the 3070 instead of nvidia driver | `configs/etc/X11/xorg.conf.d/10-nvidia-primary.conf` |
| dpkg wedged: `libnvidia-cfg.so.1 overwrite` conflict | Ubuntu 610.43.02 + CUDA repo 610.57.04 installed together | purge unversioned leftovers: `dpkg -l \| awk '/^ii/ && $2 ~ /^(lib)?nvidia/ {print $2}' \| grep -v -- '-[0-9]' \| sudo xargs -r dpkg --purge --force-all`, then `sudo apt --fix-broken install` |
| `nvidia-smi` fails but `dkms status` says installed | Secure Boot rejecting unsigned module | disable Secure Boot in BIOS or enroll MOK (`mokutil --sb-state` to check) |

First commands for any new graphics problem:

```bash
nvidia-smi
sudo journalctl -u sddm -b --no-pager | tail -50
sudo grep -E '\(EE\)' /var/log/Xorg.0.log
dkms status
```
