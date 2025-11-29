# ClinixAI Local Models Directory

This directory stores local LLM models for on-device inference.

## Recommended Models

### Primary: LiquidAI LFM2-1.2B-RAG (Quantized)
- **File**: `lfm2-1.2b-rag-q4_k_m.gguf`
- **Size**: ~722MB
- **Purpose**: Medical triage on-device inference
- **Download**: [HuggingFace](https://huggingface.co/LiquidAI/LFM2-1.2B-RAG)

### Alternative: Mistral 7B Instruct (Quantized)
- **File**: `mistral-7b-instruct-v0.2.Q4_K_M.gguf`
- **Size**: ~4.1GB
- **Purpose**: Higher accuracy local inference
- **Download**: [HuggingFace](https://huggingface.co/TheBloke/Mistral-7B-Instruct-v0.2-GGUF)

### Lightweight: Phi-3 Mini (Quantized)
- **File**: `phi-3-mini-4k-instruct.Q4_K_M.gguf`
- **Size**: ~2.2GB
- **Purpose**: Fast inference on mobile devices
- **Download**: [HuggingFace](https://huggingface.co/microsoft/Phi-3-mini-4k-instruct-gguf)

## Model Download Script

```bash
# Using Hugging Face CLI
pip install huggingface_hub

# Download LFM2 (recommended)
huggingface-cli download LiquidAI/LFM2-1.2B-RAG --local-dir ./models

# Download Mistral (optional, larger but more accurate)
huggingface-cli download TheBloke/Mistral-7B-Instruct-v0.2-GGUF \
  --include "mistral-7b-instruct-v0.2.Q4_K_M.gguf" \
  --local-dir ./models
```

## Configuration

Set in `.env` or environment:
```
LOCAL_LLM_MODEL_PATH=models/lfm2-1.2b-rag-q4_k_m.gguf
LOCAL_LLM_BACKEND=llama_cpp  # or ctransformers, cactus, rule_based
LOCAL_LLM_MAX_TOKENS=256
LOCAL_LLM_TEMPERATURE=0.3
LOCAL_LLM_CONTEXT_SIZE=2048
LOCAL_LLM_THREADS=4
```

## Notes

- Models are NOT included in version control (see .gitignore)
- For development, the `rule_based` backend works without any model
- For production mobile deployment, use Cactus SDK integration
