FROM --platform=linux/amd64 nvidia/cuda:12.4.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PIP_EXTRA_INDEX_URL=https://download.pytorch.org/whl/cu128

# System dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 python3-pip git curl ffmpeg ca-certificates \
    libgl1 libglib2.0-0 \
    && rm -rf /var/lib/apt/lists/*

# Install Latest Torch (2026 Stack)
RUN pip3 install --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128

# Clone and install ACE-Step 1.5 from source
WORKDIR /src
RUN git clone https://github.com/ACE-Step/ACE-Step-1.5.git . && \
    pip3 install -e .

# Install additional requirements
RUN pip3 install runpod soundfile

# App Layer
WORKDIR /app
COPY handler.py .

# Pre-download weights (optional, can be done in entrypoint)
ENV HF_HOME=/root/.cache/huggingface

CMD ["python3", "-u", "handler.py"]
