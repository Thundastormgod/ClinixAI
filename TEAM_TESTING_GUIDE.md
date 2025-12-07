# ClinixAI RAG System - Team Testing Guide

## 🚀 Quick Start for Team Members

### Prerequisites
1. **Docker Desktop** installed and running
2. **Git** to clone the repository
3. **Python 3.10+** (optional, for running test scripts)

### Getting Started

```bash
# 1. Clone the repository
git clone https://github.com/Thundastormgod/ClinixAI.git
cd ClinixAI

# 2. Start all services (first time takes a few minutes)
docker-compose up -d

# 3. Check all services are running
docker-compose ps
```

---

## 🤖 Local LLM Setup (llama.cpp - RECOMMENDED)

llama.cpp is the **fastest option for CPU inference**. Much faster than Ollama!

### Step 1: Download a Model
```powershell
# Run the download script (Windows)
.\download_model.ps1

# Or download manually (~2GB):
# https://huggingface.co/Qwen/Qwen2.5-3B-Instruct-GGUF/resolve/main/qwen2.5-3b-instruct-q4_k_m.gguf
# Save to: models/gguf/qwen2.5-3b-instruct-q4_k_m.gguf
```

### Step 2: Start llama.cpp Server
```bash
docker-compose up -d llama-cpp
```

### Step 3: Test It
```bash
curl http://localhost:8091/health
```

### Alternative: Use Ollama (Slower but Easier)
```bash
# Pull a model
docker exec -it clinixai-ollama ollama pull qwen2.5:3b

# Test it
curl http://localhost:11434/api/tags
```

---

## 📊 Service URLs

| Service | URL | Purpose |
|---------|-----|---------|
| **Triage API** | http://localhost:8000 | Main backend API |
| **API Docs** | http://localhost:8000/docs | Swagger documentation |
| **Neo4j Browser** | http://localhost:7475 | Knowledge graph database |
| **Flutter App** | http://localhost:8088 | Frontend (if running) |

### Neo4j Credentials
- **URL**: http://localhost:7475
- **Username**: `neo4j`
- **Password**: `clinixai_neo4j_password`

---

## 🧪 Testing the RAG System

### Option 1: Python Test Script
```bash
# Run full test suite
python test_rag_system.py

# Quick health check only
python test_rag_system.py --quick

# Interactive chat mode
python test_rag_system.py --chat
```

### Option 2: Using curl (Command Line)

#### Check Service Health
```bash
curl http://localhost:8000/health
```

#### Check RAG Statistics
```bash
curl http://localhost:8000/rag/stats
```

#### Query the Knowledge Base
```bash
curl -X POST http://localhost:8000/rag/query \
  -H "Content-Type: application/json" \
  -d '{"query": "What are the symptoms of malaria?", "top_k": 3}'
```

#### Chat with Local AI + RAG
```bash
curl -X POST http://localhost:8000/chat \
  -H "Content-Type: application/json" \
  -d '{"message": "I have a fever and headache for 2 days. What could it be?", "use_rag": true}'
```

#### Full Triage Analysis with RAG
```bash
curl -X POST http://localhost:8000/analyze-with-rag \
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

### Option 3: Using the Swagger UI
1. Open http://localhost:8000/docs
2. Expand any endpoint
3. Click "Try it out"
4. Fill in the request body
5. Click "Execute"

---

## 💬 Chat Endpoint Details

### Endpoint: `POST /chat`

The chat endpoint connects your local Ollama model with the Neo4j knowledge base.

**Request:**
```json
{
  "message": "What are the danger signs of malaria?",
  "use_rag": true,
  "temperature": 0.3,
  "max_tokens": 1024
}
```

**Response:**
```json
{
  "success": true,
  "response": "Based on the medical knowledge...",
  "model": "qwen2.5:3b",
  "response_time_ms": 2500,
  "rag_context_used": true,
  "sources_count": 3
}
```

### How It Works
1. **RAG Retrieval**: Searches Neo4j for relevant medical chunks using hybrid search (semantic + keyword)
2. **Context Injection**: Formats retrieved knowledge as context for the LLM
3. **Ollama Inference**: Sends query + context to local Ollama model
4. **Response**: Returns AI-generated answer with source attribution

### Supported Ollama Models
```bash
# Small & Fast (recommended for testing)
docker exec -it clinixai-ollama ollama pull qwen2.5:3b

# Medium & Balanced
docker exec -it clinixai-ollama ollama pull qwen2.5:7b
docker exec -it clinixai-ollama ollama pull llama3.1:8b

# Large & Accurate (requires 16GB+ RAM)
docker exec -it clinixai-ollama ollama pull qwen2.5:14b
```

---

## 📚 Uploading Documents to RAG

### Upload a PDF
```bash
curl -X POST http://localhost:8000/rag/upload-pdf \
  -F "file=@/path/to/your/document.pdf" \
  -F "extract_entities=false"
```

**Parameters:**
- `extract_entities=false` - FREE, stores chunks with embeddings only
- `extract_entities=true` - Uses OpenRouter API (costs credits) to extract medical entities

### Upload Directory of PDFs
```bash
curl -X POST http://localhost:8000/rag/ingest-directory \
  -H "Content-Type: application/json" \
  -d '{"directory": "/app/docs", "extract_entities": false}'
```

---

## 🔍 Neo4j Knowledge Graph

### Access the Graph
1. Open http://localhost:7475
2. Login with `neo4j` / `clinixai_neo4j_password`
3. Run Cypher queries

### Useful Cypher Queries

```cypher
// Count all nodes by type
MATCH (n) RETURN labels(n)[0] AS type, count(*) AS count ORDER BY count DESC

// View sample chunks
MATCH (c:Chunk) RETURN c.text LIMIT 5

// Find symptoms and related diseases
MATCH (s:Symptom)-[r]->(d:Disease) RETURN s.name, type(r), d.name LIMIT 20

// Search for specific entity
MATCH (n) WHERE n.name CONTAINS 'malaria' RETURN n LIMIT 10
```

---

## 🐛 Troubleshooting

### Service Not Starting
```bash
# Check logs
docker-compose logs triage-service

# Restart services
docker-compose restart

# Full rebuild
docker-compose down
docker-compose up -d --build
```

### Ollama Not Responding
```bash
# Check if model is loaded
docker exec -it clinixai-ollama ollama list

# Pull model if missing
docker exec -it clinixai-ollama ollama pull qwen2.5:3b

# Check Ollama logs
docker logs clinixai-ollama
```

### RAG Query Returns Empty
```bash
# Check if documents are loaded
curl http://localhost:8000/rag/stats

# If Chunk count is 0, upload documents
curl -X POST http://localhost:8000/rag/upload-pdf \
  -F "file=@docs/API_DOCUMENTATION.md"
```

### Neo4j Connection Issues
```bash
# Check Neo4j status
docker logs clinixai-neo4j

# Verify Neo4j is healthy
curl http://localhost:7475
```

---

## 🌐 Environment Variables

Create a `.env` file in the project root:

```env
# OpenRouter (for cloud AI - optional)
OPENROUTER_API_KEY=your-key-here
OPENROUTER_MODEL=meta-llama/llama-3.1-70b-instruct

# Ollama (local AI)
OLLAMA_BASE_URL=http://ollama:11434
OLLAMA_MODEL=qwen2.5:3b

# Neo4j
NEO4J_URI=bolt://neo4j:7687
NEO4J_USER=neo4j
NEO4J_PASSWORD=clinixai_neo4j_password
```

---

## 📱 Flutter App Testing

```bash
# Navigate to Flutter app
cd clinix_app

# Get dependencies
flutter pub get

# Run on Chrome (web)
flutter run -d chrome --web-port=8088 -t lib/main_web.dart

# Run on Android emulator
flutter run -d android
```

---

## 🎯 Test Scenarios

### Scenario 1: Basic RAG Query
1. Query: "What are the symptoms of typhoid fever?"
2. Expected: Returns relevant chunks from medical handbooks
3. Verify: `chunks` array is not empty

### Scenario 2: Chat with Context
1. Message: "I have high fever, headache, and body aches for 3 days"
2. Expected: AI response mentioning possible causes (malaria, typhoid, etc.)
3. Verify: `rag_context_used: true`

### Scenario 3: Full Triage Flow
1. Submit symptoms via `/analyze-with-rag`
2. Expected: Urgency level, assessment, and recommendations
3. Verify: `rag_enhanced: true`, `graph_insights` populated

---

## 🗄️ Sharing the Neo4j Knowledge Base

### Why Share the Database?

Uploading and processing PDFs can take time:
- **5 PDFs**: ~5-10 minutes (chunking + embeddings)
- **50 PDFs**: ~30-60 minutes
- **500 PDFs**: Several hours

Instead of each team member repeating this process, **share a pre-loaded database backup**.

### Creating a Backup (For the Person With Documents)

```bash
# 1. Verify your knowledge base is loaded
curl http://localhost:8000/rag/stats

# Output should show:
# {
#   "database_stats": {
#     "Chunk": 2773,
#     "Document": 5,
#     ...
#   }
# }

# 2. Run the backup script
# Windows:
.\backup_neo4j.ps1

# Linux/Mac:
chmod +x backup_neo4j.sh
./backup_neo4j.sh

# 3. Find the backup file
# Location: neo4j_backup/clinixai_knowledge_YYYYMMDD_HHMMSS.dump
# Size: ~10-20 MB for 5 PDFs

# 4. Compress (optional, recommended for large files)
# Windows:
Compress-Archive -Path neo4j_backup/clinixai_knowledge_*.dump -DestinationPath clinixai_knowledge.zip

# Linux/Mac:
tar -czf clinixai_knowledge.tar.gz neo4j_backup/clinixai_knowledge_*.dump

# 5. Upload to shared storage
# - Google Drive (best for team sharing)
# - Dropbox
# - GitHub Release (if < 100MB)
# - OneDrive
# - Team server
```

### Restoring a Backup (For Team Members)

```bash
# 1. Download the backup file from shared storage
# Example: clinixai_knowledge_20250107_143022.dump

# 2. Make sure Neo4j is running
docker-compose up -d neo4j

# 3. Run the restore script
# Windows:
.\restore_neo4j.ps1 neo4j_backup\clinixai_knowledge_20250107_143022.dump

# Linux/Mac:
chmod +x restore_neo4j.sh
./restore_neo4j.sh neo4j_backup/clinixai_knowledge_20250107_143022.dump

# 4. Wait for completion (~30 seconds)
# You'll see:
# ✅ Restore complete!

# 5. Verify the restore
curl http://localhost:8000/rag/stats

# Should show the same stats as the original database
```

### What's Included in the Backup?

✅ **Included:**
- All document chunks (with text)
- All vector embeddings
- All extracted entities (symptoms, diseases, etc.)
- All relationships in knowledge graph
- Neo4j indexes and constraints

❌ **NOT Included:**
- The AI model (llama.cpp) - that's separate
- Application code
- Docker containers
- Configuration files

### Backup Best Practices

1. **Version Your Backups**
   ```
   neo4j_backup/
   ├── clinixai_v1_baseline_20250107.dump (5 PDFs, 2,773 chunks)
   ├── clinixai_v2_expanded_20250115.dump (15 PDFs, 8,421 chunks)
   └── clinixai_v3_full_20250201.dump (50 PDFs, 28,105 chunks)
   ```

2. **Document What's Included**
   Create a `README.txt` alongside each backup:
   ```
   ClinixAI Knowledge Base Backup
   Date: 2025-01-07
   Chunks: 2,773
   Documents: 5
   - WHO Emergency Care Guidelines
   - Malaria Treatment Protocol
   - Typhoid Fever Handbook
   - Cholera Response Manual
   - General Triage Guidelines
   ```

3. **Compress Large Backups**
   - Use `.zip` (Windows) or `.tar.gz` (Linux/Mac)
   - Compression reduces size by ~50-70%
   - Example: 100MB backup → 30-40MB compressed

4. **Test Before Sharing**
   Always test your backup on a clean instance:
   ```bash
   # Delete existing data
   docker-compose down -v
   docker-compose up -d
   
   # Restore your backup
   .\restore_neo4j.ps1 backup.dump
   
   # Verify
   curl http://localhost:8000/rag/stats
   ```

### Troubleshooting Backup/Restore

**Problem**: "Neo4j container not found"
```bash
# Solution: Start Neo4j first
docker-compose up -d neo4j
sleep 10  # Wait for it to be ready
.\backup_neo4j.ps1
```

**Problem**: "Restore failed: database already exists"
```bash
# Solution: The script should handle this, but if not:
docker exec clinixai-neo4j cypher-shell -u neo4j -p clinixai_neo4j_password "DROP DATABASE neo4j IF EXISTS"
.\restore_neo4j.ps1 backup.dump
```

**Problem**: "Backup file is corrupted"
```bash
# Solution: Verify the backup file
# Windows:
Get-FileHash backup.dump -Algorithm SHA256

# Linux/Mac:
sha256sum backup.dump

# Compare hash with original to ensure file wasn't corrupted during transfer
```

**Problem**: "After restore, chunk count is 0"
```bash
# Solution: Wait for Neo4j to fully start
docker logs clinixai-neo4j -f
# Wait for: "Started."

# Then check again
curl http://localhost:8000/rag/stats
```

---

## 📞 Support

- **GitHub Issues**: https://github.com/Thundastormgod/ClinixAI/issues
- **Team Slack**: #clinixai-dev
