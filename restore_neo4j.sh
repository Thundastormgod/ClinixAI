#!/bin/bash
# ClinixAI - Restore Neo4j Knowledge Graph (Linux/Mac)
# Run this to import a pre-existing Neo4j database backup
# 
# Usage: ./restore_neo4j.sh [backup_file.dump]

set -e

echo "🗄️  ClinixAI Neo4j Restore Tool"
echo ""

BACKUP_FILE=$1

# Prompt for backup file if not provided
if [ -z "$BACKUP_FILE" ]; then
    echo "Enter path to backup file (.dump):"
    read BACKUP_FILE
fi

# Check if file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "❌ Backup file not found: $BACKUP_FILE"
    exit 1
fi

echo "📥 Restoring from: $BACKUP_FILE"
echo ""

# Confirm action
echo "⚠️  WARNING: This will REPLACE the existing Neo4j database!"
read -p "Continue? (yes/no): " CONFIRM
if [ "$CONFIRM" != "yes" ]; then
    echo "Restore cancelled."
    exit 0
fi

echo ""
echo "🔄 Stopping Neo4j container..."

# Stop Neo4j
docker stop clinixai-neo4j
sleep 3

# Copy dump file into container
echo "📤 Copying backup file to container..."
docker cp $BACKUP_FILE clinixai-neo4j:/backups/neo4j.dump

# Start Neo4j
echo "🚀 Starting Neo4j..."
docker start clinixai-neo4j
sleep 5

# Restore database
echo "♻️  Restoring database..."
docker exec clinixai-neo4j neo4j-admin database load neo4j --from-path=/backups --overwrite-destination=true

# Restart Neo4j
echo "🔄 Restarting Neo4j..."
docker restart clinixai-neo4j
sleep 10

echo ""
echo "✅ Restore complete!"
echo ""
echo "🔍 Verify the restore:"
echo "   1. Open Neo4j Browser: http://localhost:7475"
echo "   2. Login: neo4j / clinixai_neo4j_password"
echo "   3. Run: MATCH (n) RETURN labels(n)[0] AS type, count(*) AS count"
echo ""
echo "🧪 Test RAG: curl http://localhost:8000/rag/stats"
