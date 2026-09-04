#!/usr/bin/env bash
# ML stack: CUDA toolkit on PATH + PyTorch venv at ~/ml
set -euo pipefail

if [ ! -x /usr/local/cuda/bin/nvcc ]; then
    echo ">>> CUDA toolkit not found at /usr/local/cuda — install it first (see README)"
    exit 1
fi

grep -q '/usr/local/cuda/bin' ~/.bashrc || \
    echo 'export PATH=/usr/local/cuda/bin:$PATH' >> ~/.bashrc

echo ">>> Creating/refreshing ~/ml venv"
python3 -m venv ~/ml
~/ml/bin/pip install --upgrade pip
~/ml/bin/pip install torch numpy

echo ">>> Smoke test"
~/ml/bin/python -c "import torch; print('CUDA available:', torch.cuda.is_available()); print(torch.cuda.get_device_name(0))"
