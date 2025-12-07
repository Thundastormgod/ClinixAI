# 🏥 ClinixAI - AI-Powered Medical Triage for Africa

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Docker](https://img.shields.io/badge/Docker-Ready-2496ED?logo=docker)](docker-compose.yml)
[![Flutter](https://img.shields.io/badge/Flutter-3.24-02569B?logo=flutter)](clinix_app/)

> **Hackathon Project**: Intelligent medical triage using local AI (llama.cpp) with cloud escalation (OpenRouter) and Neo4j GraphRAG for medical knowledge retrieval.

## 🚀 Quick Start for Teams

### Prerequisites
- **Docker Desktop** (Windows/Mac) or Docker + Docker Compose (Linux)
- **Git**
- **8GB+ RAM** recommended for local AI model

### One-Command Setup

```bash
# Clone the repository
git clone https://github.com/Thundastormgod/ClinixAI.git
cd ClinixAI

# Download the AI model (~1GB)
# Windows:
.\download_model.ps1

# Linux/Mac:
chmod +x download_model.sh && ./download_model.sh

# Start all services
docker-compose up -d

# Check everything is running
docker-compose ps
```

### 🔑 Environment Setup (Optional - for cloud AI)

Create a `.env` file for OpenRouter cloud escalation:

```env
# OpenRouter API Key (free tier available at openrouter.ai)
OPENROUTER_API_KEY=sk-or-v1-your-key-here

# Optional: Neo4j password override
NEO4J_PASSWORD=clinixai_neo4j_password
```

**Without `.env`**: The system works 100% locally using llama.cpp. Cloud AI is optional for critical cases.

---

## 📊 Service Endpoints

| Service | URL | Description |
|---------|-----|-------------|
| **Triage API** | http://localhost:8000 | Main AI backend |
| **API Docs** | http://localhost:8000/docs | Interactive Swagger UI |
| **Neo4j Browser** | http://localhost:7475 | Knowledge graph explorer |
| **API Gateway** | http://localhost:3000 | Session management |
| **llama.cpp** | http://localhost:8091 | Direct LLM access |
| **Adminer** | http://localhost:8081 | Database GUI |

### Neo4j Credentials
- **Username**: `neo4j`
- **Password**: `clinixai_neo4j_password`

---

## 🧠 AI Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                    ClinixAI Triage Flow                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  User Symptoms ──► Symptom Analyzer ──► Complexity Score    │
│                          │                                  │
│                          ▼                                  │
│              ┌──── Routing Decision ────┐                   │
│              │                          │                   │
│              ▼                          ▼                   │
│      ┌───────────────┐         ┌────────────────┐          │
│      │   llama.cpp   │         │   OpenRouter   │          │
│      │   (LOCAL)     │         │   (CLOUD)      │          │
│      │   Fast, Free  │         │   Critical     │          │
│      └───────────────┘         └────────────────┘          │
│              │                          │                   │
│              └──────────┬───────────────┘                   │
│                         ▼                                   │
│              ┌────────────────────┐                         │
│              │   Neo4j GraphRAG   │                         │
│              │   Medical Context  │                         │
│              └────────────────────┘                         │
│                         │                                   │
│                         ▼                                   │
│              ┌────────────────────┐                         │
│              │   Triage Response  │                         │
│              │   + Recommendations│                         │
│              └────────────────────┘                         │
└─────────────────────────────────────────────────────────────┘
```

### Routing Logic
- **Standard cases** → llama.cpp (local, ~5-15s response)
- **Critical/Urgent cases** → OpenRouter (cloud, highest accuracy)
- **All cases** → Enhanced with Neo4j medical knowledge

---

## 🔧 API Usage Examples

### Health Check
```bash
curl http://localhost:8000/health
```

### Chat with AI (RAG-Enhanced)
```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{
    "message": "I have a fever and headache for 2 days",
    "use_rag": true
  }'
```

### Full Triage Analysis
```bash
curl -X POST http://localhost:8000/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "session_id": "test-123",
    "symptoms": [
      {"description": "high fever", "severity": 7, "duration_hours": 48},
      {"description": "severe headache", "severity": 6}
    ],
    "patient_age": 28,
    "patient_gender": "female"
  }'
```

### Upload Medical Documents (PDF)
```bash
curl -X POST http://localhost:8000/rag/upload-pdf \
  -F "file=@medical_handbook.pdf" \
  -F "extract_entities=false"
```

---

## 📱 Flutter Frontend

### Web Version (No model download needed)
```bash
cd clinix_app

# Use web-compatible dependencies
cp pubspec_web.yaml pubspec.yaml
flutter pub get

# Run on Chrome
flutter run -d chrome --web-port 8088 -t lib/main_web.dart
```

### Native Version (Android/iOS - includes on-device AI)
```bash
cd clinix_app

# Use native dependencies
cp pubspec_native.yaml pubspec.yaml
flutter pub get

# Run on device
flutter run
```

---

## 🗃️ Project Structure

```
ClinixAI/
├── backend/
│   ├── triage-service/     # FastAPI + LangGraph AI orchestration
│   │   ├── main.py         # Main API endpoints
│   │   └── graphrag/       # Neo4j RAG implementation
│   ├── api-gateway/        # Node.js session management
│   └── ehr-bridge/         # FHIR interoperability
│
├── clinix_app/             # Flutter mobile/web app
│   ├── lib/main_web.dart   # Web entry point
│   └── lib/main.dart       # Native entry point
│
├── models/gguf/            # Local GGUF models
├── docker-compose.yml      # Full stack orchestration
├── download_model.ps1      # Windows model downloader
└── download_model.sh       # Linux/Mac model downloader
```

---

## 🧪 Testing

### Run Test Suite
```bash
python test_rag_system.py
```

### Quick Health Check
```bash
python test_rag_system.py --quick
```

### Interactive Chat Mode
```bash
python test_rag_system.py --chat
```

---

## ❓ FAQ

### Do I need to download the model every time?

**No!** The model is stored in `models/gguf/` and persists between container restarts. You only download once when first setting up.

The model file (~1GB) is stored locally on your machine in the `models/gguf/` directory. Docker mounts this directory, so:
- ✅ Model persists across container restarts
- ✅ Model persists across `docker-compose down/up`
- ✅ Only need to download once per machine

### Can I use a different model?

Yes! Edit `docker-compose.yml` and change the llama-cpp command:
```yaml
command: >
  --model /models/your-model-name.gguf
```

Available models:
- `qwen2.5-1.5b-instruct-q4_k_m.gguf` (1GB, fastest)
- `qwen2.5-3b-instruct-q4_k_m.gguf` (2GB, recommended)
- Any GGUF model from HuggingFace

### How do I add medical documents to the knowledge base?

```bash
# Upload via API
curl -X POST http://localhost:8000/rag/upload-pdf \
  -F "file=@your-document.pdf"

# Or place PDFs in a folder and ingest
curl -X POST http://localhost:8000/rag/ingest-directory \
  -H "Content-Type: application/json" \
  -d '{"directory": "/app/docs"}'
```

### Why isn't OpenRouter working?

Check your `.env` file has a valid API key:
```env
OPENROUTER_API_KEY=sk-or-v1-your-actual-key
```

Get a free key at [openrouter.ai](https://openrouter.ai)

---

## 🛠️ Development

### Rebuild Services
```bash
docker-compose down
docker-compose up -d --build
```

### View Logs
```bash
# All services
docker-compose logs -f

# Specific service
docker-compose logs -f triage-service
```

### Access Container Shell
```bash
docker exec -it clinixai-triage-service bash
```

---

## 📜 License

MIT License - See [LICENSE](LICENSE) for details.

---

## 🤝 Team

Built for the Africa Health Hackathon 2024

- **Repository**: [github.com/Thundastormgod/ClinixAI](https://github.com/Thundastormgod/ClinixAI)
