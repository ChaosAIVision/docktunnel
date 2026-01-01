# 🚀 DockTunnel

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Docker](https://img.shields.io/badge/Docker-Enabled-blue?logo=docker)](https://www.docker.com/)
[![NVIDIA](https://img.shields.io/badge/NVIDIA-GPU_Ready-green?logo=nvidia)](https://www.nvidia.com/)

**DockTunnel** is a premium, containerized development environment designed for AI/ML engineers who need instant, secure, and high-performance access to remote GPU instances. It eliminates the friction of setting up SSH, CUDA, and IDE connections, allowing you to focus on building models.

---

## 🌟 Why DockTunnel?

Connecting to remote GPU instances (like Vast.ai, RunPod, or Lambda Labs) often involves complex firewall configurations or exposing insecure ports. **DockTunnel** solves this by:

1.  **Zero-Configuration Tunneling**: Uses Cloudflare Quick Tunnels to create an encrypted bridge to your container.
2.  **IDE-First Experience**: Optimized specifically for **VSCode** and **Cursor** Remote SSH.
3.  **Lean and Mean**: A ~500MB base image instead of the standard 5GB+ CUDA images. You install only what you need.
4.  **Persistent Storage**: Pre-configured volumes for your `/workspace`, `/models`, and `/datasets`.

---

## � Quick Start

### 1. Clone & Initialize
```bash
git clone https://github.com/ChaosAIVision/docktunnel.git
cd docktunnel

# Set up your environment (Default password: docktunnel2026)
cp .env.example .env
```

### 2. Spin Up the Environment
```bash
cd deploy
docker-compose up -d --build
```

### 3. Get Your Access Link
```bash
docker-compose logs cloudflared-quick | grep trycloudflare.com
```
*Copy the generated URL (e.g., `https://random-words.trycloudflare.com`).*

---

## 🔌 Connecting Your IDE (VSCode/Cursor)

### Step 1: Install `cloudflared` Locally
You need the Cloudflare daemon on your local machine to handle the tunnel:
- **Mac**: `brew install cloudflared`
- **Windows/Linux**: [Download here](https://developers.cloudflare.com/cloudflare-one/connections/connect-networks/downloads/)

### Step 2: Add SSH Config
Open your `~/.ssh/config` and add:

```ssh
Host docktunnel
    HostName [PASTE_YOUR_TUNNEL_URL_HERE]
    User root
    ProxyCommand cloudflared access tcp --hostname %h
    IdentityFile ~/.ssh/id_ed25519
```

### Step 3: Connect
1. Open VSCode or Cursor.
2. Press `Ctrl+Shift+P` (or `Cmd+Shift+P`).
3. Select **Remote-SSH: Connect to Host...**
4. Choose `docktunnel`.

---

## 📦 ML Environment Setup (Conda)

DockTunnel keeps the base image small. Use Conda to install your ML frameworks:

### Example: PyTorch with CUDA 12.4
```bash
conda create -n docktunnel python=3.10 -y
conda activate docktunnel
conda install pytorch torchvision torchaudio pytorch-cuda=12.4 -c pytorch -c nvidia -y
```

---

## 📊 Default Services

| Service | Container Port | Local/Tunnel Access |
| :--- | :--- | :--- |
| **SSH** | `22` | Tunnel (URL) / Local: `2222` |
| **Jupyter Lab** | `8888` | Local: `8886` |
| **TensorBoard** | `6006` | Local: `6006` |
| **Web Server** | `8000` | Local: `6785` |

---

## 📁 Project Structure

```text
docktunnel/
├── deploy/
│   ├── Dockerfile            # Lightweight dev image
│   ├── docker-compose.yml    # Main stack with Tunnel
│   ├── entrypoint.sh         # Auto-starts SSH & Jupyter
│   └── cloudflared/          # Advanced config (optional)
├── data/                     # Local data mount
├── .env.example              # Environment variables
└── README.md                 # You are here
```

---

## 🛡️ Security Best Practices

- **Update Password**: The default root password is `docktunnel2026`. Run `passwd` immediately after login.
- **SSH Keys**: It is highly recommended to mount your local `~/.ssh/id_ed25519.pub` into the container's `/root/.ssh/authorized_keys`.
- **Private Tunnels**: For production use, consider using a **Named Tunnel** with your own domain (see `docker-compose.yml` comments).

---

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📜 License

This project is licensed under the MIT License.

---
Created by [ChaosAIVision](https://github.com/ChaosAIVision). If you find this useful, give it a ⭐!
