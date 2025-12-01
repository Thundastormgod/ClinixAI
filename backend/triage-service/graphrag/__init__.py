# ClinixAI GraphRAG Pipeline
# PDF-to-Neo4j Knowledge Graph Extraction

"""
GraphRAG Pipeline for ClinixAI

This module transforms unstructured medical PDFs into a structured 
Neo4j knowledge graph using local LLM inference (Ollama).

Architecture:
1. Ingest: PyPDFLoader reads PDFs
2. Chunk: RecursiveCharacterTextSplitter breaks into logical blocks
3. Extract: LLM extracts entities and relationships
4. Deduplicate: Merge similar entities
5. Write: Commit to Neo4j via Cypher

Usage:
    from graphrag import GraphRAGService, get_graph_rag_service
    
    # Using singleton
    service = get_graph_rag_service(
        neo4j_uri="bolt://localhost:7687",
        neo4j_user="neo4j",
        neo4j_password="password",
        llm_backend="ollama"
    )
    
    # Ingest PDFs
    service.ingest_pdf("path/to/medical_guide.pdf")
    
    # Get RAG context
    context = service.get_rag_context("patient with chest pain")
"""

from .neo4j_client import Neo4jClient, GraphNode, GraphRelationship, GraphDocument
from .medical_schema import (
    MedicalSchema, 
    MEDICAL_NODE_TYPES, 
    MEDICAL_RELATIONSHIPS,
    TRIAGE_SCHEMA,
    DRUG_SCHEMA,
    FULL_MEDICAL_SCHEMA
)
from .graph_extractor import MedicalGraphExtractor, LangChainGraphExtractor
from .graph_rag_service import GraphRAGService, get_graph_rag_service

__all__ = [
    # Neo4j Client
    "Neo4jClient",
    "GraphNode",
    "GraphRelationship", 
    "GraphDocument",
    # Schema
    "MedicalSchema",
    "MEDICAL_NODE_TYPES",
    "MEDICAL_RELATIONSHIPS",
    "TRIAGE_SCHEMA",
    "DRUG_SCHEMA",
    "FULL_MEDICAL_SCHEMA",
    # Extractors
    "MedicalGraphExtractor",
    "LangChainGraphExtractor",
    # Main Service
    "GraphRAGService",
    "get_graph_rag_service"
]

__version__ = "1.0.0"
