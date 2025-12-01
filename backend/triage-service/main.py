"""
ClinixAI Triage Service
LangGraph-powered AI analysis for medical triage cases
Hybrid inference: Local LLM (Cactus) + Cloud AI (HuggingFace, OpenAI, Anthropic)
Neo4j GraphRAG for medical knowledge retrieval
"""

import os
import json
from datetime import datetime
from typing import Optional, List, Dict, Any, TypedDict, Annotated
from contextlib import asynccontextmanager
import operator

from fastapi import FastAPI, HTTPException, BackgroundTasks
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import httpx

# LangGraph imports
from langgraph.graph import StateGraph, END

# GraphRAG imports
from graphrag import GraphRAGService, Neo4jClient, MedicalSchema

# ==================== LANGGRAPH STATE ====================

class TriageState(TypedDict):
    """State for the triage LangGraph workflow"""
    session_id: str
    symptoms: List[Dict[str, Any]]
    vital_signs: Optional[Dict[str, Any]]
    patient_info: Dict[str, Any]
    
    # Analysis results
    symptom_features: Dict[str, Any]
    complexity_score: float
    urgency_level: str
    confidence_score: float
    primary_assessment: str
    recommended_action: str
    differential_diagnoses: List[Dict[str, Any]]
    
    # Inference tracking
    inference_provider: str
    inference_time_ms: int
    escalated_to_cloud: bool
    error: Optional[str]
    
    # Messages for chain of thought
    messages: Annotated[List[str], operator.add]

# ==================== LANGGRAPH NODES ====================

def symptom_analyzer_node(state: TriageState) -> TriageState:
    """Analyze symptoms and extract features"""
    symptoms = state.get("symptoms", [])
    
    # Extract keywords and severity
    symptom_text = " ".join([s.get("description", "").lower() for s in symptoms])
    max_severity = max([s.get("severity", 5) for s in symptoms]) if symptoms else 5
    
    # Critical symptom detection
    critical_keywords = ["chest pain", "difficulty breathing", "unconscious", 
                        "severe bleeding", "stroke", "heart attack", "seizure"]
    urgent_keywords = ["high fever", "severe pain", "vomiting blood", 
                      "head injury", "broken bone", "allergic reaction"]
    
    detected_critical = [kw for kw in critical_keywords if kw in symptom_text]
    detected_urgent = [kw for kw in urgent_keywords if kw in symptom_text]
    
    # Calculate complexity score
    complexity_score = 0.3  # Base complexity
    complexity_score += len(symptoms) * 0.1
    complexity_score += (max_severity / 10) * 0.3
    if detected_critical:
        complexity_score += 0.3
    if detected_urgent:
        complexity_score += 0.2
    complexity_score = min(complexity_score, 1.0)
    
    return {
        **state,
        "symptom_features": {
            "symptom_text": symptom_text,
            "max_severity": max_severity,
            "critical_keywords": detected_critical,
            "urgent_keywords": detected_urgent,
            "symptom_count": len(symptoms),
        },
        "complexity_score": complexity_score,
        "messages": [f"[SymptomAnalyzer] Complexity: {complexity_score:.2f}, Critical: {detected_critical}"],
    }

async def huggingface_node(state: TriageState) -> TriageState:
    """Process with HuggingFace Inference API"""
    api_key = os.getenv("HUGGINGFACE_API_KEY", "")
    if not api_key:
        return {
            **state,
            "error": "HuggingFace API key not configured",
            "messages": ["[HuggingFace] No API key, skipping"],
        }
    
    model = os.getenv("HUGGINGFACE_MODEL", "mistralai/Mistral-7B-Instruct-v0.2")
    features = state.get("symptom_features", {})
    
    prompt = f"""<s>[INST] You are a medical triage assistant. Analyze these symptoms and provide assessment.

Symptoms: {features.get('symptom_text', 'No symptoms provided')}
Severity: {features.get('max_severity', 5)}/10

Respond in JSON format:
{{"urgency": "critical|urgent|standard|non-urgent", "confidence": 0.0-1.0, "assessment": "...", "action": "...", "conditions": [{{"name": "...", "probability": 0.0-1.0}}]}}
[/INST]</s>"""

    try:
        start = datetime.utcnow()
        async with httpx.AsyncClient() as client:
            response = await client.post(
                f"https://api-inference.huggingface.co/models/{model}",
                headers={"Authorization": f"Bearer {api_key}"},
                json={"inputs": prompt, "parameters": {"max_new_tokens": 500, "temperature": 0.3}},
                timeout=60.0,
            )
            
            if response.status_code == 200:
                data = response.json()
                text = data[0].get("generated_text", "") if isinstance(data, list) else str(data)
                
                # Extract JSON from response
                import re
                json_match = re.search(r'\{[^{}]*\}', text)
                if json_match:
                    result = json.loads(json_match.group())
                    inference_time = int((datetime.utcnow() - start).total_seconds() * 1000)
                    
                    return {
                        **state,
                        "urgency_level": result.get("urgency", "standard"),
                        "confidence_score": result.get("confidence", 0.7),
                        "primary_assessment": result.get("assessment", "Assessment via HuggingFace"),
                        "recommended_action": result.get("action", "Consult healthcare professional"),
                        "differential_diagnoses": result.get("conditions", []),
                        "inference_provider": f"huggingface/{model}",
                        "inference_time_ms": inference_time,
                        "escalated_to_cloud": True,
                        "error": None,
                        "messages": [f"[HuggingFace] Success in {inference_time}ms"],
                    }
    except Exception as e:
        pass
    
    return {
        **state,
        "error": "HuggingFace inference failed",
        "messages": ["[HuggingFace] Failed, will try fallback"],
    }

async def openai_node(state: TriageState) -> TriageState:
    """Process with OpenAI GPT-4"""
    api_key = os.getenv("OPENAI_API_KEY", "")
    if not api_key or api_key == "your-openai-key":
        return {
            **state,
            "error": "OpenAI API key not configured",
            "messages": ["[OpenAI] No API key, skipping"],
        }
    
    features = state.get("symptom_features", {})
    prompt = f"""Analyze these symptoms for medical triage:
Symptoms: {features.get('symptom_text', '')}
Severity: {features.get('max_severity', 5)}/10

Respond ONLY in JSON: {{"urgency": "critical|urgent|standard|non-urgent", "confidence": 0.0-1.0, "assessment": "...", "action": "...", "conditions": [{{"name": "...", "probability": 0.0-1.0}}]}}"""

    try:
        start = datetime.utcnow()
        async with httpx.AsyncClient() as client:
            response = await client.post(
                "https://api.openai.com/v1/chat/completions",
                headers={"Authorization": f"Bearer {api_key}", "Content-Type": "application/json"},
                json={
                    "model": "gpt-4o",
                    "messages": [
                        {"role": "system", "content": "You are a medical triage AI. Respond only in JSON."},
                        {"role": "user", "content": prompt}
                    ],
                    "temperature": 0.3,
                    "max_tokens": 500,
                },
                timeout=30.0,
            )
            
            if response.status_code == 200:
                data = response.json()
                content = data["choices"][0]["message"]["content"]
                result = json.loads(content)
                inference_time = int((datetime.utcnow() - start).total_seconds() * 1000)
                
                return {
                    **state,
                    "urgency_level": result.get("urgency", "standard"),
                    "confidence_score": result.get("confidence", 0.8),
                    "primary_assessment": result.get("assessment", "Assessment via OpenAI"),
                    "recommended_action": result.get("action", "Consult healthcare professional"),
                    "differential_diagnoses": result.get("conditions", []),
                    "inference_provider": "openai/gpt-4o",
                    "inference_time_ms": inference_time,
                    "escalated_to_cloud": True,
                    "error": None,
                    "messages": [f"[OpenAI] Success in {inference_time}ms"],
                }
    except Exception as e:
        pass
    
    return {
        **state,
        "error": "OpenAI inference failed",
        "messages": ["[OpenAI] Failed, will try fallback"],
    }

async def anthropic_node(state: TriageState) -> TriageState:
    """Process with Anthropic Claude"""
    api_key = os.getenv("ANTHROPIC_API_KEY", "")
    if not api_key or api_key == "your-anthropic-key":
        return {
            **state,
            "error": "Anthropic API key not configured", 
            "messages": ["[Anthropic] No API key, skipping"],
        }
    
    features = state.get("symptom_features", {})
    prompt = f"""Analyze these symptoms for medical triage:
Symptoms: {features.get('symptom_text', '')}
Severity: {features.get('max_severity', 5)}/10

Respond ONLY in JSON: {{"urgency": "critical|urgent|standard|non-urgent", "confidence": 0.0-1.0, "assessment": "...", "action": "...", "conditions": [{{"name": "...", "probability": 0.0-1.0}}]}}"""

    try:
        start = datetime.utcnow()
        async with httpx.AsyncClient() as client:
            response = await client.post(
                "https://api.anthropic.com/v1/messages",
                headers={
                    "x-api-key": api_key,
                    "Content-Type": "application/json",
                    "anthropic-version": "2023-06-01",
                },
                json={
                    "model": "claude-3-sonnet-20240229",
                    "max_tokens": 500,
                    "messages": [{"role": "user", "content": prompt}],
                    "system": "You are a medical triage AI. Respond only in valid JSON format.",
                },
                timeout=30.0,
            )
            
            if response.status_code == 200:
                data = response.json()
                content = data["content"][0]["text"]
                result = json.loads(content)
                inference_time = int((datetime.utcnow() - start).total_seconds() * 1000)
                
                return {
                    **state,
                    "urgency_level": result.get("urgency", "standard"),
                    "confidence_score": result.get("confidence", 0.85),
                    "primary_assessment": result.get("assessment", "Assessment via Anthropic"),
                    "recommended_action": result.get("action", "Consult healthcare professional"),
                    "differential_diagnoses": result.get("conditions", []),
                    "inference_provider": "anthropic/claude-3-sonnet",
                    "inference_time_ms": inference_time,
                    "escalated_to_cloud": True,
                    "error": None,
                    "messages": [f"[Anthropic] Success in {inference_time}ms"],
                }
    except Exception as e:
        pass
    
    return {
        **state,
        "error": "Anthropic inference failed",
        "messages": ["[Anthropic] Failed"],
    }

def fallback_node(state: TriageState) -> TriageState:
    """Rule-based fallback when all AI providers fail"""
    features = state.get("symptom_features", {})
    
    # Determine urgency based on keywords
    if features.get("critical_keywords"):
        urgency = "critical"
        confidence = 0.85
        assessment = "Critical symptoms detected. Immediate medical attention required."
        action = "Call emergency services or go to nearest emergency room immediately."
    elif features.get("urgent_keywords") or features.get("max_severity", 5) >= 8:
        urgency = "urgent"
        confidence = 0.75
        assessment = "Urgent symptoms detected. Prompt medical attention recommended."
        action = "Visit a healthcare facility within the next few hours."
    else:
        urgency = "standard"
        confidence = 0.6
        assessment = "Standard symptoms requiring evaluation."
        action = "Schedule an appointment with your healthcare provider."
    
    return {
        **state,
        "urgency_level": urgency,
        "confidence_score": confidence,
        "primary_assessment": assessment,
        "recommended_action": action,
        "differential_diagnoses": [{"name": "Requires clinical evaluation", "probability": 1.0}],
        "inference_provider": "rule-based-fallback",
        "inference_time_ms": 1,
        "escalated_to_cloud": False,
        "error": None,
        "messages": [f"[Fallback] Using rule-based analysis: {urgency}"],
    }

# ==================== LANGGRAPH ROUTING ====================

def should_use_cloud(state: TriageState) -> str:
    """Route based on complexity score"""
    complexity = state.get("complexity_score", 0.5)
    threshold = float(os.getenv("COMPLEXITY_THRESHOLD", "0.7"))
    
    if complexity >= threshold:
        return "cloud"
    return "local_fallback"

def check_huggingface_result(state: TriageState) -> str:
    """Check if HuggingFace succeeded"""
    if state.get("error") is None and state.get("inference_provider", "").startswith("huggingface"):
        return "done"
    return "try_openai"

def check_openai_result(state: TriageState) -> str:
    """Check if OpenAI succeeded"""
    if state.get("error") is None and state.get("inference_provider", "").startswith("openai"):
        return "done"
    return "try_anthropic"

def check_anthropic_result(state: TriageState) -> str:
    """Check if Anthropic succeeded"""
    if state.get("error") is None and state.get("inference_provider", "").startswith("anthropic"):
        return "done"
    return "fallback"

# ==================== BUILD LANGGRAPH ====================

def build_triage_graph() -> StateGraph:
    """Build the LangGraph workflow for triage"""
    workflow = StateGraph(TriageState)
    
    # Add nodes
    workflow.add_node("symptom_analyzer", symptom_analyzer_node)
    workflow.add_node("huggingface", huggingface_node)
    workflow.add_node("openai", openai_node)
    workflow.add_node("anthropic", anthropic_node)
    workflow.add_node("fallback", fallback_node)
    
    # Set entry point
    workflow.set_entry_point("symptom_analyzer")
    
    # Add conditional routing after symptom analysis
    workflow.add_conditional_edges(
        "symptom_analyzer",
        should_use_cloud,
        {
            "cloud": "huggingface",
            "local_fallback": "fallback",
        }
    )
    
    # Cloud provider chain with fallbacks
    workflow.add_conditional_edges(
        "huggingface",
        check_huggingface_result,
        {"done": END, "try_openai": "openai"}
    )
    
    workflow.add_conditional_edges(
        "openai", 
        check_openai_result,
        {"done": END, "try_anthropic": "anthropic"}
    )
    
    workflow.add_conditional_edges(
        "anthropic",
        check_anthropic_result,
        {"done": END, "fallback": "fallback"}
    )
    
    # Fallback always ends
    workflow.add_edge("fallback", END)
    
    return workflow.compile()

# Create global graph instance
triage_graph = build_triage_graph()

# ==================== PYDANTIC MODELS ====================

class Symptom(BaseModel):
    description: str
    severity: Optional[int] = Field(None, ge=1, le=10)
    duration_hours: Optional[int] = None
    body_location: Optional[str] = None

class VitalSigns(BaseModel):
    temperature: Optional[float] = None
    heart_rate: Optional[int] = None
    blood_pressure: Optional[str] = None
    oxygen_saturation: Optional[int] = None

class TriageRequest(BaseModel):
    session_id: str
    symptoms: List[Symptom]
    vital_signs: Optional[VitalSigns] = None
    patient_age: Optional[int] = None
    patient_gender: Optional[str] = None
    medical_history: Optional[List[str]] = None

class DifferentialDiagnosis(BaseModel):
    condition: str
    probability: float
    icd_code: Optional[str] = None

class TriageResponse(BaseModel):
    session_id: str
    urgency_level: str
    confidence_score: float
    primary_assessment: str
    recommended_action: str
    differential_diagnoses: List[DifferentialDiagnosis]
    escalated_to_cloud: bool = True
    ai_model: str
    inference_time_ms: int
    complexity_score: Optional[float] = None
    workflow_messages: Optional[List[str]] = None
    disclaimer: str = "This is an AI-assisted assessment. Always consult a healthcare professional."

# ==================== APP SETUP ====================

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("🚀 ClinixAI Triage Service Starting (LangGraph-powered)...")
    print(f"📊 Complexity threshold: {os.getenv('COMPLEXITY_THRESHOLD', '0.7')}")
    print(f"🤖 HuggingFace model: {os.getenv('HUGGINGFACE_MODEL', 'mistralai/Mistral-7B-Instruct-v0.2')}")
    yield
    # Shutdown
    print("👋 ClinixAI Triage Service Shutting Down...")

app = FastAPI(
    title="ClinixAI Triage Service",
    description="LangGraph-powered AI analysis for medical triage",
    version="2.0.0",
    lifespan=lifespan,
)

# CORS
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# ==================== ROUTES ====================

@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "service": "clinixai-triage-service",
        "version": "2.0.0",
        "engine": "langgraph",
        "timestamp": datetime.utcnow().isoformat(),
    }

@app.post("/analyze", response_model=TriageResponse)
async def analyze_triage(request: TriageRequest):
    """Perform LangGraph-powered AI triage analysis"""
    
    # Prepare initial state
    initial_state: TriageState = {
        "session_id": request.session_id,
        "symptoms": [s.model_dump() for s in request.symptoms],
        "vital_signs": request.vital_signs.model_dump() if request.vital_signs else None,
        "patient_info": {
            "age": request.patient_age,
            "gender": request.patient_gender,
            "medical_history": request.medical_history or [],
        },
        "symptom_features": {},
        "complexity_score": 0.0,
        "urgency_level": "standard",
        "confidence_score": 0.0,
        "primary_assessment": "",
        "recommended_action": "",
        "differential_diagnoses": [],
        "inference_provider": "",
        "inference_time_ms": 0,
        "escalated_to_cloud": False,
        "error": None,
        "messages": [],
    }
    
    # Run the LangGraph workflow
    try:
        result = await triage_graph.ainvoke(initial_state)
    except Exception as e:
        # If LangGraph fails entirely, use simple fallback
        result = fallback_node(initial_state)
        result["error"] = str(e)
    
    # Parse differential diagnoses
    raw_diagnoses = result.get("differential_diagnoses", [])
    differential_diagnoses = []
    for d in raw_diagnoses:
        if isinstance(d, dict):
            differential_diagnoses.append(DifferentialDiagnosis(
                condition=d.get("name", d.get("condition", "Unknown")),
                probability=d.get("probability", 0.5),
                icd_code=d.get("icd_code"),
            ))
        elif isinstance(d, str):
            differential_diagnoses.append(DifferentialDiagnosis(
                condition=d,
                probability=0.5,
            ))
    
    return TriageResponse(
        session_id=request.session_id,
        urgency_level=result.get("urgency_level", "standard"),
        confidence_score=result.get("confidence_score", 0.5),
        primary_assessment=result.get("primary_assessment", "Assessment unavailable"),
        recommended_action=result.get("recommended_action", "Consult a healthcare professional"),
        differential_diagnoses=differential_diagnoses,
        escalated_to_cloud=result.get("escalated_to_cloud", False),
        ai_model=result.get("inference_provider", "unknown"),
        inference_time_ms=result.get("inference_time_ms", 0),
        complexity_score=result.get("complexity_score"),
        workflow_messages=result.get("messages"),
    )

@app.get("/graph")
async def get_graph_visualization():
    """Get LangGraph workflow visualization (Mermaid format)"""
    try:
        mermaid = triage_graph.get_graph().draw_mermaid()
        return {
            "format": "mermaid",
            "graph": mermaid,
        }
    except Exception as e:
        return {
            "format": "text",
            "graph": """
graph TD
    A[symptom_analyzer] --> B{complexity >= 0.7?}
    B -->|Yes| C[huggingface]
    B -->|No| F[fallback]
    C -->|Success| END
    C -->|Fail| D[openai]
    D -->|Success| END  
    D -->|Fail| E[anthropic]
    E -->|Success| END
    E -->|Fail| F[fallback]
    F --> END
""",
            "error": str(e),
        }

@app.get("/models")
async def get_available_models():
    """Get status of available AI models"""
    return {
        "models": {
            "huggingface": {
                "model": os.getenv("HUGGINGFACE_MODEL", "mistralai/Mistral-7B-Instruct-v0.2"),
                "configured": bool(os.getenv("HUGGINGFACE_API_KEY")),
            },
            "openai": {
                "model": "gpt-4o",
                "configured": bool(os.getenv("OPENAI_API_KEY")) and os.getenv("OPENAI_API_KEY") != "your-openai-key",
            },
            "anthropic": {
                "model": "claude-3-sonnet-20240229",
                "configured": bool(os.getenv("ANTHROPIC_API_KEY")) and os.getenv("ANTHROPIC_API_KEY") != "your-anthropic-key",
            },
            "fallback": {
                "model": "rule-based",
                "configured": True,
            },
        },
        "complexity_threshold": float(os.getenv("COMPLEXITY_THRESHOLD", "0.7")),
    }

# ==================== GRAPHRAG ENDPOINTS ====================

# GraphRAG Pydantic Models
class GraphRAGQueryRequest(BaseModel):
    query: str
    max_results: int = 10
    include_relationships: bool = True
    include_entities: bool = True

class GraphRAGQueryResponse(BaseModel):
    context: str
    sources: List[str]
    entities: List[Dict[str, Any]]
    relationships: List[Dict[str, Any]]
    confidence: float
    success: bool
    error: Optional[str] = None

class EntitySearchRequest(BaseModel):
    query: str
    entity_type: Optional[str] = None
    limit: int = 20

class RedFlagsRequest(BaseModel):
    symptoms: List[str]

class ConditionsRequest(BaseModel):
    symptoms: List[str]

class DrugInteractionsRequest(BaseModel):
    drugs: List[str]

# Global GraphRAG service
graph_rag_service: Optional[GraphRAGService] = None

def get_graph_rag_service() -> GraphRAGService:
    """Get or create GraphRAG service instance"""
    global graph_rag_service
    if graph_rag_service is None:
        neo4j_uri = os.getenv("NEO4J_URI", "bolt://localhost:7687")
        neo4j_user = os.getenv("NEO4J_USER", "neo4j")
        neo4j_password = os.getenv("NEO4J_PASSWORD", "clinixai_neo4j_password")
        
        graph_rag_service = GraphRAGService(
            neo4j_uri=neo4j_uri,
            neo4j_user=neo4j_user,
            neo4j_password=neo4j_password,
        )
    return graph_rag_service

@app.post("/graphrag/query", response_model=GraphRAGQueryResponse)
async def graphrag_query(request: GraphRAGQueryRequest):
    """Query the medical knowledge graph for RAG context"""
    try:
        service = get_graph_rag_service()
        
        # Get RAG context from Neo4j
        result = await service.get_rag_context(
            query=request.query,
            max_results=request.max_results,
        )
        
        return GraphRAGQueryResponse(
            context=result.get("context", ""),
            sources=result.get("sources", []),
            entities=result.get("entities", []) if request.include_entities else [],
            relationships=result.get("relationships", []) if request.include_relationships else [],
            confidence=result.get("confidence", 0.5),
            success=True,
        )
    except Exception as e:
        return GraphRAGQueryResponse(
            context="",
            sources=[],
            entities=[],
            relationships=[],
            confidence=0.0,
            success=False,
            error=str(e),
        )

@app.post("/graphrag/search/entities")
async def search_entities(request: EntitySearchRequest):
    """Search for medical entities in the knowledge graph"""
    try:
        service = get_graph_rag_service()
        entities = await service.search_entities(
            query=request.query,
            entity_type=request.entity_type,
            limit=request.limit,
        )
        return {"entities": entities, "success": True}
    except Exception as e:
        return {"entities": [], "success": False, "error": str(e)}

@app.post("/graphrag/red-flags")
async def get_red_flags(request: RedFlagsRequest):
    """Get red flags for given symptoms from the knowledge graph"""
    try:
        service = get_graph_rag_service()
        red_flags = await service.get_red_flags_for_symptoms(request.symptoms)
        return {"red_flags": red_flags, "success": True}
    except Exception as e:
        return {"red_flags": [], "success": False, "error": str(e)}

@app.post("/graphrag/conditions")
async def get_possible_conditions(request: ConditionsRequest):
    """Get possible conditions for given symptoms"""
    try:
        service = get_graph_rag_service()
        conditions = await service.get_possible_conditions(request.symptoms)
        return {"conditions": conditions, "success": True}
    except Exception as e:
        return {"conditions": [], "success": False, "error": str(e)}

@app.post("/graphrag/drug-interactions")
async def get_drug_interactions(request: DrugInteractionsRequest):
    """Get drug interactions from the knowledge graph"""
    try:
        service = get_graph_rag_service()
        interactions = await service.get_drug_interactions(request.drugs)
        return {"interactions": interactions, "success": True}
    except Exception as e:
        return {"interactions": [], "success": False, "error": str(e)}

@app.get("/graphrag/stats")
async def get_graphrag_stats():
    """Get statistics about the medical knowledge graph"""
    try:
        service = get_graph_rag_service()
        stats = await service.get_graph_stats()
        return {"stats": stats, "success": True}
    except Exception as e:
        return {"stats": {}, "success": False, "error": str(e)}

@app.post("/graphrag/ingest")
async def ingest_documents(
    directory: str = None,
    background_tasks: BackgroundTasks = None
):
    """Ingest documents into the knowledge graph (background task)"""
    try:
        service = get_graph_rag_service()
        
        if directory:
            # Run ingestion in background
            background_tasks.add_task(service.ingest_directory, directory)
            return {
                "message": f"Started ingesting documents from {directory}",
                "success": True,
            }
        else:
            return {
                "message": "No directory specified",
                "success": False,
            }
    except Exception as e:
        return {"message": str(e), "success": False}

# ==================== ROOT ENDPOINT ====================

@app.get("/")
async def root():
    return {
        "service": "ClinixAI Triage Service",
        "version": "2.1.0",
        "engine": "LangGraph + Neo4j GraphRAG",
        "status": "running",
        "endpoints": {
            "health": "GET /health",
            "analyze": "POST /analyze",
            "graph": "GET /graph",
            "models": "GET /models",
            "graphrag": {
                "query": "POST /graphrag/query",
                "search_entities": "POST /graphrag/search/entities",
                "red_flags": "POST /graphrag/red-flags",
                "conditions": "POST /graphrag/conditions",
                "drug_interactions": "POST /graphrag/drug-interactions",
                "stats": "GET /graphrag/stats",
                "ingest": "POST /graphrag/ingest",
            },
        },
    }

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
