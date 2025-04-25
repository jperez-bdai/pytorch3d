# Build arguments
ARG CUDA_VER=12.4.1
ARG UBUNTU_VER=22.04
ARG ARCH=linux/amd64

# Available cuda images can be found at https://hub.docker.com/r/nvidia/cuda/tags
# Download the base image
FROM --platform=${ARCH} nvidia/cuda:${CUDA_VER}-cudnn-devel-ubuntu${UBUNTU_VER}

# Install as root
USER root

# Set the pipefail option to fail early in the pipeline
SHELL ["/bin/bash", "-o", "pipefail", "-c"]

# Python version
ARG PYTHON_VER=3.10

# Install dependencies
ARG DEBIAN_FRONTEND="noninteractive"
ENV LANG="C.UTF-8"
ENV LC_ALL="C.UTF-8"
ENV NVM_DIR="/usr/local/nvm"
ENV POETRY_VIRTUALENVS_CREATE=false

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    bash \
    bash-completion \
    curl \
    git \
    wget \
    sudo \
    tzdata \
    unzip \
    usbutils \
    nvtop \
    ca-certificates \
    libgl1-mesa-dri \
    libgl1-mesa-glx \
    libssl-dev \
    libffi-dev \
    x11-utils \
    x11vnc \
    xvfb \
    xz-utils \
    zenity \
    zip \
    python${PYTHON_VER} \
    python${PYTHON_VER}-dev \
    python3-pip \
    python-is-python3 \
    python3.10-venv \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Set environment variables
ENV PATH="/root/.local/bin:$PATH"
ENV PYTHON_VERSION=${PYTHON_VER}

# GitHub token
ARG GITHUB_TOKEN
RUN echo "machine github.com login $GITHUB_TOKEN" > $HOME/.netrc

# Set the working directory
WORKDIR /inside
COPY ./ /inside/

RUN mkdir -p /conda_cache

# Installing conda:
RUN mkdir -p ~/miniconda3
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
RUN bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
RUN rm ~/miniconda3/miniconda.sh
RUN source ~/miniconda3/bin/activate
