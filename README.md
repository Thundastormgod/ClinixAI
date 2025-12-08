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
.\scripts\download_model.ps1

# Linux/Mac:
chmod +x scripts/download_model.sh && ./scripts/download_model.sh

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

## 🗄️ Sharing the Knowledge Base (Neo4j Backup/Restore)

**Problem**: Each team member having to upload and chunk PDFs individually wastes time and compute.

**Solution**: Share a pre-loaded Neo4j database backup!

### For the Person Who Has the Documents

```bash
# 1. After uploading all PDFs and building the knowledge graph
curl http://localhost:8000/rag/stats  # Verify chunks are loaded

# 2. Create a backup
# Windows:
.\scripts\backup_neo4j.ps1

# Linux/Mac:
chmod +x scripts/backup_neo4j.sh
./scripts/backup_neo4j.sh

# 3. Upload the backup file to shared storage
# - Google Drive
# - Dropbox
# - GitHub Release (if < 100MB)
# - Team server

# Output: neo4j_backup/clinixai_knowledge_YYYYMMDD_HHMMSS.dump
```

### For Team Members Without Documents

```bash
# 1. Download the backup file from shared storage

# 2. Restore the database
# Windows:
.\scripts\restore_neo4j.ps1 path\to\clinixai_knowledge_YYYYMMDD_HHMMSS.dump

# Linux/Mac:
chmod +x scripts/restore_neo4j.sh
./scripts/restore_neo4j.sh path/to/clinixai_knowledge_YYYYMMDD_HHMMSS.dump

# 3. Verify the restore
curl http://localhost:8000/rag/stats
# Should show the same chunk count as the original

# 4. Test RAG queries
curl -X POST http://localhost:8000/rag/query \
  -H "Content-Type: application/json" \
  -d '{"query": "What are malaria symptoms?", "top_k": 3}'
```

### What Gets Backed Up?

- ✅ All document chunks (embeddings included)
- ✅ All extracted entities (if any)
- ✅ All relationships in the knowledge graph
- ✅ Neo4j indexes and constraints
- ❌ Does NOT include: The AI model (that's separate)

### Backup File Size

Typical sizes based on document count:
- **5 PDFs** (~2,773 chunks): ~10-20 MB
- **50 PDFs**: ~100-200 MB
- **500 PDFs**: ~1-2 GB

**Tip**: Compress before sharing: `Compress-Archive` (Windows) or `tar -czf` (Linux/Mac)

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
│   ├── triage-service/       # FastAPI + LangGraph AI orchestration
│   │   ├── main.py           # Main API endpoints
│   │   ├── ai/               # AI provider integrations
│   │   └── graphrag/         # Neo4j RAG implementation
│   ├── api-gateway/          # Node.js session management
│   ├── ehr-bridge/           # FHIR interoperability
│   └── database/             # PostgreSQL init scripts
│
├── clinix_app/               # Flutter mobile/web app
│   ├── lib/main_web.dart     # Web entry point
│   ├── lib/main.dart         # Native entry point
│   └── assets/knowledge/     # Local knowledge base files
│
├── scripts/                  # Utility scripts
│   ├── download_model.ps1    # Windows model downloader
│   ├── download_model.sh     # Linux/Mac model downloader
│   ├── backup_neo4j.ps1      # Neo4j backup (Windows)
│   ├── backup_neo4j.sh       # Neo4j backup (Linux/Mac)
│   ├── restore_neo4j.ps1     # Neo4j restore (Windows)
│   ├── restore_neo4j.sh      # Neo4j restore (Linux/Mac)
│   ├── build_web.ps1         # Flutter web build (Windows)
│   └── build_web.sh          # Flutter web build (Linux/Mac)
│
├── docs/                     # Documentation
│   ├── SETUP_GUIDE.md        # Detailed setup instructions
│   ├── API_DOCUMENTATION.md  # API reference
│   ├── ARCHITECTURE.md       # System architecture
│   └── ...
│
├── models/                   # Local AI models (downloaded separately)
│   └── gguf/                 # GGUF model files (gitignored)
│
├── docker-compose.yml        # Full stack orchestration
├── .env.example              # Environment template
├── CONTRIBUTING.md           # Contribution guidelines
└── LICENSE                   # MIT License
```

---

## 🧪 Testing

See [docs/TEAM_TESTING_GUIDE.md](docs/TEAM_TESTING_GUIDE.md) for detailed testing instructions.

### Quick Health Check
```bash
curl http://localhost:8000/health
```

### Test RAG Query
```bash
curl -X POST http://localhost:8000/rag/query \
  -H "Content-Type: application/json" \
  -d '{"query": "What are malaria symptoms?", "top_k": 3}'
```

---

## ❓ FAQ

### Do I need to download the model every time?

**No!** The model is stored in `models/gguf/` and persists between container restarts. You only download once when first setting up.

The model file (~1GB) is stored locally on your machine in the `models/gguf/` directory. Docker mounts this directory, so:
- ✅ Model persists across container restarts
- ✅ Model persists across `docker-compose down/up`
- ✅ Only need to download once per machine

### Do I need to upload documents every time?

**No!** The Neo4j knowledge graph persists in a Docker volume. Once documents are uploaded and chunked, they stay there unless you delete the volume.

**For teams**: Use the backup/restore scripts to share a pre-loaded database:
1. Person with docs: `.\scripts\backup_neo4j.ps1` → Share the `.dump` file
2. Team members: `.\scripts\restore_neo4j.ps1 backup.dump` → Instant knowledge base!

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
