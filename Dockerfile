FROM --platform=linux/amd64 nvidia/cuda:12.4.1-runtime-ubuntu22.04

ENV DEBIAN_FRONTEND=noninteractive \
    PIP_NO_CACHE_DIR=1 \
    PYTHONUNBUFFERED=1 \
    PIP_EXTRA_INDEX_URL=https://download.pytorch.org/whl/nightly/cu128

# System dependencies (including Python 3.11)
RUN apt-get update && apt-get install -y --no-install-recommends \
    software-properties-common curl git ffmpeg ca-certificates \
    libgl1 libglib2.0-0 \
    && add-apt-repository ppa:deadsnakes/ppa \
    && apt-get update && apt-get install -y --no-install-recommends \
    python3.11 python3.11-dev python3.11-distutils \
    && rm -rf /var/lib/apt/lists/*

# Install pip for Python 3.11
RUN curl -sS https://bootstrap.pypa.io/get-pip.py | python3.11

# Set python3.11 as default
RUN ln -sf /usr/bin/python3.11 /usr/bin/python3 && \
    ln -sf /usr/bin/python3.11 /usr/bin/python

# Install uv for fast dependency management
RUN curl -LsSf https://astral.sh/uv/install.sh | sh
ENV PATH="/root/.local/bin:$PATH"

# Install Torch (2026 Stack)
RUN uv pip install --system --pre torch torchvision torchaudio --index-url https://download.pytorch.org/whl/nightly/cu128

# Clone and install ACE-Step 1.5
WORKDIR /src
RUN git clone https://github.com/ACE-Step/ACE-Step-1.5.git . && \
    uv pip install --system ./acestep/third_parts/nano-vllm && \
    uv pip install --system .

# Install additional requirements
RUN uv pip install --system runpod soundfile

# App Layer
WORKDIR /app
COPY handler.py .

# Pre-download weights
ENV HF_HOME=/root/.cache/huggingface

CMD ["python3", "-u", "handler.py"]
