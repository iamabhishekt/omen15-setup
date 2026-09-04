#!/usr/bin/env bash
# DGX-style container stack: Docker CE + NVIDIA Container Toolkit.
set -euo pipefail

echo ">>> Installing Docker CE"
sudo apt update
sudo apt install -y ca-certificates curl gnupg
sudo install -m 0755 -d /etc/apt/keyrings
if curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg; then
    sudo chmod a+r /etc/apt/keyrings/docker.gpg
    CODENAME="$(. /etc/os-release && echo "$VERSION_CODENAME")"
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $CODENAME stable" \
        | sudo tee /etc/apt/sources.list.d/docker.list >/dev/null
    if ! sudo apt update; then
        echo ">>> Docker repo has no '$CODENAME' yet — falling back to Ubuntu's docker.io"
        sudo rm -f /etc/apt/sources.list.d/docker.list
        sudo apt update
        sudo apt install -y docker.io docker-compose-v2 || sudo apt install -y docker.io
    else
        sudo apt install -y docker-ce docker-ce-cli containerd.io \
            docker-buildx-plugin docker-compose-plugin
    fi
else
    echo ">>> Could not reach Docker's repo — installing Ubuntu's docker.io"
    sudo apt install -y docker.io docker-compose-v2 || sudo apt install -y docker.io
fi
sudo usermod -aG docker "$USER"

echo ">>> NVIDIA Container Toolkit"
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey \
    | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg
curl -fsSL https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list \
    | sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' \
    | sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list >/dev/null
sudo apt update
sudo apt install -y nvidia-container-toolkit
sudo nvidia-ctk runtime configure --runtime=docker
sudo systemctl restart docker
sudo nvidia-smi -pm 1 || true   # persistence mode

echo ">>> Testing GPU inside a container"
sudo docker run --rm --gpus all ubuntu nvidia-smi || {
    echo ">>> Container GPU test failed — check: docker info, nvidia-ctk runtime configure"
}
echo ">>> Remember: re-login (or reboot) once for passwordless docker (docker group)."
echo ">>> NGC PyTorch container (optional, ~10 GB):"
echo ">>>   docker run --rm -it --gpus all nvcr.io/nvidia/pytorch:latest"
