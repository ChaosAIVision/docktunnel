#!/bin/bash

# Setup SSH keys from YAML config file
SSH_KEYS_FILE="/root/.ssh/ssh-keys.yml"

if [ -f "$SSH_KEYS_FILE" ]; then
    echo "Setting up SSH public keys from $SSH_KEYS_FILE..."
    mkdir -p /root/.ssh
    chmod 700 /root/.ssh

    # Clear existing keys
    > /root/.ssh/authorized_keys
    chmod 600 /root/.ssh/authorized_keys

    # Parse YAML and extract keys (simple grep-based approach)
    # Extract lines starting with "- " and strip the prefix
    grep -E '^\s*-\s*"' "$SSH_KEYS_FILE" | sed 's/^\s*-\s*"//' | sed 's/"$//' | while IFS= read -r key; do
        if [ -n "$key" ]; then
            echo "$key" >> /root/.ssh/authorized_keys
            echo "Added SSH key: ${key##* }"
        fi
    done

    key_count=$(wc -l < /root/.ssh/authorized_keys)
    echo "SSH keys configured successfully ($key_count keys added)"
else
    echo "No SSH keys file found at $SSH_KEYS_FILE"
fi

# Start SSH service
echo "Starting SSH service..."
service ssh start

# Start Jupyter Lab if enabled
if [ "$JUPYTER_ENABLE_LAB" = "yes" ]; then
    echo "Starting Jupyter Lab..."
    nohup jupyter lab \
        --ip=0.0.0.0 \
        --port=8888 \
        --no-browser \
        --allow-root \
        --NotebookApp.token='' \
        --NotebookApp.password='' \
        > /var/log/jupyter.log 2>&1 &
fi

# Print connection information
echo "=========================================="
echo "🚀 DockTunnel Development Environment Ready!"
echo "=========================================="
echo "SSH: ssh -p 2222 root@localhost"
echo "Jupyter Lab: http://localhost:8888 (Mapped to 8886 on host)"
echo "TensorBoard: http://localhost:6006"
echo "=========================================="
echo "🎮 GPU Status:"
nvidia-smi --query-gpu=index,name,memory.total --format=csv,noheader
echo "=========================================="

# Execute the main command
exec "$@"
