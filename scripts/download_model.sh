#!/bin/bash
# Download GGUF model for llama.cpp server
# Run this script to download a small, fast medical-capable model

# Create models directory
mkdir -p models/gguf

# Download Qwen2.5-3B-Instruct (Q4_K_M quantization - good balance of speed/quality)
# Size: ~2GB, very fast on CPU
echo "Downloading Qwen2.5-3B-Instruct (Q4_K_M)..."
curl -L -o models/gguf/qwen2.5-3b-instruct-q4_k_m.gguf \
  "https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf"

echo "Download complete!"
echo ""
echo "To start llama.cpp server with Docker:"
echo "  docker run -d -p 8091:8080 -v $(pwd)/models/gguf:/models ghcr.io/ggerganov/llama.cpp:server \\"
echo "    --model /models/qwen2.5-3b-instruct-q4_k_m.gguf --ctx-size 2048 --threads 4"
