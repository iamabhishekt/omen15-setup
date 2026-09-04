#!/usr/bin/env bash
# Dev tooling: GitHub CLI (official apt repo) + Node.js (NodeSource, deb).
set -euo pipefail

echo ">>> GitHub CLI"
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    | sudo tee /usr/share/keyrings/githubcli-archive-keyring.gpg >/dev/null
sudo chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
    | sudo tee /etc/apt/sources.list.d/github-cli.list >/dev/null
sudo apt update
sudo apt install -y gh

echo ">>> Node.js via NodeSource (falls back to Ubuntu's package)"
if curl -fsSL https://deb.nodesource.com/setup_24.x | sudo -E bash -; then
    sudo apt install -y nodejs
else
    echo ">>> NodeSource unavailable — using Ubuntu's nodejs/npm"
    sudo apt install -y nodejs npm
fi

echo ">>> Authenticate gh:"
echo ">>>   gh auth login"
