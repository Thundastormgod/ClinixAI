# ClinixAI AI Model Specifications

## Overview

ClinixAI uses multiple AI models for different tasks: language understanding, speech recognition, and semantic search. This document details the specifications for each model.

---

## 1. Language Models (LLM)

### 1.1 Qwen 0.5B Q4 (Primary - On-Device)

| Property | Value |
|----------|-------|
| **Model** | Qwen2.5-0.5B-Instruct |
| **Quantization** | Q4_K_M |
| **Size** | ~350 MB |
| **Parameters** | 500 million |
| **Context Length** | 4096 tokens |
| **License** | Apache 2.0 |

**Performance (Android - Snapdragon 8 Gen 2):**
| Metric | Value |
|--------|-------|
| Load Time | ~5 seconds |
| Inference Speed | 15-25 tokens/sec |
| Memory Usage | ~500 MB |
| First Token Latency | ~500 ms |

**Use Cases:**
- ✅ Symptom analysis
- ✅ Urgency classification
- ✅ Basic medical Q&A
- ❌ Complex differential diagnosis

**Download:**
```
URL: https://cdn.clinixai.com/models/qwen-0.5b-q4.gguf
SHA256: [checksum]
```

---

### 1.2 Qwen 1.5B Q4 (Enhanced - On-Device)

| Property | Value |
|----------|-------|
| **Model** | Qwen2.5-1.5B-Instruct |
| **Quantization** | Q4_K_M |
| **Size** | ~1.1 GB |
| **Parameters** | 1.5 billion |
| **Context Length** | 8192 tokens |
| **License** | Apache 2.0 |

**Performance (Android - Snapdragon 8 Gen 2):**
| Metric | Value |
|--------|-------|
| Load Time | ~12 seconds |
| Inference Speed | 8-15 tokens/sec |
| Memory Usage | ~1.2 GB |
| First Token Latency | ~800 ms |

**Use Cases:**
- ✅ Detailed symptom analysis
- ✅ Multi-step reasoning
- ✅ Medical guideline application
- ⚠️ Requires higher-end device

---

### 1.3 Cloud Models (Fallback)

| Model | Provider | Use Case |
|-------|----------|----------|
| **GPT-4o-mini** | OpenAI | Complex triage, accuracy-critical |
| **Claude 3 Haiku** | Anthropic | Detailed explanations |
| **Gemini 1.5 Flash** | Google | Fast responses, long context |
| **Llama 3.1 8B** | Meta | Open-source fallback |

**Cloud Model Selection Logic:**
```dart
String selectCloudModel(AIRequest request) {
  if (request.requiresHighAccuracy) return 'gpt-4o-mini';
  if (request.contextLength > 8000) return 'gemini-1.5-flash';
  if (request.preferOpenSource) return 'llama-3.1-8b';
  return 'claude-3-haiku';  // Default
}
```

---

## 2. Speech-to-Text Models

### 2.1 Whisper Tiny (Primary - On-Device)

| Property | Value |
|----------|-------|
| **Model** | whisper-tiny |
| **Size** | ~75 MB |
| **Parameters** | 39 million |
| **Languages** | 99 languages |
| **License** | MIT |

**Performance:**
| Metric | Value |
|--------|-------|
| Load Time | ~2 seconds |
| Transcription Speed | ~10x real-time |
| Memory Usage | ~200 MB |
| Word Error Rate | ~15% (English) |

**Supported Audio Formats:**
- WAV (16-bit, 16kHz)
- MP3
- M4A
- FLAC

**Download:**
```
URL: https://cdn.clinixai.com/models/whisper-tiny.bin
SHA256: [checksum]
```

---

### 2.2 Whisper Base (Enhanced - On-Device)

| Property | Value |
|----------|-------|
| **Model** | whisper-base |
| **Size** | ~150 MB |
| **Parameters** | 74 million |
| **Word Error Rate** | ~10% (English) |

**Use When:**
- Higher accuracy needed
- Device has sufficient memory (>3GB RAM)
- Non-native English speakers

---

## 3. Embedding Models

### 3.1 All-MiniLM-L6-v2 (RAG Embeddings)

| Property | Value |
|----------|-------|
| **Model** | all-MiniLM-L6-v2 |
| **Dimensions** | 384 |
| **Size** | ~90 MB |
| **Max Sequence** | 256 tokens |
| **License** | Apache 2.0 |

**Performance:**
| Metric | Value |
|--------|-------|
| Embedding Speed | ~1000 sentences/sec |
| Memory Usage | ~150 MB |
| Similarity Accuracy | 85%+ |

**Use Cases:**
- Medical knowledge retrieval
- Symptom similarity search
- Document chunking & indexing

---

## 4. Model Selection Guidelines

### Device Requirements

| Model Tier | RAM | Storage | CPU |
|------------|-----|---------|-----|
| **Minimal** (0.5B + Tiny) | 2GB+ | 500MB | Any |
| **Standard** (0.5B + Base) | 3GB+ | 600MB | Mid-range |
| **Enhanced** (1.5B + Base) | 4GB+ | 1.5GB | High-end |

### Recommended Configurations

**Budget Devices (e.g., Samsung A series):**
```yaml
llm: qwen-0.5b-q4
stt: whisper-tiny
embeddings: all-minilm-l6-v2
```

**Mid-Range Devices (e.g., Nothing Phone 2):**
```yaml
llm: qwen-0.5b-q4
stt: whisper-base
embeddings: all-minilm-l6-v2
```

**Flagship Devices (e.g., Samsung S24, iPhone 15):**
```yaml
llm: qwen-1.5b-q4
stt: whisper-base
embeddings: all-minilm-l6-v2
```

---

## 5. Model Prompts

### Triage System Prompt

```
You are ClinixAI, a medical triage assistant for emergency situations.

Your role:
1. Analyze patient symptoms
2. Assess urgency level (1-5)
3. Provide clear recommendations
4. Identify red flags

Urgency Levels:
- Level 1 (Critical): Life-threatening, immediate care needed
- Level 2 (Emergent): Serious, care within 1 hour
- Level 3 (Urgent): Moderate, care within 4 hours
- Level 4 (Less Urgent): Minor, same-day care
- Level 5 (Non-Urgent): Routine, scheduled care

Always:
- Be clear and concise
- Prioritize patient safety
- Recommend professional medical evaluation
- Never diagnose definitively

Output format:
URGENCY: [1-5]
ASSESSMENT: [brief analysis]
RECOMMENDATIONS: [bullet points]
RED FLAGS: [if any]
```

### RAG Query Prompt

```
Based on the following medical guidelines:
{context}

Patient symptoms: {symptoms}

Provide a triage assessment following the urgency classification system.
Include relevant guideline references in your response.
```

---

## 6. Model Updates & Versioning

### Version Schema

```
model-name-version-quantization
Example: qwen-0.5b-v1.2-q4
```

### Update Mechanism

```dart
class ModelManager {
  Future<bool> checkForUpdates(String modelId) async {
    final localVersion = await getLocalVersion(modelId);
    final remoteVersion = await fetchRemoteVersion(modelId);
    return remoteVersion > localVersion;
  }
  
  Future<void> updateModel(String modelId) async {
    // 1. Download new model
    await downloadModel(modelId);
    // 2. Verify checksum
    await verifyChecksum(modelId);
    // 3. Swap models
    await swapModels(modelId);
    // 4. Clean up old version
    await cleanupOldVersion(modelId);
  }
}
```

---

## 7. Benchmarks

### Triage Accuracy (Internal Testing)

| Model | Accuracy | Precision | Recall | F1 |
|-------|----------|-----------|--------|-----|
| Qwen 0.5B Q4 | 78% | 0.75 | 0.80 | 0.77 |
| Qwen 1.5B Q4 | 85% | 0.83 | 0.87 | 0.85 |
| GPT-4o-mini | 92% | 0.90 | 0.94 | 0.92 |
| Claude 3 Haiku | 89% | 0.87 | 0.91 | 0.89 |

### Latency Comparison (Snapdragon 8 Gen 2)

| Operation | Local (0.5B) | Local (1.5B) | Cloud |
|-----------|--------------|--------------|-------|
| Triage Analysis | 3-5s | 6-10s | 1-2s |
| STT (10s audio) | 1s | 1s | 0.5s |
| RAG Query | 0.3s | 0.3s | 0.2s |

---

## Appendix: Model Downloads

### Official CDN

| Model | URL | Size |
|-------|-----|------|
| Qwen 0.5B Q4 | `https://cdn.clinixai.com/models/qwen-0.5b-q4.gguf` | 350 MB |
| Qwen 1.5B Q4 | `https://cdn.clinixai.com/models/qwen-1.5b-q4.gguf` | 1.1 GB |
| Whisper Tiny | `https://cdn.clinixai.com/models/whisper-tiny.bin` | 75 MB |
| Whisper Base | `https://cdn.clinixai.com/models/whisper-base.bin` | 150 MB |
| MiniLM Embeddings | `https://cdn.clinixai.com/models/minilm-l6-v2.bin` | 90 MB |

### Alternative Sources

- [Hugging Face](https://huggingface.co/Qwen)
- [Ollama Library](https://ollama.com/library)

---

*Document Version: 1.0.0*  
*Last Updated: November 29, 2025*
