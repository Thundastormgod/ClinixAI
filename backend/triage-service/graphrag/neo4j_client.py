"""
Neo4j Client for ClinixAI GraphRAG

Provides:
- Connection management
- Cypher query execution
- Graph document ingestion
- Medical entity search
"""

import os
import logging
from typing import List, Dict, Any, Optional, Tuple
from dataclasses import dataclass
from contextlib import contextmanager

try:
    from neo4j import GraphDatabase, Driver, Session
    from neo4j.exceptions import ServiceUnavailable, AuthError
    NEO4J_AVAILABLE = True
except ImportError:
    NEO4J_AVAILABLE = False
    Driver = None
    Session = None

logger = logging.getLogger(__name__)


@dataclass
class GraphNode:
    """Represents a node in the knowledge graph"""
    id: str
    label: str
    properties: Dict[str, Any]
    
    def to_cypher_props(self) -> str:
        """Convert properties to Cypher format"""
        props = [f'{k}: ${k}' for k in self.properties.keys()]
        return '{' + ', '.join(props) + '}'


@dataclass  
class GraphRelationship:
    """Represents a relationship in the knowledge graph"""
    source_id: str
    target_id: str
    type: str
    properties: Dict[str, Any]


@dataclass
class GraphDocument:
    """A document containing extracted graph elements"""
    nodes: List[GraphNode]
    relationships: List[GraphRelationship]
    source: Optional[str] = None
    metadata: Optional[Dict[str, Any]] = None


class Neo4jClient:
    """
    Neo4j database client for GraphRAG operations.
    
    Usage:
        client = Neo4jClient(
            uri="bolt://localhost:7687",
            user="neo4j",
            password="password"
        )
        
        # Query the graph
        results = client.search_symptoms("fever", limit=10)
        
        # Get RAG context
        context = client.get_rag_context("patient with chest pain and shortness of breath")
    """
    
    def __init__(
        self,
        uri: str = None,
        user: str = None,
        password: str = None,
        database: str = "neo4j"
    ):
        if not NEO4J_AVAILABLE:
            raise ImportError("neo4j package not installed. Run: pip install neo4j")
        
        self.uri = uri or os.getenv("NEO4J_URI", "bolt://localhost:7687")
        self.user = user or os.getenv("NEO4J_USER", "neo4j")
        self.password = password or os.getenv("NEO4J_PASSWORD", "clinixai_neo4j_password")
        self.database = database
        
        self._driver: Optional[Driver] = None
        
    def connect(self) -> bool:
        """Establish connection to Neo4j"""
        try:
            self._driver = GraphDatabase.driver(
                self.uri,
                auth=(self.user, self.password)
            )
            # Verify connection
            self._driver.verify_connectivity()
            logger.info(f"Connected to Neo4j at {self.uri}")
            return True
        except ServiceUnavailable as e:
            logger.error(f"Neo4j service unavailable: {e}")
            return False
        except AuthError as e:
            logger.error(f"Neo4j authentication failed: {e}")
            return False
        except Exception as e:
            logger.error(f"Neo4j connection error: {e}")
            return False
    
    def close(self):
        """Close the database connection"""
        if self._driver:
            self._driver.close()
            self._driver = None
            logger.info("Neo4j connection closed")
    
    @contextmanager
    def session(self) -> Session:
        """Get a database session"""
        if not self._driver:
            self.connect()
        
        session = self._driver.session(database=self.database)
        try:
            yield session
        finally:
            session.close()
    
    def execute_query(
        self, 
        query: str, 
        parameters: Dict[str, Any] = None
    ) -> List[Dict[str, Any]]:
        """Execute a Cypher query and return results"""
        with self.session() as session:
            result = session.run(query, parameters or {})
            return [dict(record) for record in result]
    
    def execute_write(
        self,
        query: str,
        parameters: Dict[str, Any] = None
    ) -> Any:
        """Execute a write transaction"""
        with self.session() as session:
            result = session.execute_write(
                lambda tx: tx.run(query, parameters or {}).consume()
            )
            return result
    
    # ==================== SCHEMA SETUP ====================
    
    def setup_schema(self):
        """Create indexes and constraints for optimal performance"""
        constraints = [
            # Unique constraints for main entities
            "CREATE CONSTRAINT disease_name IF NOT EXISTS FOR (d:Disease) REQUIRE d.name IS UNIQUE",
            "CREATE CONSTRAINT symptom_name IF NOT EXISTS FOR (s:Symptom) REQUIRE s.name IS UNIQUE",
            "CREATE CONSTRAINT drug_name IF NOT EXISTS FOR (d:Drug) REQUIRE d.name IS UNIQUE",
            "CREATE CONSTRAINT red_flag_name IF NOT EXISTS FOR (r:RedFlag) REQUIRE r.name IS UNIQUE",
            
            # Index for full-text search
            "CREATE FULLTEXT INDEX entity_search IF NOT EXISTS FOR (n:Disease|Symptom|Drug|Sign|Condition) ON EACH [n.name, n.description]",
            
            # Index for document chunks
            "CREATE INDEX chunk_doc_id IF NOT EXISTS FOR (c:Chunk) ON (c.document_id)",
            
            # Index for triage levels
            "CREATE INDEX triage_level IF NOT EXISTS FOR (t:TriageLevel) ON (t.level)",
        ]
        
        for constraint in constraints:
            try:
                self.execute_write(constraint)
                logger.info(f"Created: {constraint[:50]}...")
            except Exception as e:
                logger.debug(f"Schema element may already exist: {e}")
    
    # ==================== GRAPH INGESTION ====================
    
    def add_graph_document(
        self,
        graph_doc: GraphDocument,
        include_source: bool = True
    ):
        """
        Add a GraphDocument to Neo4j.
        
        Args:
            graph_doc: The graph document containing nodes and relationships
            include_source: Whether to create source links to document chunks
        """
        with self.session() as session:
            # Create nodes
            for node in graph_doc.nodes:
                query = f"""
                MERGE (n:{node.label} {{name: $name}})
                SET n += $properties
                RETURN n
                """
                params = {
                    "name": node.properties.get("name", node.id),
                    "properties": node.properties
                }
                session.run(query, params)
            
            # Create relationships
            for rel in graph_doc.relationships:
                # Find source and target nodes
                query = f"""
                MATCH (source {{name: $source_name}})
                MATCH (target {{name: $target_name}})
                MERGE (source)-[r:{rel.type}]->(target)
                SET r += $properties
                RETURN r
                """
                params = {
                    "source_name": rel.source_id,
                    "target_name": rel.target_id,
                    "properties": rel.properties
                }
                session.run(query, params)
            
            # Create source chunk link if specified
            if include_source and graph_doc.source:
                chunk_query = """
                MERGE (c:Chunk {id: $chunk_id})
                SET c.text = $text, c.source = $source
                WITH c
                UNWIND $node_names AS node_name
                MATCH (n {name: node_name})
                MERGE (n)-[:MENTIONED_IN]->(c)
                """
                params = {
                    "chunk_id": graph_doc.metadata.get("chunk_id", graph_doc.source[:50]),
                    "text": graph_doc.metadata.get("text", ""),
                    "source": graph_doc.source,
                    "node_names": [n.properties.get("name", n.id) for n in graph_doc.nodes]
                }
                session.run(chunk_query, params)
    
    def add_graph_documents(
        self,
        graph_docs: List[GraphDocument],
        include_source: bool = True
    ):
        """Add multiple graph documents"""
        for doc in graph_docs:
            self.add_graph_document(doc, include_source)
        logger.info(f"Added {len(graph_docs)} graph documents to Neo4j")
    
    # ==================== RAG QUERIES ====================
    
    def search_entities(
        self,
        query: str,
        labels: List[str] = None,
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """
        Full-text search for entities matching a query.
        
        Args:
            query: Search term
            labels: Optional list of labels to filter (e.g., ["Disease", "Symptom"])
            limit: Maximum results
        
        Returns:
            List of matching entities with scores
        """
        # Use full-text index if available
        cypher = """
        CALL db.index.fulltext.queryNodes('entity_search', $query)
        YIELD node, score
        WHERE score > 0.5
        RETURN node.name AS name, labels(node) AS labels, 
               node.description AS description, score
        ORDER BY score DESC
        LIMIT $limit
        """
        
        try:
            results = self.execute_query(cypher, {"query": query, "limit": limit})
            
            # Filter by labels if specified
            if labels:
                results = [r for r in results if any(l in r["labels"] for l in labels)]
            
            return results
        except Exception as e:
            logger.warning(f"Full-text search failed, using fallback: {e}")
            return self._fallback_search(query, labels, limit)
    
    def _fallback_search(
        self,
        query: str,
        labels: List[str] = None,
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """Fallback search using CONTAINS"""
        label_filter = ":Disease|Symptom|Drug|Sign|Condition"
        if labels:
            label_filter = ":" + "|".join(labels)
        
        cypher = f"""
        MATCH (n{label_filter})
        WHERE toLower(n.name) CONTAINS toLower($query)
           OR toLower(n.description) CONTAINS toLower($query)
        RETURN n.name AS name, labels(n) AS labels,
               n.description AS description, 1.0 AS score
        LIMIT $limit
        """
        return self.execute_query(cypher, {"query": query, "limit": limit})
    
    def get_symptom_diseases(
        self,
        symptom_name: str,
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """Get diseases associated with a symptom"""
        cypher = """
        MATCH (s:Symptom {name: $symptom})-[:INDICATES]->(d:Disease)
        RETURN d.name AS disease, d.description AS description,
               d.severity AS severity
        LIMIT $limit
        """
        return self.execute_query(cypher, {"symptom": symptom_name, "limit": limit})
    
    def get_disease_details(
        self,
        disease_name: str
    ) -> Dict[str, Any]:
        """Get comprehensive information about a disease"""
        cypher = """
        MATCH (d:Disease {name: $disease})
        OPTIONAL MATCH (d)<-[:INDICATES]-(s:Symptom)
        OPTIONAL MATCH (d)<-[:TREATS]-(drug:Drug)
        OPTIONAL MATCH (d)-[:RED_FLAG_FOR]->(rf:RedFlag)
        OPTIONAL MATCH (d)-[:REQUIRES_URGENCY]->(t:TriageLevel)
        RETURN d.name AS disease,
               d.description AS description,
               d.severity AS severity,
               collect(DISTINCT s.name) AS symptoms,
               collect(DISTINCT drug.name) AS treatments,
               collect(DISTINCT rf.name) AS red_flags,
               t.level AS triage_level
        """
        results = self.execute_query(cypher, {"disease": disease_name})
        return results[0] if results else {}
    
    def get_red_flags(
        self,
        symptom: str
    ) -> List[str]:
        """Get red flags associated with a symptom (returns list of flag names)"""
        cypher = """
        MATCH (s:Symptom)-[:RED_FLAG_FOR]->(rf:RedFlag)
        WHERE toLower(s.name) CONTAINS toLower($symptom)
        RETURN rf.name AS red_flag
        UNION
        MATCH (s:Symptom)-[:INDICATES]->(d:Disease)-[:HAS_RED_FLAG]->(rf:RedFlag)
        WHERE toLower(s.name) CONTAINS toLower($symptom)
        RETURN rf.name AS red_flag
        """
        results = self.execute_query(cypher, {"symptom": symptom})
        return [r["red_flag"] for r in results if r.get("red_flag")]
    
    def get_red_flags_detailed(
        self,
        symptoms: List[str]
    ) -> List[Dict[str, Any]]:
        """Get red flags associated with given symptoms (detailed)"""
        cypher = """
        UNWIND $symptoms AS symptom_name
        MATCH (s:Symptom {name: symptom_name})-[:RED_FLAG_FOR]->(rf:RedFlag)
        RETURN rf.name AS red_flag, rf.severity AS severity,
               rf.requires_immediate_action AS immediate,
               collect(s.name) AS related_symptoms
        """
        return self.execute_query(cypher, {"symptoms": symptoms})
    
    def get_related_entities(
        self,
        entity_name: str,
        limit: int = 10
    ) -> List[Dict[str, Any]]:
        """Get entities related to the given entity"""
        cypher = """
        MATCH (n {name: $name})-[r]-(related)
        RETURN related.name AS name, 
               labels(related) AS labels,
               type(r) AS relationship,
               related.description AS description,
               properties(related) AS properties
        LIMIT $limit
        """
        return self.execute_query(cypher, {"name": entity_name, "limit": limit})
    
    def get_drug_interaction(
        self,
        drug1: str,
        drug2: str
    ) -> Optional[Dict[str, Any]]:
        """Get interaction between two drugs"""
        cypher = """
        MATCH (d1:Drug)-[r:INTERACTS_WITH]-(d2:Drug)
        WHERE toLower(d1.name) CONTAINS toLower($drug1)
          AND toLower(d2.name) CONTAINS toLower($drug2)
        RETURN d1.name AS drug1, d2.name AS drug2,
               r.severity AS severity, r.description AS description,
               r.contraindicated AS contraindicated
        LIMIT 1
        """
        results = self.execute_query(cypher, {"drug1": drug1, "drug2": drug2})
        return results[0] if results else None
    
    def get_rag_context(
        self,
        query: str,
        max_hops: int = 2,
        limit: int = 20
    ) -> str:
        """
        Get RAG context from the knowledge graph for a query.
        
        This performs a graph traversal to find relevant connected information
        and formats it as context for the LLM.
        
        Args:
            query: The user query (symptoms/condition description)
            max_hops: Maximum graph traversal depth
            limit: Maximum context items
        
        Returns:
            Formatted context string for RAG
        """
        # Step 1: Find matching entities
        matches = self.search_entities(query, limit=5)
        
        if not matches:
            return ""
        
        # Step 2: Expand graph around matches
        context_parts = []
        
        for match in matches:
            entity_name = match["name"]
            labels = match["labels"]
            
            # Get connected information based on entity type
            if "Symptom" in labels:
                # Get diseases this symptom indicates
                diseases = self.get_symptom_diseases(entity_name, limit=5)
                if diseases:
                    disease_list = ", ".join([d["disease"] for d in diseases])
                    context_parts.append(
                        f"Symptom '{entity_name}' may indicate: {disease_list}"
                    )
                
                # Get red flags
                red_flags = self.get_red_flags([entity_name])
                if red_flags:
                    rf_list = ", ".join([r["red_flag"] for r in red_flags])
                    context_parts.append(
                        f"Red flags for '{entity_name}': {rf_list}"
                    )
            
            elif "Disease" in labels:
                details = self.get_disease_details(entity_name)
                if details:
                    context_parts.append(
                        f"Disease: {entity_name}\n"
                        f"  Symptoms: {', '.join(details.get('symptoms', []))}\n"
                        f"  Treatments: {', '.join(details.get('treatments', []))}\n"
                        f"  Red flags: {', '.join(details.get('red_flags', []))}\n"
                        f"  Triage level: {details.get('triage_level', 'Unknown')}"
                    )
        
        # Step 3: Get source chunks for additional context
        chunk_cypher = """
        CALL db.index.fulltext.queryNodes('entity_search', $query)
        YIELD node
        MATCH (node)-[:MENTIONED_IN]->(c:Chunk)
        RETURN c.text AS text, c.source AS source
        LIMIT 5
        """
        
        try:
            chunks = self.execute_query(chunk_cypher, {"query": query})
            for chunk in chunks:
                if chunk.get("text"):
                    context_parts.append(f"From {chunk.get('source', 'knowledge base')}:\n{chunk['text']}")
        except Exception:
            pass  # Full-text index may not exist
        
        return "\n\n".join(context_parts[:limit])
    
    # ==================== STATISTICS ====================
    
    def get_stats(self) -> Dict[str, Any]:
        """Get database statistics"""
        stats = {}
        
        # Node counts by label
        node_query = """
        CALL db.labels() YIELD label
        CALL apoc.cypher.run('MATCH (n:`' + label + '`) RETURN count(n) as count', {})
        YIELD value
        RETURN label, value.count AS count
        """
        
        try:
            results = self.execute_query(node_query)
            stats["nodes"] = {r["label"]: r["count"] for r in results}
        except Exception:
            # APOC not available, use simple count
            simple_query = "MATCH (n) RETURN labels(n)[0] AS label, count(*) AS count"
            results = self.execute_query(simple_query)
            stats["nodes"] = {r["label"]: r["count"] for r in results}
        
        # Relationship counts
        rel_query = """
        MATCH ()-[r]->()
        RETURN type(r) AS type, count(*) AS count
        """
        results = self.execute_query(rel_query)
        stats["relationships"] = {r["type"]: r["count"] for r in results}
        
        # Total counts
        stats["total_nodes"] = sum(stats.get("nodes", {}).values())
        stats["total_relationships"] = sum(stats.get("relationships", {}).values())
        
        return stats
    
    def clear_database(self, confirm: bool = False):
        """Clear all data from the database (use with caution!)"""
        if not confirm:
            raise ValueError("Must set confirm=True to clear database")
        
        self.execute_write("MATCH (n) DETACH DELETE n")
        logger.warning("Database cleared!")
