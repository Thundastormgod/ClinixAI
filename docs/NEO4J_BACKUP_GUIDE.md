# Neo4j Knowledge Base Sharing - Quick Reference

## 🎯 Problem Solved

**Before**: Every team member had to:
- Upload 5+ PDFs individually
- Wait 5-10 minutes for chunking/embedding
- Use their own compute resources
- End up with duplicate processing

**After**: One person does it, everyone benefits!
- One person uploads PDFs and creates backup (~2 minutes)
- Team downloads backup file (~10-20 MB)
- Restore in 30 seconds
- Everyone has the same knowledge base

---

## 📤 For the Person Creating the Backup

```bash
# 1. Verify knowledge is loaded
curl http://localhost:8000/rag/stats

# 2. Create backup
.\backup_neo4j.ps1   # Windows
./backup_neo4j.sh    # Linux/Mac

# 3. Find backup
# Location: neo4j_backup/clinixai_knowledge_YYYYMMDD_HHMMSS.dump

# 4. Share via:
# - Google Drive (recommended)
# - Dropbox
# - GitHub Release (if < 100MB)
# - Team OneDrive
```

---

## 📥 For Team Members Restoring

```bash
# 1. Download backup file from shared link

# 2. Restore
.\restore_neo4j.ps1 path\to\backup.dump   # Windows
./restore_neo4j.sh path/to/backup.dump    # Linux/Mac

# 3. Verify
curl http://localhost:8000/rag/stats

# Should show same chunk count as original!
```

---

## ✅ What Gets Backed Up

- ✅ All document chunks (2,773+ for 5 PDFs)
- ✅ All vector embeddings (semantic search)
- ✅ All extracted entities (symptoms, diseases)
- ✅ All knowledge graph relationships
- ✅ Neo4j indexes

## ❌ What's NOT Backed Up

- ❌ AI model (llama.cpp) - download separately via `download_model.ps1`
- ❌ Docker containers
- ❌ Application code

---

## 📊 File Sizes

| Documents | Chunks | Backup Size |
|-----------|--------|-------------|
| 5 PDFs    | ~2,773 | ~10-20 MB   |
| 15 PDFs   | ~8,000 | ~40-60 MB   |
| 50 PDFs   | ~28,000| ~150-200 MB |

**Tip**: Compress before sharing to reduce by 50-70%!

---

## 🔧 Quick Troubleshooting

**"Container not found"**
```bash
docker-compose up -d neo4j
sleep 10
# Then retry backup/restore
```

**"After restore, stats show 0 chunks"**
```bash
# Wait for Neo4j to fully start
docker logs clinixai-neo4j -f
# Look for: "Started."
# Then check stats again
```

**"Restore says database exists"**
```bash
# The script should handle this automatically
# If not, manually drop:
docker exec clinixai-neo4j cypher-shell -u neo4j -p clinixai_neo4j_password "DROP DATABASE neo4j IF EXISTS"
```

---

## 📝 Best Practices

1. **Version your backups**
   - `clinixai_v1_baseline.dump` (5 PDFs)
   - `clinixai_v2_expanded.dump` (15 PDFs)

2. **Document what's included**
   - Create README.txt with list of PDFs
   - Note chunk count and date

3. **Test before sharing**
   - Clean instance: `docker-compose down -v`
   - Restore your backup
   - Verify stats match

4. **Keep backups up-to-date**
   - Create new backup when adding documents
   - Share with team immediately

---

## 🎓 Example Workflow

**Monday**: Sarah uploads 5 medical PDFs
```bash
# Sarah's machine
curl -X POST http://localhost:8000/rag/upload-pdf -F "file=@malaria.pdf"
curl -X POST http://localhost:8000/rag/upload-pdf -F "file=@typhoid.pdf"
# ... 3 more PDFs
.\backup_neo4j.ps1
# Uploads backup to Google Drive
```

**Tuesday**: Team members restore
```bash
# John's machine
# Downloads from Google Drive
.\restore_neo4j.ps1 clinixai_knowledge_20250107.dump
curl http://localhost:8000/rag/stats
# ✅ 2,773 chunks loaded instantly!

# Maria's machine
./restore_neo4j.sh clinixai_knowledge_20250107.dump
curl http://localhost:8000/rag/stats
# ✅ Same data, no uploading needed!
```

**Result**: Everyone has the same medical knowledge, no duplicate work!

---

## 🔗 Full Documentation

- **README.md** - Main documentation
- **TEAM_TESTING_GUIDE.md** - Comprehensive testing guide
- **GitHub**: https://github.com/Thundastormgod/ClinixAI
