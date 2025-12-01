"""
Medical Graph Extractor for ClinixAI

Uses LLM to extract medical entities and relationships from text chunks.
Supports multiple LLM backends: Ollama, OpenAI, Anthropic.
"""

import os
import json
import logging
from typing import List, Dict, Any, Optional, Tuple
from dataclasses import dataclass

from .medical_schema import MedicalSchema, MEDICAL_NODE_TYPES, MEDICAL_RELATIONSHIPS
from .neo4j_client import GraphNode, GraphRelationship, GraphDocument

logger = logging.getLogger(__name__)

# Extraction prompt template
EXTRACTION_PROMPT = """You are a medical knowledge extraction system. Your task is to extract medical entities and relationships from the given text.

## Allowed Entity Types:
{node_types}

## Allowed Relationship Types:
{relationship_types}

## Instructions:
1. Read the text carefully
2. Identify medical entities (diseases, symptoms, drugs, procedures, etc.)
3. Identify relationships between entities
4. Return a JSON object with "entities" and "relationships" arrays

## Output Format:
{{
  "entities": [
    {{"id": "unique_id", "type": "EntityType", "name": "Entity Name", "properties": {{"description": "...", ...}}}}
  ],
  "relationships": [
    {{"source": "source_id", "target": "target_id", "type": "RELATIONSHIP_TYPE", "properties": {{}}}}
  ]
}}

## Text to analyze:
{text}

## Extracted Knowledge Graph (JSON only, no explanation):"""


class MedicalGraphExtractor:
    """
    Extracts medical knowledge graphs from text using LLM.
    
    Usage:
        extractor = MedicalGraphExtractor(
            llm_backend="ollama",
            ollama_base_url="http://localhost:11434",
            model="llama3.1:8b"
        )
        
        graph_doc = extractor.extract(text_chunk)
    """
    
    def __init__(
        self,
        llm_backend: str = "ollama",
        ollama_base_url: str = None,
        openai_api_key: str = None,
        anthropic_api_key: str = None,
        model: str = None,
        schema: MedicalSchema = None,
        temperature: float = 0.0
    ):
        self.llm_backend = llm_backend
        self.ollama_base_url = ollama_base_url or os.getenv("OLLAMA_BASE_URL", "http://localhost:11434")
        self.openai_api_key = openai_api_key or os.getenv("OPENAI_API_KEY")
        self.anthropic_api_key = anthropic_api_key or os.getenv("ANTHROPIC_API_KEY")
        self.model = model
        self.schema = schema or MedicalSchema()
        self.temperature = temperature
        
        # Set default model based on backend
        if not self.model:
            if llm_backend == "ollama":
                self.model = os.getenv("OLLAMA_MODEL", "llama3.1:8b")
            elif llm_backend == "openai":
                self.model = "gpt-4o-mini"
            elif llm_backend == "anthropic":
                self.model = "claude-3-haiku-20240307"
        
        self._client = None
        self._setup_client()
    
    def _setup_client(self):
        """Initialize the LLM client"""
        if self.llm_backend == "ollama":
            try:
                import requests
                self._client = requests.Session()
                logger.info(f"Using Ollama at {self.ollama_base_url} with model {self.model}")
            except ImportError:
                raise ImportError("requests package required for Ollama backend")
        
        elif self.llm_backend == "openai":
            try:
                from openai import OpenAI
                self._client = OpenAI(api_key=self.openai_api_key)
                logger.info(f"Using OpenAI with model {self.model}")
            except ImportError:
                raise ImportError("openai package required. Run: pip install openai")
        
        elif self.llm_backend == "anthropic":
            try:
                import anthropic
                self._client = anthropic.Anthropic(api_key=self.anthropic_api_key)
                logger.info(f"Using Anthropic with model {self.model}")
            except ImportError:
                raise ImportError("anthropic package required. Run: pip install anthropic")
        
        elif self.llm_backend == "openrouter":
            try:
                from openai import OpenAI
                self._client = OpenAI(
                    api_key=os.getenv("OPENROUTER_API_KEY"),
                    base_url="https://openrouter.ai/api/v1"
                )
                if not self.model:
                    self.model = "anthropic/claude-3.5-sonnet"  # Default to Claude
                logger.info(f"Using OpenRouter with model {self.model}")
            except ImportError:
                raise ImportError("openai package required for OpenRouter. Run: pip install openai")
    
    def _call_llm(self, prompt: str) -> str:
        """Call the LLM and return response text"""
        try:
            if self.llm_backend == "ollama":
                response = self._client.post(
                    f"{self.ollama_base_url}/api/generate",
                    json={
                        "model": self.model,
                        "prompt": prompt,
                        "stream": False,
                        "options": {
                            "temperature": self.temperature,
                            "num_predict": 2048
                        }
                    },
                    timeout=120
                )
                response.raise_for_status()
                return response.json().get("response", "")
            
            elif self.llm_backend in ["openai", "openrouter"]:
                response = self._client.chat.completions.create(
                    model=self.model,
                    messages=[{"role": "user", "content": prompt}],
                    temperature=self.temperature,
                    max_tokens=2048
                )
                return response.choices[0].message.content
            
            elif self.llm_backend == "anthropic":
                response = self._client.messages.create(
                    model=self.model,
                    max_tokens=2048,
                    temperature=self.temperature,
                    messages=[{"role": "user", "content": prompt}]
                )
                return response.content[0].text
            
        except Exception as e:
            logger.error(f"LLM call failed: {e}")
            raise
    
    def _build_prompt(self, text: str) -> str:
        """Build the extraction prompt"""
        return EXTRACTION_PROMPT.format(
            node_types=", ".join(self.schema.allowed_nodes),
            relationship_types=", ".join(self.schema.allowed_relationships),
            text=text
        )
    
    def _parse_response(self, response: str, source: str = None) -> GraphDocument:
        """Parse LLM response into GraphDocument"""
        # Try to extract JSON from response
        json_str = response.strip()
        
        # Handle markdown code blocks
        if "```json" in json_str:
            start = json_str.find("```json") + 7
            end = json_str.find("```", start)
            json_str = json_str[start:end].strip()
        elif "```" in json_str:
            start = json_str.find("```") + 3
            end = json_str.find("```", start)
            json_str = json_str[start:end].strip()
        
        # Find JSON object
        if "{" in json_str:
            start = json_str.find("{")
            end = json_str.rfind("}") + 1
            json_str = json_str[start:end]
        
        try:
            data = json.loads(json_str)
        except json.JSONDecodeError as e:
            logger.warning(f"Failed to parse JSON response: {e}")
            return GraphDocument(nodes=[], relationships=[], source=source)
        
        # Extract nodes
        nodes = []
        for entity in data.get("entities", []):
            node = GraphNode(
                id=entity.get("id", entity.get("name", "unknown")),
                label=entity.get("type", "Entity"),
                properties={
                    "name": entity.get("name", entity.get("id", "unknown")),
                    **entity.get("properties", {})
                }
            )
            
            # Validate against schema
            if self.schema.strict_mode and node.label not in self.schema.allowed_nodes:
                logger.debug(f"Skipping node with invalid type: {node.label}")
                continue
            
            nodes.append(node)
        
        # Extract relationships
        relationships = []
        for rel in data.get("relationships", []):
            relationship = GraphRelationship(
                source_id=rel.get("source", ""),
                target_id=rel.get("target", ""),
                type=rel.get("type", "RELATED_TO"),
                properties=rel.get("properties", {})
            )
            
            # Validate against schema
            if self.schema.strict_mode and relationship.type not in self.schema.allowed_relationships:
                logger.debug(f"Skipping relationship with invalid type: {relationship.type}")
                continue
            
            relationships.append(relationship)
        
        return GraphDocument(
            nodes=nodes,
            relationships=relationships,
            source=source,
            metadata={"raw_response": response}
        )
    
    def extract(
        self,
        text: str,
        source: str = None,
        metadata: Dict[str, Any] = None
    ) -> GraphDocument:
        """
        Extract medical entities and relationships from text.
        
        Args:
            text: The text to extract from
            source: Source identifier (e.g., document name)
            metadata: Additional metadata
        
        Returns:
            GraphDocument containing extracted nodes and relationships
        """
        if not text or len(text.strip()) < 50:
            logger.debug("Text too short for extraction")
            return GraphDocument(nodes=[], relationships=[], source=source)
        
        prompt = self._build_prompt(text)
        response = self._call_llm(prompt)
        
        graph_doc = self._parse_response(response, source)
        
        if metadata:
            graph_doc.metadata = {**(graph_doc.metadata or {}), **metadata}
        
        logger.info(f"Extracted {len(graph_doc.nodes)} nodes, {len(graph_doc.relationships)} relationships")
        return graph_doc
    
    def extract_batch(
        self,
        texts: List[str],
        sources: List[str] = None
    ) -> List[GraphDocument]:
        """Extract from multiple texts"""
        if sources is None:
            sources = [f"chunk_{i}" for i in range(len(texts))]
        
        results = []
        for text, source in zip(texts, sources):
            try:
                graph_doc = self.extract(text, source)
                results.append(graph_doc)
            except Exception as e:
                logger.error(f"Extraction failed for {source}: {e}")
                results.append(GraphDocument(nodes=[], relationships=[], source=source))
        
        return results


class LangChainGraphExtractor(MedicalGraphExtractor):
    """
    Graph extractor using LangChain's LLMGraphTransformer.
    Provides better structured output with function calling models.
    """
    
    def __init__(self, **kwargs):
        super().__init__(**kwargs)
        self._transformer = None
        self._setup_transformer()
    
    def _setup_transformer(self):
        """Setup LangChain graph transformer"""
        try:
            from langchain_experimental.graph_transformers import LLMGraphTransformer
            from langchain_openai import ChatOpenAI
            
            if self.llm_backend == "ollama":
                llm = ChatOpenAI(
                    base_url=f"{self.ollama_base_url}/v1",
                    api_key="ollama",
                    model=self.model,
                    temperature=self.temperature
                )
            elif self.llm_backend == "openrouter":
                llm = ChatOpenAI(
                    base_url="https://openrouter.ai/api/v1",
                    api_key=os.getenv("OPENROUTER_API_KEY"),
                    model=self.model,
                    temperature=self.temperature
                )
            else:
                llm = ChatOpenAI(
                    api_key=self.openai_api_key,
                    model=self.model,
                    temperature=self.temperature
                )
            
            self._transformer = LLMGraphTransformer(
                llm=llm,
                allowed_nodes=self.schema.allowed_nodes,
                allowed_relationships=self.schema.allowed_relationships,
                strict_mode=self.schema.strict_mode
            )
            
            logger.info("LangChain LLMGraphTransformer initialized")
            
        except ImportError as e:
            logger.warning(f"LangChain not available: {e}. Using basic extractor.")
            self._transformer = None
    
    def extract(
        self,
        text: str,
        source: str = None,
        metadata: Dict[str, Any] = None
    ) -> GraphDocument:
        """Extract using LangChain if available, else fallback to basic"""
        if self._transformer is None:
            return super().extract(text, source, metadata)
        
        try:
            from langchain_core.documents import Document
            
            doc = Document(page_content=text, metadata={"source": source or "unknown"})
            graph_docs = self._transformer.convert_to_graph_documents([doc])
            
            if not graph_docs:
                return GraphDocument(nodes=[], relationships=[], source=source)
            
            # Convert LangChain GraphDocument to our format
            lc_doc = graph_docs[0]
            
            nodes = [
                GraphNode(
                    id=node.id,
                    label=node.type,
                    properties={"name": node.id, **node.properties}
                )
                for node in lc_doc.nodes
            ]
            
            relationships = [
                GraphRelationship(
                    source_id=rel.source.id,
                    target_id=rel.target.id,
                    type=rel.type,
                    properties=rel.properties
                )
                for rel in lc_doc.relationships
            ]
            
            return GraphDocument(
                nodes=nodes,
                relationships=relationships,
                source=source,
                metadata=metadata
            )
            
        except Exception as e:
            logger.warning(f"LangChain extraction failed: {e}. Using basic extractor.")
            return super().extract(text, source, metadata)
