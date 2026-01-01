#!/bin/bash

# DockTunnel Development Environment - Quick Deploy Script
# This script helps you quickly deploy the development environment

set -e

echo "=========================================="
echo "🚀 DockTunnel Development Environment Setup"
echo "=========================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running as root on Vast.ai
if [ "$EUID" -eq 0 ]; then 
    echo -e "${GREEN}✓${NC} Running as root (Vast.ai detected)"
else
    echo -e "${YELLOW}⚠${NC} Not running as root. Some features may not work."
fi

# Check Docker
if ! command -v docker &> /dev/null; then
    echo -e "${RED}✗${NC} Docker not found. Please install Docker first."
    exit 1
fi
echo -e "${GREEN}✓${NC} Docker found"

# Check Docker Compose
if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
    echo -e "${RED}✗${NC} Docker Compose not found. Please install Docker Compose first."
    exit 1
fi
echo -e "${GREEN}✓${NC} Docker Compose found"

# Check NVIDIA Docker runtime
if docker run --rm --gpus all nvidia/cuda:12.2.0-base-ubuntu22.04 nvidia-smi &> /dev/null; then
    echo -e "${GREEN}✓${NC} NVIDIA Docker runtime working"
else
    echo -e "${YELLOW}⚠${NC} NVIDIA Docker runtime not working. GPU may not be accessible."
fi

# Create .env if not exists
if [ ! -f .env ]; then
    echo -e "${YELLOW}⚠${NC} .env not found. Creating from .env.example..."
    cp .env.example .env
    echo -e "${GREEN}✓${NC} Created .env file. Please edit it with your settings."
fi

# Navigate to deploy directory
cd "$(dirname "$0")/deploy"

echo ""
echo "=========================================="
echo "🏗️  Building DockTunnel image..."
echo "=========================================="
docker-compose build

echo ""
echo "=========================================="
echo "🚀 Starting services..."
echo "=========================================="
docker-compose up -d

echo ""
echo "=========================================="
echo "⏳ Waiting for services to be ready..."
echo "=========================================="
sleep 5

# Check if container is running
if docker ps | grep -q docktunnel-dev; then
    echo -e "${GREEN}✓${NC} DockTunnel container is running"
else
    echo -e "${RED}✗${NC} DockTunnel container failed to start"
    docker-compose logs dev
    exit 1
fi

echo ""
echo "=========================================="
echo "🎉 Setup Complete! Welcome to DockTunnel"
echo "=========================================="
echo ""

# Get container IP
CONTAINER_IP=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' docktunnel-dev)

echo "📋 Connection Information:"
echo ""
echo "  SSH (Local):"
echo "    ssh -p 2222 root@localhost"
echo ""
echo "  Jupyter Lab:"
echo "    http://localhost:8886"
echo ""
echo "  TensorBoard:"
echo "    http://localhost:6006"
echo ""
echo "  Container IP: $CONTAINER_IP"
echo ""

# Check GPU
echo "🎮 GPU Status:"
docker exec docktunnel-dev nvidia-smi --query-gpu=index,name,memory.total,memory.free --format=csv,noheader 2>/dev/null || echo "  GPU info not available"
echo ""

echo "=========================================="
echo "📚 Next Steps:"
echo "=========================================="
echo ""
echo "1. Setup SSH key authentication:"
echo "   - Generate key: ssh-keygen -t ed25519"
echo "   - Copy to container: docker exec docktunnel-dev mkdir -p /root/.ssh"
echo "   - Add public key: docker exec docktunnel-dev bash -c 'echo \"YOUR_PUBLIC_KEY\" >> /root/.ssh/authorized_keys'"
echo ""
echo "2. Connect with VSCode/Cursor:"
echo "   - Install 'Remote - SSH' extension"
echo "   - Configure ~/.ssh/config as per README.md"
echo "   - Connect via Remote SSH"
echo ""
echo "3. View Tunnel URL:"
echo "   docker-compose logs cloudflared-quick | grep trycloudflare.com"
echo ""
echo "4. View logs:"
echo "   docker-compose logs -f"
echo ""
echo "=========================================="
