"""
Advanced GraphRAG Service for ClinixAI
======================================

Top-tier RAG system combining:
1. PDF Document Ingestion Pipeline
2. Neo4j Knowledge Graph Storage
3. Semantic Vector Embeddings (Sentence Transformers)
4. Hybrid Retrieval (Keyword + Semantic + Graph Traversal)
5. OpenRouter LLM Integration for Entity Extraction & QA

This is the production-ready RAG system for medical triage.
"""

import os
import re
import json
import hashlib
import logging
from typing import List, Dict, Any, Optional, Tuple
from pathlib import Path
from datetime import datetime
from dataclasses import dataclass, field
import asyncio

import httpx

# Neo4j imports
try:
    from neo4j import GraphDatabase
    NEO4J_AVAILABLE = True
except ImportError:
    NEO4J_AVAILABLE = False

# Embedding imports
try:
    from sentence_transformers import SentenceTransformer
    import numpy as np
    EMBEDDINGS_AVAILABLE = True
except ImportError:
    EMBEDDINGS_AVAILABLE = False

# PDF imports
try:
    from pypdf import PdfReader
    PDF_AVAILABLE = True
except ImportError:
    PDF_AVAILABLE = False

logger = logging.getLogger(__name__)


# ==================== DATA CLASSES ====================

@dataclass
class DocumentChunk:
    """A chunk of text from a document"""
    id: str
    text: str
    document_id: str
    document_name: str
    chunk_index: int
    embedding: Optional[List[float]] = None
    metadata: Dict[str, Any] = field(default_factory=dict)


@dataclass
class ExtractedEntity:
    """An entity extracted from text"""
    id: str
    name: str
    type: str
    description: Optional[str] = None
    properties: Dict[str, Any] = field(default_factory=dict)
    source_chunk_id: Optional[str] = None


@dataclass
class ExtractedRelationship:
    """A relationship between entities"""
    source_id: str
    target_id: str
    type: str
    properties: Dict[str, Any] = field(default_factory=dict)


@dataclass
class RAGContext:
    """Context retrieved for RAG"""
    chunks: List[DocumentChunk]
    entities: List[Dict[str, Any]]
    relationships: List[Dict[str, Any]]
    graph_paths: List[str]
    total_score: float
    retrieval_method: str


# ==================== EMBEDDING SERVICE ====================

class EmbeddingService:
    """
    Manages text embeddings using Sentence Transformers.
    Uses medical-optimized models when available.
    """
    
    # Medical-optimized embedding models (ranked by quality)
    MEDICAL_MODELS = [
        "sentence-transformers/all-MiniLM-L6-v2",  # Fast, good quality
        "sentence-transformers/all-mpnet-base-v2",  # Better quality
        "pritamdeka/S-PubMedBert-MS-MARCO",  # Medical-specific
    ]
    
    def __init__(self, model_name: str = None):
        if not EMBEDDINGS_AVAILABLE:
            raise ImportError("sentence-transformers not installed. Run: pip install sentence-transformers")
        
        self.model_name = model_name or self.MEDICAL_MODELS[0]
        self._model = None
        self._dimension = None
    
    def load(self):
        """Load the embedding model"""
        if self._model is None:
            logger.info(f"Loading embedding model: {self.model_name}")
            self._model = SentenceTransformer(self.model_name)
            # Get embedding dimension
            test_embedding = self._model.encode(["test"])
            self._dimension = len(test_embedding[0])
            logger.info(f"Embedding dimension: {self._dimension}")
    
    @property
    def dimension(self) -> int:
        """Get embedding dimension"""
        if self._dimension is None:
            self.load()
        return self._dimension
    
    def embed(self, texts: List[str]) -> List[List[float]]:
        """Generate embeddings for texts"""
        if self._model is None:
            self.load()
        
        embeddings = self._model.encode(texts, show_progress_bar=False)
        return [emb.tolist() for emb in embeddings]
    
    def embed_single(self, text: str) -> List[float]:
        """Generate embedding for single text"""
        return self.embed([text])[0]
    
    def similarity(self, embedding1: List[float], embedding2: List[float]) -> float:
        """Calculate cosine similarity between embeddings"""
        a = np.array(embedding1)
        b = np.array(embedding2)
        return float(np.dot(a, b) / (np.linalg.norm(a) * np.linalg.norm(b)))


# ==================== OPENROUTER EXTRACTOR ====================

class OpenRouterExtractor:
    """
    Uses OpenRouter LLMs for high-quality entity/relationship extraction.
    """
    
    EXTRACTION_PROMPT = """You are a medical knowledge extraction expert. Extract medical entities and relationships from the following text.

## Entity Types to Extract:
- Disease: Medical conditions, illnesses, disorders
- Symptom: Signs and symptoms patients experience
- Drug: Medications, pharmaceuticals
- Procedure: Medical procedures, treatments
- BodyPart: Anatomical locations
- RiskFactor: Risk factors for conditions
- RedFlag: Emergency warning signs
- LabTest: Laboratory tests
- VitalSign: Vital sign measurements

## Relationship Types:
- CAUSES: A causes B
- INDICATES: Symptom indicates Disease
- TREATS: Drug treats Disease
- AFFECTS: Disease affects BodyPart
- RISK_FACTOR_FOR: RiskFactor increases risk of Disease
- RED_FLAG_FOR: RedFlag is emergency sign for Disease
- DIAGNOSED_BY: Disease diagnosed by Test
- CONTRAINDICATED_FOR: Drug contraindicated for Condition

## Text to Analyze:
{text}

## Output Format (JSON only):
{{
  "entities": [
    {{"id": "e1", "name": "entity name", "type": "Disease|Symptom|Drug|etc", "description": "brief description"}}
  ],
  "relationships": [
    {{"source": "e1", "target": "e2", "type": "RELATIONSHIP_TYPE"}}
  ]
}}

Extract all medical knowledge. Return ONLY valid JSON."""

    def __init__(
        self,
        api_key: str = None,
        model: str = None,
        site_url: str = None,
        site_name: str = None
    ):
        self.api_key = api_key or os.getenv("OPENROUTER_API_KEY")
        # Use cheaper Llama model by default for entity extraction (saves ~90% vs Claude)
        self.model = model or os.getenv("OPENROUTER_EXTRACTION_MODEL", "meta-llama/llama-3.1-70b-instruct")
        self.site_url = site_url or os.getenv("OPENROUTER_SITE_URL", "https://clinixai.health")
        self.site_name = site_name or os.getenv("OPENROUTER_SITE_NAME", "ClinixAI")
        
        if not self.api_key:
            raise ValueError("OPENROUTER_API_KEY not set")
    
    async def extract(self, text: str) -> Tuple[List[ExtractedEntity], List[ExtractedRelationship]]:
        """Extract entities and relationships from text using OpenRouter"""
        prompt = self.EXTRACTION_PROMPT.format(text=text[:4000])  # Limit text length
        
        async with httpx.AsyncClient() as client:
            response = await client.post(
                "https://openrouter.ai/api/v1/chat/completions",
                headers={
                    "Authorization": f"Bearer {self.api_key}",
                    "Content-Type": "application/json",
                    "HTTP-Referer": self.site_url,
                    "X-Title": self.site_name,
                },
                json={
                    "model": self.model,
                    "messages": [
                        {"role": "system", "content": "You are a medical knowledge extraction expert. Always return valid JSON."},
                        {"role": "user", "content": prompt}
                    ],
                    "temperature": 0.1,
                    "max_tokens": 2000,
                },
                timeout=60.0,
            )
            
            if response.status_code != 200:
                logger.error(f"OpenRouter extraction failed: {response.status_code}")
                return [], []
            
            content = response.json()["choices"][0]["message"]["content"]
            return self._parse_extraction(content)
    
    def _parse_extraction(self, content: str) -> Tuple[List[ExtractedEntity], List[ExtractedRelationship]]:
        """Parse LLM extraction response"""
        # Extract JSON from response
        json_match = re.search(r'```json\s*(.*?)\s*```', content, re.DOTALL)
        if json_match:
            content = json_match.group(1)
        else:
            # Try to find raw JSON
            json_match = re.search(r'\{[\s\S]*\}', content)
            if json_match:
                content = json_match.group()
        
        try:
            data = json.loads(content)
        except json.JSONDecodeError as e:
            logger.warning(f"Failed to parse extraction JSON: {e}")
            return [], []
        
        entities = []
        for e in data.get("entities", []):
            entities.append(ExtractedEntity(
                id=e.get("id", hashlib.md5(e.get("name", "").encode()).hexdigest()[:8]),
                name=e.get("name", ""),
                type=e.get("type", "Entity"),
                description=e.get("description"),
                properties=e.get("properties", {})
            ))
        
        relationships = []
        for r in data.get("relationships", []):
            relationships.append(ExtractedRelationship(
                source_id=r.get("source", ""),
                target_id=r.get("target", ""),
                type=r.get("type", "RELATED_TO"),
                properties=r.get("properties", {})
            ))
        
        return entities, relationships


# ==================== NEO4J VECTOR STORE ====================

class Neo4jVectorStore:
    """
    Neo4j client with vector search capabilities.
    Stores document chunks with embeddings and extracted entities.
    """
    
    def __init__(
        self,
        uri: str = None,
        user: str = None,
        password: str = None,
        database: str = "neo4j"
    ):
        if not NEO4J_AVAILABLE:
            raise ImportError("neo4j not installed. Run: pip install neo4j")
        
        self.uri = uri or os.getenv("NEO4J_URI", "bolt://localhost:7687")
        self.user = user or os.getenv("NEO4J_USER", "neo4j")
        self.password = password or os.getenv("NEO4J_PASSWORD", "clinixai_neo4j_password")
        self.database = database
        self._driver = None
    
    def connect(self) -> bool:
        """Connect to Neo4j"""
        try:
            self._driver = GraphDatabase.driver(
                self.uri,
                auth=(self.user, self.password)
            )
            self._driver.verify_connectivity()
            logger.info(f"Connected to Neo4j at {self.uri}")
            return True
        except Exception as e:
            logger.error(f"Neo4j connection failed: {e}")
            return False
    
    def close(self):
        """Close connection"""
        if self._driver:
            self._driver.close()
    
    def setup_vector_index(self, embedding_dimension: int = 384):
        """Create vector index for semantic search"""
        with self._driver.session(database=self.database) as session:
            # Create vector index on Chunk nodes
            try:
                session.run("""
                    CREATE VECTOR INDEX chunk_embeddings IF NOT EXISTS
                    FOR (c:Chunk)
                    ON c.embedding
                    OPTIONS {indexConfig: {
                        `vector.dimensions`: $dimension,
                        `vector.similarity_function`: 'cosine'
                    }}
                """, dimension=embedding_dimension)
                logger.info(f"Created vector index with dimension {embedding_dimension}")
            except Exception as e:
                logger.info(f"Vector index may already exist: {e}")
            
            # Create full-text indexes
            try:
                session.run("""
                    CREATE FULLTEXT INDEX chunk_text IF NOT EXISTS
                    FOR (c:Chunk)
                    ON EACH [c.text]
                """)
            except:
                pass
            
            try:
                session.run("""
                    CREATE FULLTEXT INDEX entity_search IF NOT EXISTS
                    FOR (n:Disease|Symptom|Drug|Procedure|BodyPart|RiskFactor|RedFlag)
                    ON EACH [n.name, n.description]
                """)
            except:
                pass
            
            # Create indexes for entity lookup
            for label in ["Disease", "Symptom", "Drug", "Procedure", "BodyPart", "RiskFactor", "RedFlag", "Document", "Chunk"]:
                try:
                    session.run(f"CREATE INDEX {label.lower()}_name IF NOT EXISTS FOR (n:{label}) ON (n.name)")
                except:
                    pass
    
    def add_document(self, doc_id: str, name: str, metadata: Dict[str, Any] = None):
        """Add a document node"""
        with self._driver.session(database=self.database) as session:
            session.run("""
                MERGE (d:Document {id: $id})
                SET d.name = $name,
                    d.created_at = datetime(),
                    d += $metadata
            """, id=doc_id, name=name, metadata=metadata or {})
    
    def add_chunk(self, chunk: DocumentChunk):
        """Add a chunk with embedding"""
        with self._driver.session(database=self.database) as session:
            session.run("""
                MERGE (c:Chunk {id: $id})
                SET c.text = $text,
                    c.document_id = $doc_id,
                    c.chunk_index = $chunk_index,
                    c.embedding = $embedding,
                    c.created_at = datetime()
                
                WITH c
                MATCH (d:Document {id: $doc_id})
                MERGE (c)-[:FROM_DOCUMENT]->(d)
            """, 
                id=chunk.id,
                text=chunk.text,
                doc_id=chunk.document_id,
                chunk_index=chunk.chunk_index,
                embedding=chunk.embedding
            )
    
    def add_entity(self, entity: ExtractedEntity, chunk_id: str = None):
        """Add an entity and link to source chunk"""
        with self._driver.session(database=self.database) as session:
            # Create entity with dynamic label
            session.run(f"""
                MERGE (e:{entity.type} {{name: $name}})
                SET e.id = $id,
                    e.description = $description,
                    e += $properties,
                    e.updated_at = datetime()
            """,
                id=entity.id,
                name=entity.name,
                description=entity.description,
                properties=entity.properties
            )
            
            # Link to chunk if provided
            if chunk_id:
                session.run(f"""
                    MATCH (e:{entity.type} {{name: $name}})
                    MATCH (c:Chunk {{id: $chunk_id}})
                    MERGE (e)-[:MENTIONED_IN]->(c)
                """, name=entity.name, chunk_id=chunk_id)
    
    def add_relationship(self, rel: ExtractedRelationship, entity_map: Dict[str, str]):
        """Add a relationship between entities"""
        source_name = entity_map.get(rel.source_id)
        target_name = entity_map.get(rel.target_id)
        
        if not source_name or not target_name:
            return
        
        with self._driver.session(database=self.database) as session:
            # Dynamic relationship type
            session.run(f"""
                MATCH (a) WHERE a.name = $source
                MATCH (b) WHERE b.name = $target
                MERGE (a)-[r:{rel.type}]->(b)
                SET r += $properties
            """,
                source=source_name,
                target=target_name,
                properties=rel.properties
            )
    
    def vector_search(self, embedding: List[float], limit: int = 5) -> List[Dict[str, Any]]:
        """Search chunks by vector similarity"""
        with self._driver.session(database=self.database) as session:
            result = session.run("""
                CALL db.index.vector.queryNodes('chunk_embeddings', $limit, $embedding)
                YIELD node, score
                RETURN node.id AS id, node.text AS text, node.document_id AS doc_id, score
                ORDER BY score DESC
            """, embedding=embedding, limit=limit)
            
            return [dict(record) for record in result]
    
    def keyword_search(self, search_text: str, limit: int = 5) -> List[Dict[str, Any]]:
        """Search chunks by keyword (full-text)"""
        with self._driver.session(database=self.database) as session:
            result = session.run("""
                CALL db.index.fulltext.queryNodes('chunk_text', $search_text)
                YIELD node, score
                RETURN node.id AS id, node.text AS text, node.document_id AS doc_id, score
                LIMIT $limit
            """, search_text=search_text, limit=limit)
            
            return [dict(record) for record in result]
    
    def entity_search(self, search_text: str, limit: int = 10) -> List[Dict[str, Any]]:
        """Search entities by name/description"""
        with self._driver.session(database=self.database) as session:
            result = session.run("""
                CALL db.index.fulltext.queryNodes('entity_search', $search_text)
                YIELD node, score
                RETURN labels(node)[0] AS type, node.name AS name, 
                       node.description AS description, score
                LIMIT $limit
            """, search_text=search_text, limit=limit)
            
            return [dict(record) for record in result]
    
    def get_entity_context(self, entity_name: str, depth: int = 2) -> Dict[str, Any]:
        """Get entity and its graph neighborhood"""
        with self._driver.session(database=self.database) as session:
            result = session.run("""
                MATCH (e) WHERE e.name = $name
                CALL apoc.path.subgraphAll(e, {maxLevel: $depth})
                YIELD nodes, relationships
                RETURN e AS entity,
                       [n IN nodes | {name: n.name, type: labels(n)[0]}] AS related_entities,
                       [r IN relationships | {type: type(r), source: startNode(r).name, target: endNode(r).name}] AS relations
            """, name=entity_name, depth=depth)
            
            record = result.single()
            if record:
                return dict(record)
            return {}
    
    def get_symptom_disease_paths(self, symptoms: List[str]) -> List[Dict[str, Any]]:
        """Find diseases related to given symptoms"""
        with self._driver.session(database=self.database) as session:
            result = session.run("""
                UNWIND $symptoms AS symptom_name
                MATCH (s:Symptom)-[r:INDICATES|MANIFESTS_AS|ASSOCIATED_WITH]-(d:Disease)
                WHERE toLower(s.name) CONTAINS toLower(symptom_name)
                RETURN d.name AS disease, 
                       collect(DISTINCT s.name) AS matching_symptoms,
                       count(DISTINCT s) AS symptom_count
                ORDER BY symptom_count DESC
                LIMIT 10
            """, symptoms=symptoms)
            
            return [dict(record) for record in result]
    
    def get_red_flags(self, symptoms: List[str]) -> List[Dict[str, Any]]:
        """Find red flags related to symptoms"""
        with self._driver.session(database=self.database) as session:
            result = session.run("""
                UNWIND $symptoms AS symptom_name
                MATCH (s:Symptom)-[:RED_FLAG_FOR|INDICATES]->(rf:RedFlag)
                WHERE toLower(s.name) CONTAINS toLower(symptom_name)
                RETURN rf.name AS red_flag, rf.description AS description,
                       collect(DISTINCT s.name) AS related_symptoms
            """, symptoms=symptoms)
            
            return [dict(record) for record in result]
    
    def get_stats(self) -> Dict[str, int]:
        """Get database statistics"""
        with self._driver.session(database=self.database) as session:
            result = session.run("""
                MATCH (n)
                WITH labels(n)[0] AS label, count(*) AS count
                RETURN label, count
                ORDER BY count DESC
            """)
            
            stats = {}
            for record in result:
                stats[record["label"]] = record["count"]
            return stats


# ==================== ADVANCED RAG SERVICE ====================

class AdvancedRAGService:
    """
    Production-ready GraphRAG service combining:
    - PDF ingestion with chunking
    - OpenRouter LLM entity extraction
    - Sentence Transformer embeddings
    - Neo4j graph + vector storage
    - Hybrid retrieval (semantic + keyword + graph)
    """
    
    def __init__(
        self,
        neo4j_uri: str = None,
        neo4j_user: str = None,
        neo4j_password: str = None,
        openrouter_api_key: str = None,
        embedding_model: str = None,
        chunk_size: int = 500,
        chunk_overlap: int = 100
    ):
        # Components
        self.vector_store = Neo4jVectorStore(
            uri=neo4j_uri,
            user=neo4j_user,
            password=neo4j_password
        )
        self.embedder = EmbeddingService(model_name=embedding_model)
        self.extractor = OpenRouterExtractor(api_key=openrouter_api_key)
        
        # Config
        self.chunk_size = chunk_size
        self.chunk_overlap = chunk_overlap
        
        # State
        self._initialized = False
    
    def initialize(self) -> bool:
        """Initialize all components"""
        if self._initialized:
            return True
        
        # Connect to Neo4j
        if not self.vector_store.connect():
            return False
        
        # Load embeddings model
        self.embedder.load()
        
        # Setup vector index
        self.vector_store.setup_vector_index(self.embedder.dimension)
        
        self._initialized = True
        logger.info("AdvancedRAGService initialized")
        return True
    
    def close(self):
        """Clean up resources"""
        self.vector_store.close()
        self._initialized = False
    
    # ==================== PDF INGESTION ====================
    
    def _load_pdf(self, pdf_path: str) -> str:
        """Extract text from PDF"""
        if not PDF_AVAILABLE:
            raise ImportError("pypdf not installed. Run: pip install pypdf")
        
        reader = PdfReader(pdf_path)
        text_parts = []
        
        for page in reader.pages:
            text = page.extract_text()
            if text:
                text_parts.append(text)
        
        return "\n\n".join(text_parts)
    
    def _chunk_text(self, text: str) -> List[str]:
        """Split text into overlapping chunks"""
        chunks = []
        start = 0
        
        while start < len(text):
            end = start + self.chunk_size
            
            # Try to end at sentence boundary
            if end < len(text):
                for sep in [". ", "\n\n", "\n", " "]:
                    last_sep = text.rfind(sep, start + self.chunk_size // 2, end)
                    if last_sep > start:
                        end = last_sep + len(sep)
                        break
            
            chunk = text[start:end].strip()
            if chunk:
                chunks.append(chunk)
            
            start = end - self.chunk_overlap
        
        return chunks
    
    async def ingest_pdf(
        self,
        pdf_path: str,
        extract_entities: bool = False,  # DEFAULT OFF to save OpenRouter credits
        batch_size: int = 10,  # Process N chunks at a time for entity extraction
        progress_callback: callable = None
    ) -> Dict[str, Any]:
        """
        Ingest a PDF into the knowledge graph.
        
        Args:
            pdf_path: Path to PDF file
            extract_entities: Use LLM to extract medical entities (costs OpenRouter credits!)
            batch_size: How many chunks to process for entity extraction (lower = less cost)
            progress_callback: Optional callback(progress, total, message)
        
        Returns:
            Ingestion statistics
        
        Cost-saving notes:
        - Embeddings are FREE (local sentence-transformers)
        - Neo4j storage is FREE (local database)
        - Entity extraction uses OpenRouter API (COSTS CREDITS)
        - Set extract_entities=False for free ingestion (semantic search still works!)
        - Use batch_size to limit entity extraction costs
        """
        if not self._initialized:
            self.initialize()
        
        pdf_path = Path(pdf_path)
        if not pdf_path.exists():
            raise FileNotFoundError(f"PDF not found: {pdf_path}")
        
        # Generate document ID
        doc_id = hashlib.md5(pdf_path.name.encode()).hexdigest()[:12]
        
        logger.info(f"Ingesting PDF: {pdf_path.name}")
        
        # Step 1: Load PDF
        if progress_callback:
            progress_callback(5, 100, f"Loading {pdf_path.name}...")
        
        text = self._load_pdf(str(pdf_path))
        logger.info(f"Extracted {len(text)} characters")
        
        # Step 2: Chunk text
        if progress_callback:
            progress_callback(10, 100, "Chunking text...")
        
        chunks = self._chunk_text(text)
        logger.info(f"Created {len(chunks)} chunks")
        
        # Step 3: Create document node
        self.vector_store.add_document(
            doc_id=doc_id,
            name=pdf_path.name,
            metadata={"path": str(pdf_path), "chunks": len(chunks)}
        )
        
        # Step 4: Process chunks
        total_entities = 0
        total_relationships = 0
        
        # Track how many chunks we've done entity extraction for
        entity_extraction_count = 0
        
        for i, chunk_text in enumerate(chunks):
            if progress_callback:
                progress = 15 + int(75 * i / len(chunks))
                progress_callback(progress, 100, f"Processing chunk {i+1}/{len(chunks)}...")
            
            chunk_id = f"{doc_id}_chunk_{i}"
            
            # Generate embedding (FREE - local)
            embedding = self.embedder.embed_single(chunk_text)
            
            # Create chunk object
            chunk = DocumentChunk(
                id=chunk_id,
                text=chunk_text,
                document_id=doc_id,
                document_name=pdf_path.name,
                chunk_index=i,
                embedding=embedding
            )
            
            # Store chunk with embedding (FREE - local Neo4j)
            self.vector_store.add_chunk(chunk)
            
            # Extract entities (if enabled AND within batch limit)
            # This is the ONLY part that costs OpenRouter credits!
            if extract_entities and entity_extraction_count < batch_size:
                try:
                    entities, relationships = await self.extractor.extract(chunk_text)
                    entity_extraction_count += 1
                    
                    # Build entity map for relationship linking
                    entity_map = {e.id: e.name for e in entities}
                    
                    # Store entities
                    for entity in entities:
                        entity.source_chunk_id = chunk_id
                        self.vector_store.add_entity(entity, chunk_id)
                        total_entities += 1
                    
                    # Store relationships
                    for rel in relationships:
                        self.vector_store.add_relationship(rel, entity_map)
                        total_relationships += 1
                    
                    # Log batch progress
                    if entity_extraction_count >= batch_size:
                        logger.info(f"Reached batch limit ({batch_size}), skipping entity extraction for remaining chunks")
                        
                except Exception as e:
                    logger.warning(f"Entity extraction failed for chunk {i}: {e}")
        
        if progress_callback:
            progress_callback(100, 100, "Complete!")
        
        stats = {
            "document_id": doc_id,
            "file": pdf_path.name,
            "chunks": len(chunks),
            "entities_extracted": total_entities,
            "relationships_extracted": total_relationships,
            "timestamp": datetime.utcnow().isoformat()
        }
        
        logger.info(f"Ingestion complete: {stats}")
        return stats
    
    async def ingest_directory(
        self,
        directory: str,
        pattern: str = "*.pdf",
        extract_entities: bool = True
    ) -> List[Dict[str, Any]]:
        """Ingest all PDFs in a directory"""
        directory = Path(directory)
        pdf_files = list(directory.glob(pattern))
        
        results = []
        for pdf_path in pdf_files:
            try:
                stats = await self.ingest_pdf(
                    str(pdf_path),
                    extract_entities=extract_entities
                )
                results.append(stats)
            except Exception as e:
                logger.error(f"Failed to ingest {pdf_path}: {e}")
                results.append({"file": pdf_path.name, "error": str(e)})
        
        return results
    
    # ==================== HYBRID RETRIEVAL ====================
    
    def retrieve(
        self,
        query: str,
        top_k: int = 5,
        include_entities: bool = True,
        include_graph_context: bool = True
    ) -> RAGContext:
        """
        Hybrid retrieval combining semantic, keyword, and graph search.
        
        Args:
            query: User query (symptoms, questions, etc.)
            top_k: Number of chunks to retrieve
            include_entities: Search for related entities
            include_graph_context: Include graph neighborhood
        
        Returns:
            RAGContext with retrieved information
        """
        if not self._initialized:
            self.initialize()
        
        # 1. Semantic search (vector similarity)
        query_embedding = self.embedder.embed_single(query)
        semantic_results = self.vector_store.vector_search(query_embedding, limit=top_k)
        
        # 2. Keyword search (full-text)
        keyword_results = self.vector_store.keyword_search(search_text=query, limit=top_k)
        
        # 3. Merge and deduplicate results
        seen_ids = set()
        chunks = []
        
        # Weight semantic results higher
        for result in semantic_results:
            if result["id"] not in seen_ids:
                seen_ids.add(result["id"])
                chunks.append(DocumentChunk(
                    id=result["id"],
                    text=result["text"],
                    document_id=result["doc_id"],
                    document_name="",
                    chunk_index=0,
                    metadata={"score": result["score"], "method": "semantic"}
                ))
        
        for result in keyword_results:
            if result["id"] not in seen_ids:
                seen_ids.add(result["id"])
                chunks.append(DocumentChunk(
                    id=result["id"],
                    text=result["text"],
                    document_id=result["doc_id"],
                    document_name="",
                    chunk_index=0,
                    metadata={"score": result["score"] * 0.8, "method": "keyword"}
                ))
        
        # 4. Entity search
        entities = []
        if include_entities:
            entity_results = self.vector_store.entity_search(search_text=query, limit=10)
            entities = entity_results
        
        # 5. Graph context (symptom -> disease paths)
        graph_paths = []
        relationships = []
        
        if include_graph_context:
            # Extract potential symptoms from query
            symptoms = self._extract_symptoms_from_query(query)
            
            if symptoms:
                # Get disease paths
                disease_paths = self.vector_store.get_symptom_disease_paths(symptoms)
                for path in disease_paths:
                    graph_paths.append(
                        f"Symptoms {path['matching_symptoms']} may indicate {path['disease']}"
                    )
                
                # Get red flags
                red_flags = self.vector_store.get_red_flags(symptoms)
                for rf in red_flags:
                    graph_paths.append(
                        f"⚠️ RED FLAG: {rf['red_flag']} - {rf.get('description', '')}"
                    )
        
        # Calculate total relevance score
        total_score = sum(c.metadata.get("score", 0) for c in chunks)
        
        return RAGContext(
            chunks=chunks[:top_k],
            entities=entities,
            relationships=relationships,
            graph_paths=graph_paths,
            total_score=total_score,
            retrieval_method="hybrid"
        )
    
    def _extract_symptoms_from_query(self, query: str) -> List[str]:
        """Extract potential symptom keywords from query"""
        # Common symptom patterns
        symptom_keywords = [
            "pain", "ache", "fever", "cough", "headache", "nausea", "vomiting",
            "diarrhea", "fatigue", "weakness", "dizziness", "shortness of breath",
            "chest pain", "abdominal pain", "sore throat", "runny nose", "rash",
            "swelling", "bleeding", "numbness", "tingling", "confusion"
        ]
        
        query_lower = query.lower()
        found_symptoms = []
        
        for symptom in symptom_keywords:
            if symptom in query_lower:
                found_symptoms.append(symptom)
        
        # Also split query into potential multi-word symptoms
        words = query_lower.split()
        for i in range(len(words)):
            for j in range(i+1, min(i+4, len(words)+1)):
                phrase = " ".join(words[i:j])
                if len(phrase) > 3 and phrase not in found_symptoms:
                    found_symptoms.append(phrase)
        
        return found_symptoms[:10]  # Limit to 10 symptoms
    
    def format_context_for_llm(self, rag_context: RAGContext) -> str:
        """Format retrieved context for LLM prompt"""
        parts = []
        
        # Add document chunks
        if rag_context.chunks:
            parts.append("## Relevant Medical Knowledge:\n")
            for i, chunk in enumerate(rag_context.chunks, 1):
                parts.append(f"[Source {i}]: {chunk.text[:500]}...\n")
        
        # Add entity information
        if rag_context.entities:
            parts.append("\n## Related Medical Entities:\n")
            for entity in rag_context.entities[:5]:
                parts.append(f"- {entity['type']}: {entity['name']}")
                if entity.get('description'):
                    parts.append(f" - {entity['description']}")
                parts.append("\n")
        
        # Add graph paths
        if rag_context.graph_paths:
            parts.append("\n## Clinical Relationships:\n")
            for path in rag_context.graph_paths:
                parts.append(f"- {path}\n")
        
        return "".join(parts)
    
    def get_stats(self) -> Dict[str, Any]:
        """Get service statistics"""
        if not self._initialized:
            return {"status": "not_initialized"}
        
        db_stats = self.vector_store.get_stats()
        return {
            "status": "initialized",
            "embedding_model": self.embedder.model_name,
            "embedding_dimension": self.embedder.dimension,
            "database_stats": db_stats
        }


# ==================== FACTORY FUNCTION ====================

def create_rag_service(
    neo4j_uri: str = None,
    neo4j_user: str = None,
    neo4j_password: str = None
) -> AdvancedRAGService:
    """Create and initialize the RAG service"""
    service = AdvancedRAGService(
        neo4j_uri=neo4j_uri or os.getenv("NEO4J_URI", "bolt://localhost:7687"),
        neo4j_user=neo4j_user or os.getenv("NEO4J_USER", "neo4j"),
        neo4j_password=neo4j_password or os.getenv("NEO4J_PASSWORD", "clinixai_neo4j_password")
    )
    service.initialize()
    return service
