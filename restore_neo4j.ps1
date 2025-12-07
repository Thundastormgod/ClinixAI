# ClinixAI - Restore Neo4j Knowledge Graph
# Run this to import a pre-existing Neo4j database backup
# 
# Usage: .\restore_neo4j.ps1 [backup_file.dump]
# Or:    .\restore_neo4j.ps1 (will prompt for file)

param(
    [string]$BackupFile = ""
)

Write-Host "🗄️  ClinixAI Neo4j Restore Tool" -ForegroundColor Cyan
Write-Host ""

# Prompt for backup file if not provided
if ([string]::IsNullOrEmpty($BackupFile)) {
    Write-Host "Enter path to backup file (.dump):" -ForegroundColor Yellow
    $BackupFile = Read-Host
}

# Check if file exists
if (-not (Test-Path $BackupFile)) {
    Write-Host "❌ Backup file not found: $BackupFile" -ForegroundColor Red
    exit 1
}

Write-Host "📥 Restoring from: $BackupFile" -ForegroundColor Green
Write-Host ""

# Confirm action
Write-Host "⚠️  WARNING: This will REPLACE the existing Neo4j database!" -ForegroundColor Yellow
$confirm = Read-Host "Continue? (yes/no)"
if ($confirm -ne "yes") {
    Write-Host "Restore cancelled." -ForegroundColor Gray
    exit 0
}

Write-Host ""
Write-Host "🔄 Stopping Neo4j container..." -ForegroundColor Yellow

try {
    # Stop Neo4j
    docker stop clinixai-neo4j | Out-Null
    Start-Sleep -Seconds 3
    
    # Copy dump file into container's backup directory
    Write-Host "📤 Copying backup file to container..." -ForegroundColor Yellow
    docker cp $BackupFile clinixai-neo4j:/backups/neo4j.dump
    
    # Start Neo4j
    Write-Host "🚀 Starting Neo4j..." -ForegroundColor Yellow
    docker start clinixai-neo4j | Out-Null
    Start-Sleep -Seconds 5
    
    # Restore database
    Write-Host "♻️  Restoring database..." -ForegroundColor Yellow
    docker exec clinixai-neo4j neo4j-admin database load neo4j --from-path=/backups --overwrite-destination=true
    
    # Restart Neo4j to load the restored database
    Write-Host "🔄 Restarting Neo4j..." -ForegroundColor Yellow
    docker restart clinixai-neo4j | Out-Null
    Start-Sleep -Seconds 10
    
    Write-Host ""
    Write-Host "✅ Restore complete!" -ForegroundColor Green
    Write-Host ""
    Write-Host "🔍 Verify the restore:" -ForegroundColor Cyan
    Write-Host "   1. Open Neo4j Browser: http://localhost:7475"
    Write-Host "   2. Login: neo4j / clinixai_neo4j_password"
    Write-Host "   3. Run: MATCH (n) RETURN labels(n)[0] AS type, count(*) AS count"
    Write-Host ""
    Write-Host "🧪 Test RAG: curl http://localhost:8000/rag/stats" -ForegroundColor Cyan
}
catch {
    Write-Host "❌ Restore failed: $_" -ForegroundColor Red
    Write-Host ""
    Write-Host "Troubleshooting:" -ForegroundColor Yellow
    Write-Host "  1. Check Neo4j logs: docker logs clinixai-neo4j"
    Write-Host "  2. Restart Neo4j: docker restart clinixai-neo4j"
    Write-Host "  3. Verify backup file is valid .dump file"
}
