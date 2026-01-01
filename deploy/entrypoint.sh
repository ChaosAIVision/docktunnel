#!/bin/bash

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
