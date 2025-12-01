"""
GraphRAG Service for ClinixAI

High-level service combining:
- PDF ingestion and chunking
- LLM-based entity extraction
- Neo4j graph storage
- RAG context retrieval

This is the main interface for the GraphRAG pipeline.
"""

import os
import logging
from typing import List, Dict, Any, Optional
from pathlib import Path

from .neo4j_client import Neo4jClient, GraphDocument
from .medical_schema import MedicalSchema, TRIAGE_SCHEMA
from .graph_extractor import MedicalGraphExtractor, LangChainGraphExtractor

logger = logging.getLogger(__name__)


class GraphRAGService:
    """
    Main GraphRAG service for ClinixAI.
    
    Provides:
    - PDF-to-Graph ingestion pipeline
    - Medical entity extraction
    - Graph-based RAG context retrieval
    
    Usage:
        service = GraphRAGService()
        
        # Ingest PDFs
        service.ingest_pdf("path/to/medical_guide.pdf")
        service.ingest_directory("path/to/documents/")
        
        # Get RAG context for inference
        context = service.get_rag_context("patient with chest pain and dyspnea")
    """
    
    def __init__(
        self,
        neo4j_uri: str = None,
        neo4j_user: str = None,
        neo4j_password: str = None,
        llm_backend: str = "ollama",
        llm_model: str = None,
        ollama_url: str = None,
        schema: MedicalSchema = None,
        chunk_size: int = 500,
        chunk_overlap: int = 50
    ):
        # Neo4j connection
        self.neo4j = Neo4jClient(
            uri=neo4j_uri or os.getenv("NEO4J_URI", "bolt://localhost:7687"),
            user=neo4j_user or os.getenv("NEO4J_USER", "neo4j"),
            password=neo4j_password or os.getenv("NEO4J_PASSWORD", "clinixai_neo4j_password")
        )
        
        # Schema configuration
        self.schema = schema or TRIAGE_SCHEMA
        
        # Chunking parameters
        self.chunk_size = chunk_size
        self.chunk_overlap = chunk_overlap
        
        # LLM extractor
        self.extractor = self._setup_extractor(
            llm_backend=llm_backend,
            llm_model=llm_model,
            ollama_url=ollama_url
        )
        
        # State
        self._initialized = False
    
    def _setup_extractor(
        self,
        llm_backend: str,
        llm_model: str,
        ollama_url: str
    ) -> MedicalGraphExtractor:
        """Setup the appropriate graph extractor"""
        try:
            # Try LangChain extractor first (better for function-calling models)
            return LangChainGraphExtractor(
                llm_backend=llm_backend,
                model=llm_model,
                ollama_base_url=ollama_url or os.getenv("OLLAMA_BASE_URL", "http://localhost:11434"),
                schema=self.schema
            )
        except Exception as e:
            logger.info(f"Using basic extractor (LangChain unavailable): {e}")
            return MedicalGraphExtractor(
                llm_backend=llm_backend,
                model=llm_model,
                ollama_base_url=ollama_url or os.getenv("OLLAMA_BASE_URL", "http://localhost:11434"),
                schema=self.schema
            )
    
    def initialize(self) -> bool:
        """Initialize the service (connect to Neo4j, setup schema)"""
        if self._initialized:
            return True
        
        # Connect to Neo4j
        if not self.neo4j.connect():
            logger.error("Failed to connect to Neo4j")
            return False
        
        # Setup schema (indexes, constraints)
        try:
            self.neo4j.setup_schema()
            logger.info("Neo4j schema initialized")
        except Exception as e:
            logger.warning(f"Schema setup warning: {e}")
        
        self._initialized = True
        return True
    
    def close(self):
        """Close connections"""
        self.neo4j.close()
        self._initialized = False
    
    # ==================== PDF INGESTION ====================
    
    def _load_pdf(self, pdf_path: str) -> str:
        """Load text content from PDF"""
        try:
            from pypdf import PdfReader
            
            reader = PdfReader(pdf_path)
            text_parts = []
            
            for page in reader.pages:
                text = page.extract_text()
                if text:
                    text_parts.append(text)
            
            return "\n\n".join(text_parts)
            
        except ImportError:
            # Try langchain loader
            try:
                from langchain_community.document_loaders import PyPDFLoader
                loader = PyPDFLoader(pdf_path)
                documents = loader.load()
                return "\n\n".join([doc.page_content for doc in documents])
            except ImportError:
                raise ImportError("Install pypdf or langchain: pip install pypdf langchain-community")
    
    def _chunk_text(
        self,
        text: str,
        chunk_size: int = None,
        chunk_overlap: int = None
    ) -> List[str]:
        """Split text into chunks"""
        chunk_size = chunk_size or self.chunk_size
        chunk_overlap = chunk_overlap or self.chunk_overlap
        
        try:
            from langchain_text_splitters import RecursiveCharacterTextSplitter
            
            splitter = RecursiveCharacterTextSplitter(
                chunk_size=chunk_size,
                chunk_overlap=chunk_overlap,
                separators=["\n\n", "\n", ". ", " ", ""]
            )
            
            return splitter.split_text(text)
            
        except ImportError:
            # Simple fallback chunking
            chunks = []
            start = 0
            
            while start < len(text):
                end = start + chunk_size
                
                # Try to end at a sentence boundary
                if end < len(text):
                    # Look for period or newline
                    for sep in [". ", "\n\n", "\n", " "]:
                        last_sep = text.rfind(sep, start, end)
                        if last_sep > start:
                            end = last_sep + len(sep)
                            break
                
                chunks.append(text[start:end].strip())
                start = end - chunk_overlap
            
            return [c for c in chunks if c]
    
    def ingest_pdf(
        self,
        pdf_path: str,
        include_source: bool = True,
        progress_callback: callable = None
    ) -> Dict[str, Any]:
        """
        Ingest a PDF into the knowledge graph.
        
        Args:
            pdf_path: Path to the PDF file
            include_source: Link entities back to source chunks
            progress_callback: Optional callback(current, total, message)
        
        Returns:
            Statistics about the ingestion
        """
        if not self._initialized:
            self.initialize()
        
        pdf_path = Path(pdf_path)
        if not pdf_path.exists():
            raise FileNotFoundError(f"PDF not found: {pdf_path}")
        
        logger.info(f"Ingesting PDF: {pdf_path.name}")
        
        # Step 1: Load PDF
        if progress_callback:
            progress_callback(0, 100, f"Loading {pdf_path.name}...")
        
        text = self._load_pdf(str(pdf_path))
        logger.info(f"Loaded {len(text)} characters from PDF")
        
        # Step 2: Chunk text
        if progress_callback:
            progress_callback(10, 100, "Chunking text...")
        
        chunks = self._chunk_text(text)
        logger.info(f"Created {len(chunks)} chunks")
        
        # Step 3: Extract entities from each chunk
        total_nodes = 0
        total_relationships = 0
        
        for i, chunk in enumerate(chunks):
            if progress_callback:
                progress = 10 + int(80 * i / len(chunks))
                progress_callback(progress, 100, f"Extracting chunk {i+1}/{len(chunks)}...")
            
            try:
                graph_doc = self.extractor.extract(
                    text=chunk,
                    source=pdf_path.name,
                    metadata={
                        "chunk_id": f"{pdf_path.stem}_chunk_{i}",
                        "chunk_index": i,
                        "text": chunk[:500]  # Store first 500 chars
                    }
                )
                
                # Step 4: Write to Neo4j
                if graph_doc.nodes or graph_doc.relationships:
                    self.neo4j.add_graph_document(graph_doc, include_source=include_source)
                    total_nodes += len(graph_doc.nodes)
                    total_relationships += len(graph_doc.relationships)
                    
            except Exception as e:
                logger.warning(f"Failed to process chunk {i}: {e}")
        
        if progress_callback:
            progress_callback(100, 100, "Complete!")
        
        stats = {
            "file": pdf_path.name,
            "chunks": len(chunks),
            "nodes_created": total_nodes,
            "relationships_created": total_relationships
        }
        
        logger.info(f"Ingestion complete: {stats}")
        return stats
    
    def ingest_directory(
        self,
        directory: str,
        pattern: str = "*.pdf",
        progress_callback: callable = None
    ) -> List[Dict[str, Any]]:
        """Ingest all PDFs in a directory"""
        directory = Path(directory)
        
        if not directory.is_dir():
            raise NotADirectoryError(f"Not a directory: {directory}")
        
        pdf_files = list(directory.glob(pattern))
        logger.info(f"Found {len(pdf_files)} PDF files")
        
        results = []
        for i, pdf_path in enumerate(pdf_files):
            if progress_callback:
                progress_callback(i, len(pdf_files), f"Processing {pdf_path.name}...")
            
            try:
                stats = self.ingest_pdf(str(pdf_path))
                results.append(stats)
            except Exception as e:
                logger.error(f"Failed to ingest {pdf_path}: {e}")
                results.append({"file": pdf_path.name, "error": str(e)})
        
        return results
    
    def ingest_text(
        self,
        text: str,
        source: str = "manual_input",
        include_source: bool = True
    ) -> Dict[str, Any]:
        """Ingest raw text into the knowledge graph"""
        if not self._initialized:
            self.initialize()
        
        chunks = self._chunk_text(text)
        total_nodes = 0
        total_relationships = 0
        
        for i, chunk in enumerate(chunks):
            try:
                graph_doc = self.extractor.extract(
                    text=chunk,
                    source=source,
                    metadata={
                        "chunk_id": f"{source}_chunk_{i}",
                        "chunk_index": i,
                        "text": chunk[:500]
                    }
                )
                
                if graph_doc.nodes or graph_doc.relationships:
                    self.neo4j.add_graph_document(graph_doc, include_source=include_source)
                    total_nodes += len(graph_doc.nodes)
                    total_relationships += len(graph_doc.relationships)
                    
            except Exception as e:
                logger.warning(f"Failed to process chunk {i}: {e}")
        
        return {
            "source": source,
            "chunks": len(chunks),
            "nodes_created": total_nodes,
            "relationships_created": total_relationships
        }
    
    # ==================== RAG RETRIEVAL ====================
    
    def get_rag_context(
        self,
        query: str,
        max_tokens: int = 2000,
        include_graph: bool = True,
        include_chunks: bool = True,
        max_results: int = 10
    ) -> Dict[str, Any]:
        """
        Get RAG context from the knowledge graph for a query.
        
        Args:
            query: User query (symptoms, conditions, etc.)
            max_tokens: Approximate max context length
            include_graph: Include graph traversal results
            include_chunks: Include source chunk text
            max_results: Maximum number of results
        
        Returns:
            Dictionary with context, sources, entities, relationships, confidence
        """
        if not self._initialized:
            self.initialize()
        
        # Get context from Neo4j
        context_str = self.neo4j.get_rag_context(
            query=query,
            max_hops=2,
            limit=max_results
        )
        
        # Search for related entities
        entities = self.neo4j.search_entities(query=query, limit=max_results)
        
        # Get relationships for found entities
        relationships = []
        if entities:
            for entity in entities[:5]:  # Limit to first 5 for performance
                if 'name' in entity:
                    rels = self.neo4j.get_related_entities(entity['name'])
                    for rel in rels:
                        relationships.append({
                            'type': rel.get('relationship', 'RELATED_TO'),
                            'source_id': entity.get('id', ''),
                            'target_id': rel.get('id', ''),
                            'source_name': entity.get('name', ''),
                            'target_name': rel.get('name', ''),
                            'properties': rel.get('properties', {})
                        })
        
        # Get source attributions
        sources = set()
        for entity in entities:
            if 'source' in entity:
                sources.add(entity['source'])
        
        # Calculate confidence based on result quality
        confidence = min(1.0, len(entities) * 0.1 + 0.3) if entities else 0.2
        
        return {
            'context': context_str,
            'sources': list(sources),
            'entities': entities,
            'relationships': relationships,
            'confidence': confidence
        }
    
    async def get_rag_context_async(
        self,
        query: str,
        max_results: int = 10
    ) -> Dict[str, Any]:
        """Async wrapper for get_rag_context"""
        # For now, call sync method (Neo4j driver is async-safe)
        return self.get_rag_context(query=query, max_results=max_results)
    
    def search_entities(
        self,
        query: str,
        entity_type: str = None,
        limit: int = 20
    ) -> List[Dict[str, Any]]:
        """Search for entities in the knowledge graph"""
        if not self._initialized:
            self.initialize()
        
        labels = [entity_type] if entity_type else None
        return self.neo4j.search_entities(
            query=query,
            labels=labels,
            limit=limit
        )
    
    async def search_entities_async(
        self,
        query: str,
        entity_type: str = None,
        limit: int = 20
    ) -> List[Dict[str, Any]]:
        """Async wrapper for search_entities"""
        return self.search_entities(query=query, entity_type=entity_type, limit=limit)
    
    def search(
        self,
        query: str,
        entity_types: List[str] = None,
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """Search for entities in the knowledge graph"""
        if not self._initialized:
            self.initialize()
        
        return self.neo4j.search_entities(
            query=query,
            labels=entity_types,
            limit=limit
        )
    
    def get_red_flags_for_symptoms(self, symptoms: List[str]) -> List[str]:
        """Get red flags for given symptoms from the graph"""
        if not self._initialized:
            self.initialize()
        
        red_flags = []
        for symptom in symptoms:
            flags = self.neo4j.get_red_flags(symptom)
            red_flags.extend(flags)
        
        # Remove duplicates while preserving order
        seen = set()
        unique_flags = []
        for flag in red_flags:
            if flag not in seen:
                seen.add(flag)
                unique_flags.append(flag)
        
        return unique_flags
    
    async def get_red_flags_for_symptoms_async(self, symptoms: List[str]) -> List[str]:
        """Async wrapper for get_red_flags_for_symptoms"""
        return self.get_red_flags_for_symptoms(symptoms)
    
    def get_possible_conditions(self, symptoms: List[str]) -> List[Dict[str, Any]]:
        """Get possible conditions for given symptoms"""
        if not self._initialized:
            self.initialize()
        
        conditions = {}
        for symptom in symptoms:
            diseases = self.neo4j.get_symptom_diseases(symptom)
            for disease in diseases:
                name = disease.get('name', '')
                if name:
                    if name not in conditions:
                        conditions[name] = {
                            'name': name,
                            'probability': 0.0,
                            'matching_symptoms': [],
                            'properties': disease.get('properties', {})
                        }
                    conditions[name]['matching_symptoms'].append(symptom)
                    # Increase probability with each matching symptom
                    conditions[name]['probability'] = min(
                        1.0,
                        conditions[name]['probability'] + (1.0 / len(symptoms))
                    )
        
        # Sort by probability descending
        result = list(conditions.values())
        result.sort(key=lambda x: x['probability'], reverse=True)
        
        return result
    
    async def get_possible_conditions_async(self, symptoms: List[str]) -> List[Dict[str, Any]]:
        """Async wrapper for get_possible_conditions"""
        return self.get_possible_conditions(symptoms)
    
    def get_drug_interactions(self, drugs: List[str]) -> List[Dict[str, Any]]:
        """Get drug interactions from the knowledge graph"""
        if not self._initialized:
            self.initialize()
        
        interactions = []
        for i, drug1 in enumerate(drugs):
            for drug2 in drugs[i+1:]:
                # Query for interactions between drug pairs
                interaction = self.neo4j.get_drug_interaction(drug1, drug2)
                if interaction:
                    interactions.append(interaction)
        
        return interactions
    
    async def get_drug_interactions_async(self, drugs: List[str]) -> List[Dict[str, Any]]:
        """Async wrapper for get_drug_interactions"""
        return self.get_drug_interactions(drugs)
    
    def get_graph_stats(self) -> Dict[str, Any]:
        """Get knowledge graph statistics"""
        if not self._initialized:
            self.initialize()
        
        return self.neo4j.get_stats()
    
    async def get_graph_stats_async(self) -> Dict[str, Any]:
        """Async wrapper for get_graph_stats"""
        return self.get_graph_stats()
    
    def get_stats(self) -> Dict[str, Any]:
        """Get knowledge graph statistics"""
        if not self._initialized:
            self.initialize()
        
        return self.neo4j.get_stats()


# Singleton instance for easy access
_service_instance: Optional[GraphRAGService] = None


def get_graph_rag_service(**kwargs) -> GraphRAGService:
    """Get or create the GraphRAG service singleton"""
    global _service_instance
    
    if _service_instance is None:
        _service_instance = GraphRAGService(**kwargs)
    
    return _service_instance
