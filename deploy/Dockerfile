# Lightweight base image - CUDA will be installed via Conda
FROM ubuntu:22.04

# Prevent interactive prompts during build
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /workspace

# Install system dependencies
RUN apt-get update && apt-get install -y \
    # SSH server for VSCode/Cursor remote development
    openssh-server \
    # Development tools
    git \
    curl \
    wget \
    vim \
    nano \
    htop \
    tmux \
    screen \
    # Build essentials
    build-essential \
    cmake \
    # Additional utilities
    sudo \
    ca-certificates \
    bzip2 \
    && rm -rf /var/lib/apt/lists/*

# Install Miniconda
RUN wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O /tmp/miniconda.sh && \
    bash /tmp/miniconda.sh -b -p /opt/conda && \
    rm /tmp/miniconda.sh

# Add conda to PATH
ENV PATH="/opt/conda/bin:${PATH}"

# Initialize conda and configure to use conda-forge (no ToS required)
RUN /opt/conda/bin/conda init bash && \
    /opt/conda/bin/conda config --add channels conda-forge && \
    /opt/conda/bin/conda config --remove channels defaults && \
    /opt/conda/bin/conda config --set channel_priority strict

# Install minimal Python packages (users will install ML/AI packages via conda)
RUN /opt/conda/bin/pip install --no-cache-dir \
    # Jupyter (optional - comment out if not needed)
    jupyterlab \
    ipywidgets \
    # Development tools
    black \
    flake8 \
    pytest \
    ipdb

# Create conda environment template script
RUN echo '#!/bin/bash' > /workspace/setup_cuda_env.sh && \
    echo '# Example: Create conda environment with CUDA support' >> /workspace/setup_cuda_env.sh && \
    echo '' >> /workspace/setup_cuda_env.sh && \
    echo '# Option 1: PyTorch with CUDA 12.4' >> /workspace/setup_cuda_env.sh && \
    echo '# conda create -n pytorch python=3.10 -y' >> /workspace/setup_cuda_env.sh && \
    echo '# conda activate pytorch' >> /workspace/setup_cuda_env.sh && \
    echo '# conda install pytorch torchvision torchaudio pytorch-cuda=12.4 -c pytorch -c nvidia -y' >> /workspace/setup_cuda_env.sh && \
    echo '' >> /workspace/setup_cuda_env.sh && \
    echo '# Option 2: TensorFlow with CUDA' >> /workspace/setup_cuda_env.sh && \
    echo '# conda create -n tensorflow python=3.10 -y' >> /workspace/setup_cuda_env.sh && \
    echo '# conda activate tensorflow' >> /workspace/setup_cuda_env.sh && \
    echo '# pip install tensorflow[and-cuda]' >> /workspace/setup_cuda_env.sh && \
    echo '' >> /workspace/setup_cuda_env.sh && \
    echo '# Option 3: Full ML environment with CUDA' >> /workspace/setup_cuda_env.sh && \
    echo '# conda create -n ml python=3.10 cudatoolkit=12.4 -c conda-forge -y' >> /workspace/setup_cuda_env.sh && \
    echo '# conda activate ml' >> /workspace/setup_cuda_env.sh && \
    echo '# conda install pytorch torchvision torchaudio pytorch-cuda=12.4 -c pytorch -c nvidia -y' >> /workspace/setup_cuda_env.sh && \
    echo '# conda install numpy pandas scikit-learn matplotlib seaborn -y' >> /workspace/setup_cuda_env.sh && \
    chmod +x /workspace/setup_cuda_env.sh

# Configure SSH
RUN mkdir /var/run/sshd && \
    # Allow root login (for development only)
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    # Disable password authentication (use SSH keys)
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    # Enable public key authentication
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

# Set root password (change this or use SSH keys only)
RUN echo 'root:docktunnel2026' | chpasswd

# Create workspace directories
RUN mkdir -p /workspace /models /datasets

# Expose ports
EXPOSE 22 8888 6006 8000

# Copy startup script
COPY deploy/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Set entrypoint
ENTRYPOINT ["/entrypoint.sh"]

# Default command
CMD ["/bin/bash"]
