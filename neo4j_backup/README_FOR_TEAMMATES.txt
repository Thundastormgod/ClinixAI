================================================================================
           CLINIXAI NEO4J KNOWLEDGE BASE BACKUP
================================================================================

This folder contains the pre-populated Neo4j GraphRAG knowledge base for 
ClinixAI. Use this to skip the document upload and processing step.

CONTENTS:
---------
• neo4j.dump - Neo4j database backup (276MB processed, ~17MB compressed)
  - 2,773 document chunks
  - 5 medical PDF documents indexed
  - 241 Procedures, 153 Diseases, 121 Symptoms, 53 Body Parts
  - 43 Vital Signs, 38 Risk Factors, 23 Lab Tests, 20 Red Flags, 14 Drugs

================================================================================
                          HOW TO USE THIS BACKUP
================================================================================

STEP 1: Clone the repository
----------------------------
git clone https://github.com/Thundastormgod/ClinixAI.git
cd ClinixAI

STEP 2: Copy this backup folder
-------------------------------
Copy the entire "neo4j_backup" folder (containing this README and neo4j.dump) 
into the ClinixAI project root folder.

STEP 3: Restore the database
----------------------------
WINDOWS (PowerShell):
  .\restore_neo4j.ps1

LINUX/MAC:
  chmod +x restore_neo4j.sh
  ./restore_neo4j.sh

STEP 4: Start the application
-----------------------------
docker-compose up -d

STEP 5: Verify it works
-----------------------
Open: http://localhost:8000/docs
Try: POST /api/triage/consult with a medical question
Or:  http://localhost:8088 for the Flutter web app

================================================================================
                           MANUAL RESTORE (Alternative)
================================================================================

If the scripts don't work, restore manually:

1. Make sure docker-compose is running:
   docker-compose up -d

2. Stop the Neo4j container:
   docker stop clinixai-neo4j

3. Copy the dump file into the container:
   docker cp neo4j_backup/neo4j.dump clinixai-neo4j:/backups/neo4j.dump

4. Run a temporary container to restore:
   docker run --rm --volumes-from clinixai-neo4j -v ./neo4j_backup:/backup neo4j:5.15-community neo4j-admin database load neo4j --from-path=/backup --overwrite-destination=true

5. Start Neo4j again:
   docker start clinixai-neo4j

================================================================================
                              TROUBLESHOOTING
================================================================================

Issue: "Container not found"
Solution: Run 'docker-compose up -d' first to create containers

Issue: "Database in use" error
Solution: Stop Neo4j: docker stop clinixai-neo4j

Issue: "Permission denied"
Solution: Run terminal as Administrator (Windows) or use sudo (Linux/Mac)

Issue: Restore succeeds but RAG doesn't work
Solution: 
  1. Check Neo4j browser at http://localhost:7475
  2. Login: neo4j / clinixai_neo4j_password
  3. Run: MATCH (n) RETURN count(n)
  4. Should return ~3,500+ nodes

================================================================================
                             WHAT'S INCLUDED
================================================================================

This knowledge base contains medical information extracted from:
• Clinical triage protocols
• Symptom assessment guidelines  
• Emergency care procedures
• Disease diagnostic criteria
• Vital sign interpretation guides

The GraphRAG system uses this knowledge to provide AI-powered medical triage
assistance with evidence-based recommendations.

================================================================================
Created: December 7, 2025
ClinixAI Team - Hackathon Project
================================================================================
