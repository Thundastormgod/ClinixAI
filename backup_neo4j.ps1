# ClinixAI - Backup Neo4j Knowledge Graph
# Run this to export the Neo4j database with all medical documents
# 
# Usage: .\backup_neo4j.ps1

Write-Host "🗄️  ClinixAI Neo4j Backup Tool" -ForegroundColor Cyan
Write-Host ""

$backupDir = "neo4j_backup"
$timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
$backupFile = "$backupDir/clinixai_knowledge_$timestamp.dump"

# Create backup directory
if (-not (Test-Path $backupDir)) {
    New-Item -ItemType Directory -Path $backupDir -Force | Out-Null
    Write-Host "Created backup directory: $backupDir" -ForegroundColor Green
}

Write-Host "📦 Creating Neo4j database backup..." -ForegroundColor Yellow
Write-Host ""

# Method 1: Export using neo4j-admin dump (requires Neo4j container to be running)
Write-Host "Attempting to dump database from container..." -ForegroundColor Gray

try {
    # Create dump inside container
    docker exec clinixai-neo4j neo4j-admin database dump neo4j --to-path=/backups 2>&1 | Out-Null
    
    # Copy dump file from container to host
    docker cp clinixai-neo4j:/backups/neo4j.dump $backupFile
    
    if (Test-Path $backupFile) {
        $fileSize = (Get-Item $backupFile).Length / 1MB
        Write-Host "✅ Backup created successfully!" -ForegroundColor Green
        Write-Host "   File: $backupFile" -ForegroundColor White
        Write-Host "   Size: $([math]::Round($fileSize, 2)) MB" -ForegroundColor White
        
        # Create metadata file
        $metadata = @{
            timestamp = $timestamp
            chunks_count = "Run docker exec clinixai-neo4j cypher-shell -u neo4j -p clinixai_neo4j_password 'MATCH (c:Chunk) RETURN count(c)' to get count"
            documents_count = "Run docker exec clinixai-neo4j cypher-shell -u neo4j -p clinixai_neo4j_password 'MATCH (d:Document) RETURN count(d)' to get count"
            backup_method = "neo4j-admin dump"
        } | ConvertTo-Json
        
        $metadata | Out-File "$backupFile.metadata.json"
        
        Write-Host ""
        Write-Host "📤 To share with team:" -ForegroundColor Cyan
        Write-Host "   1. Compress: Compress-Archive -Path $backupFile -DestinationPath $backupDir/clinixai_knowledge.zip"
        Write-Host "   2. Upload to Google Drive/Dropbox/GitHub Release"
        Write-Host "   3. Share the download link"
        Write-Host ""
        Write-Host "🔄 To restore: .\restore_neo4j.ps1 $backupFile" -ForegroundColor Cyan
    }
    else {
        throw "Backup file not created"
    }
}
catch {
    Write-Host "❌ Backup failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  1. Check Neo4j is running: docker ps | Select-String neo4j"
    Write-Host "  2. Check logs: docker logs clinixai-neo4j"
    Write-Host "  3. Try restarting: docker restart clinixai-neo4j"
}
