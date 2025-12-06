"""
Upload PDF Documents to ClinixAI RAG System
=============================================

This script uploads all PDF files from the docs folder to the 
Neo4j-powered GraphRAG system for medical knowledge retrieval.
"""

import os
import sys
import time
import requests
from pathlib import Path

# Configuration
TRIAGE_SERVICE_URL = "http://localhost:8000"
DOCS_DIR = Path(__file__).parent / "docs"

def check_service_health():
    """Check if triage service is running"""
    try:
        r = requests.get(f"{TRIAGE_SERVICE_URL}/health", timeout=10)
        if r.status_code == 200:
            print("✅ Triage service is healthy")
            return True
    except Exception as e:
        print(f"❌ Triage service not reachable: {e}")
    return False

def get_rag_stats():
    """Get current RAG knowledge base stats"""
    try:
        r = requests.get(f"{TRIAGE_SERVICE_URL}/rag/stats", timeout=30)
        if r.status_code == 200:
            return r.json()
    except Exception as e:
        print(f"Error getting RAG stats: {e}")
    return None

def upload_pdf(pdf_path: Path):
    """Upload a single PDF to the RAG system"""
    print(f"\n📄 Uploading: {pdf_path.name}")
    print(f"   Size: {pdf_path.stat().st_size / 1024:.1f} KB")
    
    try:
        with open(pdf_path, 'rb') as f:
            files = {'file': (pdf_path.name, f, 'application/pdf')}
            r = requests.post(
                f"{TRIAGE_SERVICE_URL}/rag/upload-pdf",
                files=files,
                timeout=300  # 5 minutes for large PDFs
            )
        
        if r.status_code == 200:
            result = r.json()
            chunks = result.get('chunks_created', 0)
            entities = result.get('entities_extracted', 0)
            print(f"   ✅ Success: {chunks} chunks, {entities} entities extracted")
            return True
        else:
            print(f"   ❌ Failed: {r.status_code} - {r.text[:200]}")
            return False
    except requests.exceptions.Timeout:
        print(f"   ⏳ Timeout - PDF may be processing in background")
        return False
    except Exception as e:
        print(f"   ❌ Error: {e}")
        return False

def main():
    print("=" * 60)
    print("  ClinixAI PDF Upload to GraphRAG")
    print("=" * 60)
    
    # Check service health
    if not check_service_health():
        print("\n❌ Please ensure the triage-service is running:")
        print("   docker-compose up -d triage-service")
        sys.exit(1)
    
    # Get initial stats
    print("\n📊 Current RAG Stats:")
    stats = get_rag_stats()
    if stats:
        print(f"   Status: {stats.get('status', 'unknown')}")
        print(f"   Embedding Model: {stats.get('embedding_model', 'unknown')}")
    
    # Find PDF files
    if not DOCS_DIR.exists():
        print(f"\n❌ Docs directory not found: {DOCS_DIR}")
        sys.exit(1)
    
    pdf_files = list(DOCS_DIR.glob("*.pdf"))
    if not pdf_files:
        print(f"\n❌ No PDF files found in {DOCS_DIR}")
        sys.exit(1)
    
    print(f"\n📁 Found {len(pdf_files)} PDF files to upload:")
    for pdf in pdf_files:
        print(f"   - {pdf.name}")
    
    # Upload each PDF
    print("\n" + "=" * 60)
    print("  Starting Upload Process")
    print("=" * 60)
    
    success_count = 0
    failed_count = 0
    
    for i, pdf_path in enumerate(pdf_files, 1):
        print(f"\n[{i}/{len(pdf_files)}]", end="")
        if upload_pdf(pdf_path):
            success_count += 1
        else:
            failed_count += 1
        
        # Small delay between uploads
        if i < len(pdf_files):
            time.sleep(2)
    
    # Final stats
    print("\n" + "=" * 60)
    print("  Upload Complete")
    print("=" * 60)
    print(f"\n✅ Successful: {success_count}")
    print(f"❌ Failed: {failed_count}")
    
    # Get final stats
    print("\n📊 Final RAG Stats:")
    stats = get_rag_stats()
    if stats:
        db_stats = stats.get('database_stats', {})
        print(f"   Documents: {db_stats.get('documents', 0)}")
        print(f"   Chunks: {db_stats.get('chunks', 0)}")
        print(f"   Entities: {db_stats.get('entities', 0)}")
        print(f"   Relationships: {db_stats.get('relationships', 0)}")
    
    print("\n🎉 The medical knowledge is now available for RAG-enhanced triage!")

if __name__ == "__main__":
    main()
