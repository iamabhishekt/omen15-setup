#!/usr/bin/env bash
# Post-install verification — every check prints PASS or FAIL.
set -uo pipefail

pass() { echo "PASS  $1"; }
fail() { echo "FAIL  $1"; }

nvidia-smi >/dev/null 2>&1 && pass "nvidia-smi (kernel driver loaded)" || fail "nvidia-smi"
dkms status 2>/dev/null | grep -q "installed" && pass "dkms module installed" || fail "dkms"
systemctl is-active --quiet sddm && pass "sddm active" || fail "sddm"
[ "$(cat /etc/X11/default-display-manager 2>/dev/null)" = "/usr/bin/sddm" ] \
    && pass "sddm is default display manager" || fail "default-display-manager"
[ -x /usr/local/cuda/bin/nvcc ] && pass "nvcc ($(nvcc --version | tail -1 | awk '{print $5}'))" || fail "nvcc not on disk"
grep -q '/usr/local/cuda/bin' ~/.bashrc 2>/dev/null && pass "cuda PATH in .bashrc" || fail "cuda PATH"
command -v glxinfo >/dev/null && pass "mesa-utils (glxinfo)" || fail "glxinfo missing"
snap list >/dev/null 2>&1 && fail "snapd still installed" || pass "no snap"
command -v steam >/dev/null && pass "steam (deb)" || fail "steam missing"
command -v gamemode >/dev/null && pass "gamemode" || fail "gamemode missing"
command -v mangohud >/dev/null && pass "mangohud" || fail "mangohud missing"
sudo docker info >/dev/null 2>&1 && pass "docker running" || fail "docker"
sudo docker info 2>/dev/null | grep -q nvidia && pass "docker nvidia runtime" || fail "docker nvidia runtime"
[ -x "$HOME/ml/bin/python" ] && pass "~/ml venv exists" || fail "~/ml venv"
"$HOME/ml/bin/python" -c "import torch,sys; sys.exit(0 if torch.cuda.is_available() else 1)" 2>/dev/null \
    && pass "torch.cuda.is_available()" || fail "torch CUDA"
"$HOME/ml/bin/python" -c "import numpy" 2>/dev/null && pass "numpy" || fail "numpy (pip install numpy into ~/ml)"
prime-select query 2>/dev/null | grep -q on-demand && pass "prime-select on-demand" || fail "prime-select"

echo
echo "Run these INSIDE a Plasma session (Konsole) for display checks:"
echo "  glxinfo | grep 'OpenGL renderer'"
echo "  __NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia glxinfo | grep renderer"
echo "  xrandr    # should list panel + external HP monitor"
