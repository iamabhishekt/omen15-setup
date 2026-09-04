# Bazzite-style command runner for this machine.
# Run `just --list` to see everything.

default:
    @just --list

# --- setup (same as scripts/, in bootstrap order) ---

base:
    ./scripts/00-base.sh

nvidia:
    ./scripts/01-nvidia.sh

ml:
    ./scripts/02-ml.sh

dgx:
    ./scripts/03-dgx-docker.sh

gaming:
    ./scripts/04-gaming.sh

jetbrains:
    ./scripts/05-jetbrains.sh

devtools:
    ./scripts/06-devtools.sh

desktop:
    ./scripts/07-desktop.sh

kde:
    ./scripts/08-kde-desktop.sh

bazzite:
    ./scripts/09-bazzite-gaming.sh

proton-ge:
    ./scripts/10-proton-ge.sh

gamescope-session:
    ./scripts/11-gamescope-session.sh

distrobox:
    ./scripts/12-distrobox-just.sh

cli:
    ./scripts/13-dev-cli.sh

agents:
    ./scripts/14-ai-agents.sh

verify:
    ./scripts/verify.sh

# --- desktop snapshots ---

capture:
    ./scripts/capture-kde-config.sh

apply-kde:
    ./scripts/apply-kde-config.sh

# --- daily drivers ---

update:
    sudo apt update && sudo apt full-upgrade -y && sudo apt autoremove -y

gpu:
    nvidia-smi

temp:
    sensors 2>/dev/null || sudo apt install -y lm-sensors && sensors
