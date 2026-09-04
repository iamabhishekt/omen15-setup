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
  00-base.sh        essentials, Firefox (Mozilla apt), purge snap/flatpak
  01-nvidia.sh      driver 610 + all display configs (idempotent)
  02-ml.sh          CUDA PATH + ~/ml venv + PyTorch
  03-dgx-docker.sh  Docker CE + NVIDIA Container Toolkit + GPU container test
  04-gaming.sh       Steam (official .deb) + gamemode + mangohud + Vulkan
  05-jetbrains.sh   JetBrains Toolbox (official tarball, self-contained)
  06-devtools.sh    gh CLI (apt) + Node.js (NodeSource) + git identity
  07-desktop.sh     lid-close config + KDE dark theme
  08-kde-desktop.sh Bazzite-style polish: wallpaper, lockscreen, tearing, night color
  09-bazzite-gaming.sh  gamescope, OBS, CoreCtrl, OpenRGB, btop, fastfetch
  10-proton-ge.sh       latest GE-Proton into Steam compatibilitytools
  11-gamescope-session.sh  console-like Steam session (experimental)
  12-distrobox-just.sh  distrobox + just
  13-dev-cli.sh      omarchy-style CLI toolkit: kitty, zsh, starship, fzf,
                     ripgrep, fd, bat, eza, zoxide, delta, lazygit, neovim
  14-ai-agents.sh    claude, codex, kimi, dsh, opencode, cursor-agent, arkcli,
                     ark-helper, qwen, opencli, ccr, bailian, byterover, ...
  install-deb.sh     install any vendor .deb (Cursor/TRAE/CodeBuddy/ZCode/Warp)
  capture-kde-config.sh  snapshot YOUR arranged desktop into the repo
  apply-kde-config.sh    restore that arrangement on any machine
  verify.sh         PASS/FAIL checklist of the whole machine
Justfile            `just <recipe>` shortcuts for everything above
configs/etc/        the exact files applied to /etc (sddm, xorg, modprobe, logind)
configs/home/       zshrc (starship/zoxide/fzf/aliases)
configs/wallpapers/ shipped dark wallpaper (used by desktop + lockscreen)
configs/kde/        captured KDE settings (created by capture-kde-config.sh)
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
./scripts/08-kde-desktop.sh     # inside the session: wallpaper, lockscreen, tearing
./scripts/09-bazzite-gaming.sh  # gamescope, OBS, CoreCtrl, OpenRGB
./scripts/10-proton-ge.sh       # GE-Proton into Steam
./scripts/12-distrobox-just.sh
./scripts/13-dev-cli.sh          # kitty, zsh+starship, fzf, ripgrep, lazygit...
./scripts/14-ai-agents.sh        # claude, codex, kimi, dsh, opencode, arkcli...
./scripts/verify.sh
./scripts/05-jetbrains.sh   # run inside the desktop session
# optional / experimental:
./scripts/11-gamescope-session.sh   # console-like Steam session at SDDM
```

## AI agents & IDEs

CLI agents (`14-ai-agents.sh`, mirrors the reference MacBook): claude, codex,
kimi (`@moonshot-ai/kimi-code`), dsh (DeepSeek Harness), opencode,
cursor-agent, arkcli + ark-helper (`arkcli helper`), qwen-code, opencli,
claude-code-router (ccr), bailian, byterover, mcporter, gitnexus, deckrun,
ecc-universal, plumb-mcp. `hermes` and `workbuddy` are NOT on the reference
Mac — add manually if you find installers.

GUI IDEs have no apt repo — download the Linux .deb from each vendor and:

```bash
./scripts/install-deb.sh ~/Downloads/cursor.deb     # or a URL
```

| App | Download |
|---|---|
| Cursor | cursor.com/download |
| TRAE / TRAE SOLO | trae.ai |
| CodeBuddy CN | codebuddy.tencent.com (or its download page) |
| ZCode | vendor site |
| Warp | warp.dev/download |
| JetBrains | `05-jetbrains.sh` (Toolbox, then IDEs from its GUI) |

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

## Git identity — keep the office account out

This is a **personal repo**. All commits are authored with the GitHub noreply
email (`85431526+iamabhishekt@users.noreply.github.com`) so no other email
can ever leak into history.

On a machine that also has the office git config (like the MacBook), use
repo-local settings so they override the global office identity:

```bash
cd omen15-setup
git config user.name  "iamabhishekt"
git config user.email "85431526+iamabhishekt@users.noreply.github.com"
```

On the Omen (personal machine), set it globally instead:

```bash
git config --global user.name  "iamabhishekt"
git config --global user.email "85431526+iamabhishekt@users.noreply.github.com"
gh auth login             # log in as iamabhishekt
gh auth switch --user iamabhishekt   # if multiple accounts exist
```

Verify before pushing: `git log --format='%an %ae'` must never show a
non-personal email. `06-devtools.sh` sets the global identity if unset.

## Bazzite parity map

| Bazzite feature | Here |
|---|---|
| Steam + Proton | `04-gaming.sh` (Steam deb, Proton bundled) |
| Proton GE builds | `10-proton-ge.sh` |
| Gamescope | `09-bazzite-gaming.sh` (per-game: `gamescope -- %command%`) |
| Console-like Steam session | `11-gamescope-session.sh` (experimental, own SDDM entry) |
| GameMode / MangoHud | `04-gaming.sh` (`gamemoderun %command%`, `mangohud %command%`) |
| OBS Studio | `09-bazzite-gaming.sh` |
| CoreCtrl hardware control | `09-bazzite-gaming.sh` + polkit rule |
| OpenRGB | `09-bazzite-gaming.sh` |
| Distrobox containers | `12-distrobox-just.sh` (docker backend) |
| `just` recipes | `Justfile` — run `just --list` |
| fastfetch / btop terminals | `09-bazzite-gaming.sh` |
| Dark KDE + wallpapers + lockscreen | `08-kde-desktop.sh` |
| Immutable OS / OSTree updates | N/A — standard apt Ubuntu (`just update`) |

## Desktop polish (Bazzite-style) — the two-step personalization loop

1. `./scripts/08-kde-desktop.sh` applies the baseline: Breeze Dark, dark
   wallpaper on desktop **and lockscreen**, auto-lock after 10 min +
   lock-on-suspend, compositor tearing allowed (smoothest fullscreen gaming),
   Night Color on, numlock at the login screen.
2. Then arrange the desktop by hand — panel position, pinned taskbar apps,
   shortcuts, whatever you like — and run:

```bash
./scripts/capture-kde-config.sh    # snapshots ~/.config KDE files into configs/kde/
git add -A && git commit -m "kde: capture desktop arrangement" && git push
```

From then on, `./scripts/apply-kde-config.sh` reproduces your exact desktop
on any reinstall. Re-capture after any big arrangement change.

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
