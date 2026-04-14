FROM --platform=linux/amd64 nvidia/cuda:12.4.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PIP_EXTRA_INDEX_URL=https://download.pytorch.org/whl/cu128

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip git curl ffmpeg ca-certificates \
    libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install Torch (Standard Pip Install)
RUN pip3 install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu128

# Install ACE-Step & nano-vllm (Standard Pip Install)
RUN pip3 install git+https://github.com/GeeeekExplorer/nano-vllm.git
RUN pip3 install git+https://github.com/ACE-Step/ACE-Step-1.5.git

# Install additional requirements
RUN pip3 install runpod soundfile

# App Layer
WORKDIR /app
COPY handler.py .

# Pre-download weights (optional, can be done in entrypoint)
ENV HF_HOME=/root/.cache/huggingface

CMD ["python3", "-u", "handler.py"]
