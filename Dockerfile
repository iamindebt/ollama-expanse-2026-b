FROM python:3.12-slim

LABEL org.opencontainers.image.title="ollama-expanse-2026-b" \
      org.opencontainers.image.description="Latest Ollama version compatible with SDSC Expanse V100s" \
      org.opencontainers.image.source="https://github.com/iamindebt/ollama-expanse-2026-b"

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash curl ca-certificates git jq procps pciutils zstd gnupg \
    && rm -rf /var/lib/apt/lists/*

RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g opencode-ai@latest @modelcontextprotocol/server-brave-search@0.6.2 && \
    npm cache clean --force

RUN curl -fsSL https://ollama.com/download/ollama-linux-amd64.tar.zst \
    | tar --zstd -x -C /usr/local

COPY requirements.txt constraints.txt /tmp/

RUN python -m pip install --upgrade pip && \
    python -m pip install torch==2.14.1+cu126 torchvision torchaudio \
        --index-url https://download.pytorch.org/whl/cu126 && \
    python -m pip install -r /tmp/requirements.txt \
        -c /tmp/constraints.txt && \
    python -m pip check && \
    rm /tmp/requirements.txt /tmp/constraints.txt

RUN node --version && npm --version && opencode --version

RUN python -c "import torch, torchvision, torchaudio; print('PyTorch:', torch.__version__); print('CUDA:', torch.version.cuda); print('Torchvision:', torchvision.__version__); print('Torchaudio:', torchaudio.__version__)"

CMD ["/bin/bash"]
