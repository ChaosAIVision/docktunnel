# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

DockTunnel is a containerized GPU development environment designed for remote AI/ML work on platforms like Vast.ai. It provides a lightweight Ubuntu base with Conda, SSH access, Jupyter Lab, and Cloudflare tunneling for secure remote IDE connections.

## Key Commands

### Building and Running
```bash
# Quick deploy (from project root) - x86_64
./deploy.sh

# Manual build and start - x86_64
cd deploy
docker-compose build
docker-compose up -d

# Build for ARM64 (aarch64) - use this branch
cd deploy
docker-compose build
docker-compose up -d

# Or specify platform explicitly
docker buildx build --platform linux/arm64 -f deploy/Dockerfile -t docktunnel-dev:aarch64 ..

# View logs
docker-compose logs -f
docker-compose logs cloudflared-quick | grep trycloudflare.com  # Get tunnel URL

# Stop services
docker-compose down
```

### Development Access
```bash
# SSH into container (local access)
ssh -p 2222 root@localhost

# Execute commands in container
docker exec -it docktunnel-dev bash

# Check GPU status
docker exec docktunnel-dev nvidia-smi
```

### Conda Environment Setup
The base image is intentionally lightweight (~500MB). Install ML frameworks via Conda:
```bash
# Inside container
conda create -n docktunnel python=3.10 -y
conda activate docktunnel
conda install pytorch torchvision torchaudio pytorch-cuda=12.4 -c pytorch -c nvidia -y
```

A template script is available at `/workspace/setup_cuda_env.sh` inside the container.

## Architecture

### Container Services
- **dev**: Main development container with GPU access, SSH, Jupyter Lab
- **cloudflared-quick**: Cloudflare tunnel for secure external access (generates random trycloudflare.com URL)

### Port Mappings
- `2222` → SSH (container port 22)
- `8886` → Jupyter Lab (container port 8888)
- `6006` → TensorBoard
- `6785` → General web server (container port 8000)

### Volume Structure
- `/workspace` - Docker named volume (persistent workspace)
- `/models` - Docker named volume (model storage)
- `/datasets` - Docker named volume (dataset storage)
- `/root/data` - Mounted from `./data` in project root

### Connection Methods
1. **Local**: Direct SSH via `localhost:2222`
2. **Tunnel**: Via Cloudflare Quick Tunnel URL (requires `cloudflared` installed locally)

For tunnel access, configure `~/.ssh/config`:
```
Host docktunnel
    HostName [PASTE_TUNNEL_URL]
    User root
    ProxyCommand cloudflared access tcp --hostname %h
    IdentityFile ~/.ssh/id_ed25519
```

## Architecture-Specific Builds

### ARM64 (aarch64) Branch
This branch (`aarch`) is configured for ARM64 systems (like Apple Silicon, AWS Graviton, etc.).

**Key changes:**
- Miniconda download URL uses `Miniconda3-latest-Linux-aarch64.sh`

**Build commands:**
```bash
# On ARM64 system
cd deploy
docker-compose build
docker-compose up -d

# Cross-compile from x86_64 to ARM64
docker buildx build --platform linux/arm64 -f deploy/Dockerfile -t docktunnel-dev:aarch64 ..
```

## Important Files
- `deploy/Dockerfile`: Base image definition (Ubuntu 22.04 + Conda + SSH)
- `deploy/docker-compose.yml`: Service orchestration with GPU support
- `deploy/entrypoint.sh`: Container startup script (starts SSH, Jupyter)
- `deploy.sh`: Quick deployment script with validation
- `requirements.txt`: Template for Python dependencies (commented out by default)

## Environment Configuration
Copy `.env.example` to `.env` before first deployment. Default root password: `docktunnel2026`

## Security Notes
- SSH key authentication recommended over password
- Change default root password after first login
- For production, consider using Named Tunnel instead of Quick Tunnel
