#!/usr/bin/env bash
# AI agent CLIs — mirrors the reference MacBook setup.
# Requires 06-devtools.sh (Node.js) to have run first.
set -euo pipefail

command -v node >/dev/null 2>&1 || { echo ">>> Run 06-devtools.sh first (Node.js required)"; exit 1; }

# Install user-global (no sudo for npm -g)
npm config set prefix "$HOME/.local"
grep -q '.local/bin' ~/.bashrc || echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc
[ -f ~/.zshrc ] && grep -q '.local/bin' ~/.zshrc || true

echo ">>> npm-based agents (codex, kimi, qwen, arkcli, ark-helper, ...)"
npm install -g \
    @openai/codex \
    @moonshot-ai/kimi-code \
    @byted-aml/ark-helper \
    @volcengine/ark-cli \
    @qwen-code/qwen-code \
    @jackwener/opencli \
    @musistudio/claude-code-router \
    bailian-cli \
    byterover-cli \
    mcporter \
    gitnexus \
    deckrun \
    ecc-universal \
    plumb-mcp \
    opencode-ai

echo ">>> Claude Code (native installer -> ~/.local/bin/claude)"
curl -fsSL https://claude.ai/install.sh | bash

echo ">>> Cursor CLI / cursor-agent (native installer)"
curl -fsSL https://cursor.com/install | bash || echo ">>> cursor-agent install failed — see cursor.com/download"

echo ">>> DeepSeek Harness (dsh) -> ~/.local (separate prefix, like the Mac)"
npm install -g --prefix "$HOME/.local" @deepseek-ai/dsh

echo
echo ">>> Installed CLIs: claude, codex, kimi, dsh, opencode, cursor-agent, arkcli,"
echo ">>>   ark-helper, qwen, opencli, ccr(claude-code-router), bailian, byterover..."
echo ">>> GUI IDEs (Cursor / TRAE / TRAE SOLO / CodeBuddy CN / ZCode / Warp):"
echo ">>>   download the Linux .deb from each vendor and run:"
echo ">>>     ./scripts/install-deb.sh /path/or/url/to/app.deb"
echo ">>> Not present on the reference Mac: hermes, workbuddy — add manually if needed."
echo ">>> Each agent needs its own login/API key afterwards."
