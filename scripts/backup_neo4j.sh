#!/bin/bash
# ClinixAI - Backup Neo4j Knowledge Graph (Linux/Mac)
# Run this to export the Neo4j database with all medical documents
# 
# Usage: ./backup_neo4j.sh

set -e

echo "🗄️  ClinixAI Neo4j Backup Tool"
echo ""

BACKUP_DIR="neo4j_backup"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="$BACKUP_DIR/clinixai_knowledge_$TIMESTAMP.dump"

# Create backup directory
mkdir -p $BACKUP_DIR
echo "Created backup directory: $BACKUP_DIR"

echo "📦 Creating Neo4j database backup..."
echo ""

# Create dump inside container
docker exec clinixai-neo4j neo4j-admin database dump neo4j --to-path=/backups

# Copy dump file from container to host
docker cp clinixai-neo4j:/backups/neo4j.dump $BACKUP_FILE

if [ -f "$BACKUP_FILE" ]; then
    FILE_SIZE=$(du -h "$BACKUP_FILE" | cut -f1)
    echo "✅ Backup created successfully!"
    echo "   File: $BACKUP_FILE"
    echo "   Size: $FILE_SIZE"
    
    # Create metadata
    cat > "$BACKUP_FILE.metadata.json" << EOF
{
  "timestamp": "$TIMESTAMP",
  "backup_method": "neo4j-admin dump",
  "restore_command": "./restore_neo4j.sh $BACKUP_FILE"
}
EOF
    
    echo ""
    echo "📤 To share with team:"
    echo "   1. Compress: tar -czf $BACKUP_DIR/clinixai_knowledge.tar.gz $BACKUP_FILE"
    echo "   2. Upload to Google Drive/Dropbox/GitHub Release"
    echo "   3. Share the download link"
    echo ""
    echo "🔄 To restore: ./restore_neo4j.sh $BACKUP_FILE"
else
    echo "❌ Backup file not created"
    exit 1
fi
