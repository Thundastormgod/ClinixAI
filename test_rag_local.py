import sys
import os
import asyncio
import json

# Add backend/triage-service to path so we can import graphrag
sys.path.append(os.path.join(os.getcwd(), "backend", "triage-service"))

from graphrag.graph_rag_service import get_graph_rag_service

async def main():
    print("🚀 Initializing GraphRAG Service...")
    
    # Initialize service
    # Note: Using default env vars which should match docker-compose
    # If running outside docker but connecting to docker services:
    # NEO4J_URI=bolt://localhost:7687
    # OLLAMA_BASE_URL=http://localhost:11434
    
    os.environ["NEO4J_URI"] = "bolt://localhost:7687"
    os.environ["NEO4J_USER"] = "neo4j"
    os.environ["NEO4J_PASSWORD"] = "clinixai_neo4j_password"
    os.environ["OLLAMA_BASE_URL"] = "http://localhost:11434"
    
    service = get_graph_rag_service()
    
    # 1. Ingest Sample Data
    print("\n📥 Ingesting sample medical data...")
    sample_text = """
    Malaria in Pregnancy:
    Malaria infection during pregnancy is a significant public health problem with substantial risks for the mother, her fetus, and the newborn. 
    In Africa, 30 million women living in malaria-endemic areas become pregnant each year.
    
    Risks to Mother:
    - Severe anemia
    - Cerebral malaria
    - Hypoglycemia
    - Puerperal sepsis
    - Death
    
    Risks to Fetus/Newborn:
    - Spontaneous abortion
    - Stillbirth
    - Premature delivery
    - Low birth weight (a leading cause of child mortality)
    - Congenital malaria
    
    Prevention and Treatment:
    Intermittent Preventive Treatment in pregnancy (IPTp) with sulfadoxine-pyrimethamine (SP) is recommended for all pregnant women in moderate to high transmission areas.
    Insecticide-treated nets (ITNs) should be used.
    Prompt diagnosis and effective treatment of malaria infections is crucial.
    Artemisinin-based combination therapies (ACTs) are generally safe in the second and third trimesters.
    """
    
    try:
        stats = service.ingest_text(sample_text, source="malaria_guidelines_v1.txt")
        print(f"✅ Ingestion complete: {stats}")
    except Exception as e:
        print(f"❌ Ingestion failed: {e}")
        return

    # 2. Query RAG
    query = "What are the risks of malaria for pregnant women and how should it be treated?"
    print(f"\n🔍 Querying: '{query}'")
    
    try:
        result = await service.get_rag_context_async(query)
        
        print("\n📊 RAG Context Retrieved:")
        print("-" * 50)
        print(result.get("context", "No context found"))
        print("-" * 50)
        
        print(f"\nEntities Found: {len(result.get('entities', []))}")
        for entity in result.get('entities', [])[:5]:
            print(f"- {entity.get('name')} ({entity.get('label')})")
            
        print(f"\nConfidence: {result.get('confidence')}")
        
    except Exception as e:
        print(f"❌ Query failed: {e}")

if __name__ == "__main__":
    asyncio.run(main())
