"""
ClinixAI Triage Service
LangGraph-powered AI analysis for medical triage cases

Inference Architecture:
1. llama.cpp (LOCAL) - Primary local inference using GGUF models
2. OpenRouter (CLOUD) - Escalation for critical/urgent cases

Intelligent Routing:
- Standard/Non-urgent cases → llama.cpp (FREE, local, fast)
- Critical/Urgent cases → OpenRouter (cloud, highest accuracy)

The local llama.cpp model acts as an intelligent router:
- Analyzes symptoms locally first
- Escalates to cloud when case severity requires it
- Provides fast responses for simple cases
- Ensures critical cases get best possible analysis

Neo4j GraphRAG for medical knowledge retrieval
"""

import os
import json
import re
import logging
from datetime import datetime
from typing import Optional, List, Dict, Any, TypedDict, Annotated
from contextlib import asynccontextmanager
import operator

from fastapi import FastAPI, HTTPException, BackgroundTasks, File, UploadFile
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field
import httpx

# LangGraph imports
from langgraph.graph import StateGraph, END

# GraphRAG imports
from graphrag import GraphRAGService, Neo4jClient, MedicalSchema

# Setup logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

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

# ==================== LLAMA.CPP LOCAL INFERENCE ====================

async def call_llama_cpp(
    messages: List[Dict], 
    temperature: float = 0.3, 
    max_tokens: int = 512,
    timeout: float = 120.0
) -> Optional[Dict]:
    """
    Call llama.cpp server for local inference.
    
    This is the PRIMARY local inference engine - fastest CPU inference available.
    Uses OpenAI-compatible API format.
    """
    llama_url = os.getenv("LLAMA_CPP_URL", "http://llama-cpp:8080")
    
    try:
        logger.info(f"Calling llama.cpp at {llama_url}")
        async with httpx.AsyncClient(timeout=timeout) as client:
            response = await client.post(
                f"{llama_url}/v1/chat/completions",
                json={
                    "messages": messages,
                    "temperature": temperature,
                    "max_tokens": max_tokens,
                    "stream": False
                }
            )
            if response.status_code == 200:
                data = response.json()
                logger.info(f"llama.cpp response received successfully")
                return {
                    "content": data["choices"][0]["message"]["content"],
                    "backend": "llama-cpp",
                    "model": data.get("model", "qwen2.5-1.5b-instruct")
                }
            else:
                logger.warning(f"llama.cpp returned status {response.status_code}: {response.text}")
    except Exception as e:
        logger.warning(f"llama.cpp inference failed: {e}")
    return None


async def call_openrouter(
    messages: List[Dict], 
    model: str = None,
    temperature: float = 0.3, 
    max_tokens: int = 512,
    timeout: float = 45.0
) -> Optional[Dict]:
    """
    Call OpenRouter API for cloud inference.
    
    Used for:
    - Critical/urgent case escalation
    - When local inference is unavailable
    - Complex cases requiring more capable models
    """
    api_key = os.getenv("OPENROUTER_API_KEY", "")
    if not api_key or api_key == "your-openrouter-key":
        logger.warning("OpenRouter API key not configured")
        return None
    
    # Default to a capable but cost-effective model
    if model is None:
        model = os.getenv("OPENROUTER_DEFAULT_MODEL", "anthropic/claude-3.5-sonnet")
    
    try:
        async with httpx.AsyncClient(timeout=timeout) as client:
            response = await client.post(
                "https://openrouter.ai/api/v1/chat/completions",
                headers={
                    "Authorization": f"Bearer {api_key}",
                    "Content-Type": "application/json",
                    "HTTP-Referer": os.getenv("OPENROUTER_SITE_URL", "https://clinixai.health"),
                    "X-Title": os.getenv("OPENROUTER_SITE_NAME", "ClinixAI"),
                },
                json={
                    "model": model,
                    "messages": messages,
                    "temperature": temperature,
                    "max_tokens": max_tokens
                }
            )
            if response.status_code == 200:
                data = response.json()
                return {
                    "content": data["choices"][0]["message"]["content"],
                    "backend": "openrouter",
                    "model": model
                }
            else:
                logger.warning(f"OpenRouter returned status {response.status_code}: {response.text}")
    except Exception as e:
        logger.warning(f"OpenRouter inference failed: {e}")
    return None

# ==================== LANGGRAPH NODES ====================

def symptom_analyzer_node(state: TriageState) -> TriageState:
    """
    Analyze symptoms and extract features.
    Determines case complexity and whether to escalate to cloud.
    """
    symptoms = state.get("symptoms", [])
    
    # Extract keywords and severity
    symptom_text = " ".join([s.get("description", "").lower() for s in symptoms])
    max_severity = max([s.get("severity", 5) for s in symptoms]) if symptoms else 5
    
    # Critical symptom detection - ALWAYS escalate to cloud
    critical_keywords = [
        "chest pain", "difficulty breathing", "unconscious", 
        "severe bleeding", "stroke", "heart attack", "seizure",
        "not breathing", "no pulse", "coughing blood", "severe trauma"
    ]
    
    # Urgent symptoms - escalate to cloud for better accuracy
    urgent_keywords = [
        "high fever", "severe pain", "vomiting blood", 
        "head injury", "broken bone", "allergic reaction",
        "confusion", "severe headache", "persistent vomiting",
        "difficulty swallowing", "sudden vision loss"
    ]
    
    detected_critical = [kw for kw in critical_keywords if kw in symptom_text]
    detected_urgent = [kw for kw in urgent_keywords if kw in symptom_text]
    
    # Calculate complexity score
    complexity_score = 0.3  # Base complexity
    complexity_score += len(symptoms) * 0.1
    complexity_score += (max_severity / 10) * 0.3
    if detected_critical:
        complexity_score = 1.0  # Critical always gets max complexity
    elif detected_urgent:
        complexity_score += 0.3
    complexity_score = min(complexity_score, 1.0)
    
    # Determine if we should escalate to cloud
    should_escalate = bool(detected_critical) or bool(detected_urgent) or max_severity >= 8
    
    return {
        **state,
        "symptom_features": {
            "symptom_text": symptom_text,
            "max_severity": max_severity,
            "critical_keywords": detected_critical,
            "urgent_keywords": detected_urgent,
            "symptom_count": len(symptoms),
            "should_escalate": should_escalate,
        },
        "complexity_score": complexity_score,
        "messages": [f"[SymptomAnalyzer] Complexity: {complexity_score:.2f}, Critical: {detected_critical}, Urgent: {detected_urgent}"],
    }


async def llama_cpp_node(state: TriageState) -> TriageState:
    """
    Process with local llama.cpp model.
    
    Used for:
    - Standard cases (fast local inference)
    - Initial triage assessment
    - Cost-effective processing
    """
    features = state.get("symptom_features", {})
    
    prompt = f"""You are ClinixAI, a medical triage assistant. Analyze these symptoms and provide a structured assessment.

PATIENT SYMPTOMS:
{features.get('symptom_text', 'No symptoms provided')}

SEVERITY RATING: {features.get('max_severity', 5)}/10
SYMPTOM COUNT: {features.get('symptom_count', 0)}

Respond ONLY with valid JSON in this exact format:
{{"urgency": "critical|urgent|standard|non-urgent", "confidence": 0.0-1.0, "assessment": "Brief clinical assessment", "action": "Recommended action", "conditions": [{{"name": "Possible condition", "probability": 0.0-1.0}}]}}"""

    messages = [
        {"role": "system", "content": "You are ClinixAI, an expert medical triage AI. Always respond with valid JSON only. Be accurate, concise, and prioritize patient safety."},
        {"role": "user", "content": prompt}
    ]
    
    try:
        start = datetime.utcnow()
        result = await call_llama_cpp(messages, temperature=0.3, max_tokens=500)
        
        if result:
            content = result["content"]
            
            # Extract JSON from response
            json_match = re.search(r'```json\s*(.*?)\s*```', content, re.DOTALL)
            if json_match:
                content = json_match.group(1)
            else:
                json_match = re.search(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}', content, re.DOTALL)
                if json_match:
                    content = json_match.group()
            
            parsed = json.loads(content)
            inference_time = int((datetime.utcnow() - start).total_seconds() * 1000)
            
            return {
                **state,
                "urgency_level": parsed.get("urgency", "standard"),
                "confidence_score": parsed.get("confidence", 0.75),
                "primary_assessment": parsed.get("assessment", "Assessment via llama.cpp"),
                "recommended_action": parsed.get("action", "Consult healthcare professional"),
                "differential_diagnoses": parsed.get("conditions", []),
                "inference_provider": f"llama-cpp/{result.get('model', 'qwen2.5-1.5b')}",
                "inference_time_ms": inference_time,
                "escalated_to_cloud": False,
                "error": None,
                "messages": [f"[llama.cpp] Success in {inference_time}ms"],
            }
    except json.JSONDecodeError as e:
        logger.warning(f"llama.cpp JSON parse error: {e}")
    except Exception as e:
        logger.warning(f"llama.cpp node error: {e}")
    
    return {
        **state,
        "error": "llama.cpp inference failed",
        "messages": ["[llama.cpp] Failed, trying OpenRouter escalation"],
    }


async def openrouter_node(state: TriageState) -> TriageState:
    """
    Process with OpenRouter API - Cloud escalation for critical/urgent cases.
    
    Used when:
    - Case is critical or urgent
    - Local inference failed
    - Higher accuracy is required
    
    Model selection based on case severity:
    - Critical: Claude 3.5 Sonnet or GPT-4o (highest accuracy)
    - Urgent: GPT-4o-mini or Claude 3 Haiku (good balance)
    """
    features = state.get("symptom_features", {})
    complexity = state.get("complexity_score", 0.5)
    
    # Dynamic model selection based on severity
    if features.get("critical_keywords") or complexity >= 0.9:
        # Critical cases - use most capable model
        model = os.getenv("OPENROUTER_CRITICAL_MODEL", "anthropic/claude-3.5-sonnet")
    elif features.get("urgent_keywords") or complexity >= 0.7:
        # Urgent cases - use capable but cost-effective model
        model = os.getenv("OPENROUTER_URGENT_MODEL", "openai/gpt-4o-mini")
    else:
        # Standard escalation - use cost-effective model
        model = os.getenv("OPENROUTER_STANDARD_MODEL", "meta-llama/llama-3.1-70b-instruct")
    
    # Include RAG context if available
    rag_context = features.get("rag_context", "")
    
    prompt = f"""You are ClinixAI, a medical triage assistant. Analyze these symptoms and provide a structured assessment.

PATIENT SYMPTOMS:
{features.get('symptom_text', 'No symptoms provided')}

SEVERITY RATING: {features.get('max_severity', 5)}/10
CRITICAL INDICATORS: {features.get('critical_keywords', [])}
URGENT INDICATORS: {features.get('urgent_keywords', [])}

{f'MEDICAL KNOWLEDGE CONTEXT:{chr(10)}{rag_context}' if rag_context else ''}

Respond ONLY with valid JSON in this exact format:
{{"urgency": "critical|urgent|standard|non-urgent", "confidence": 0.0-1.0, "assessment": "Brief clinical assessment", "action": "Recommended action", "conditions": [{{"name": "Possible condition", "probability": 0.0-1.0}}], "red_flags": ["Warning signs if any"]}}"""

    messages = [
        {"role": "system", "content": "You are ClinixAI, an expert medical triage AI. Always respond with valid JSON only. Be accurate, concise, and prioritize patient safety."},
        {"role": "user", "content": prompt}
    ]
    
    try:
        start = datetime.utcnow()
        result = await call_openrouter(messages, model=model, temperature=0.3, max_tokens=500)
        
        if result:
            content = result["content"]
            
            # Extract JSON from response
            json_match = re.search(r'```json\s*(.*?)\s*```', content, re.DOTALL)
            if json_match:
                content = json_match.group(1)
            else:
                json_match = re.search(r'\{[^{}]*(?:\{[^{}]*\}[^{}]*)*\}', content, re.DOTALL)
                if json_match:
                    content = json_match.group()
            
            parsed = json.loads(content)
            inference_time = int((datetime.utcnow() - start).total_seconds() * 1000)
            
            return {
                **state,
                "urgency_level": parsed.get("urgency", "standard"),
                "confidence_score": parsed.get("confidence", 0.85),
                "primary_assessment": parsed.get("assessment", "Assessment via OpenRouter"),
                "recommended_action": parsed.get("action", "Consult healthcare professional"),
                "differential_diagnoses": parsed.get("conditions", []),
                "inference_provider": f"openrouter/{model}",
                "inference_time_ms": inference_time,
                "escalated_to_cloud": True,
                "error": None,
                "messages": [f"[OpenRouter] Success with {model} in {inference_time}ms"],
            }
    except json.JSONDecodeError as e:
        logger.warning(f"OpenRouter JSON parse error: {e}")
    except Exception as e:
        logger.warning(f"OpenRouter node error: {e}")
    
    return {
        **state,
        "error": "OpenRouter inference failed",
        "messages": ["[OpenRouter] Failed, falling back to rules"],
    }


def fallback_node(state: TriageState) -> TriageState:
    """
    Rule-based fallback when all AI providers fail.
    
    Provides basic triage based on keyword detection.
    Always errs on the side of caution.
    """
    features = state.get("symptom_features", {})
    
    # Determine urgency based on keywords
    if features.get("critical_keywords"):
        urgency = "critical"
        confidence = 0.85
        assessment = "Critical symptoms detected. Immediate medical attention required."
        action = "Call emergency services (911) or go to nearest emergency room immediately."
    elif features.get("urgent_keywords") or features.get("max_severity", 5) >= 8:
        urgency = "urgent"
        confidence = 0.75
        assessment = "Urgent symptoms detected. Prompt medical attention recommended."
        action = "Visit a healthcare facility or urgent care within the next few hours."
    elif features.get("max_severity", 5) >= 6:
        urgency = "standard"
        confidence = 0.65
        assessment = "Moderate symptoms requiring medical evaluation."
        action = "Schedule an appointment with your healthcare provider within 1-2 days."
    else:
        urgency = "non-urgent"
        confidence = 0.6
        assessment = "Mild symptoms that can likely be managed with self-care."
        action = "Monitor symptoms. See a doctor if they worsen or persist beyond a few days."
    
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

def should_escalate_to_cloud(state: TriageState) -> str:
    """
    Intelligent routing decision.
    
    Routes to:
    - 'cloud': Critical/urgent cases → OpenRouter (highest accuracy)
    - 'local': Standard cases → llama.cpp (fast, free)
    """
    features = state.get("symptom_features", {})
    
    # Always escalate critical/urgent cases
    if features.get("should_escalate", False):
        return "cloud"
    
    # Check complexity threshold
    complexity = state.get("complexity_score", 0.5)
    threshold = float(os.getenv("CLOUD_ESCALATION_THRESHOLD", "0.7"))
    
    if complexity >= threshold:
        return "cloud"
    
    return "local"


def check_llama_result(state: TriageState) -> str:
    """Check if llama.cpp succeeded"""
    if state.get("error") is None and state.get("inference_provider", "").startswith("llama-cpp"):
        return "done"
    return "escalate"


def check_openrouter_result(state: TriageState) -> str:
    """Check if OpenRouter succeeded"""
    if state.get("error") is None and state.get("inference_provider", "").startswith("openrouter"):
        return "done"
    return "fallback"

# ==================== BUILD LANGGRAPH ====================

def build_triage_graph() -> StateGraph:
    """
    Build the LangGraph workflow for triage.
    
    Architecture:
    1. Symptom Analysis → Determine severity
    2. Intelligent Routing:
       - Critical/Urgent → OpenRouter (cloud)
       - Standard → llama.cpp (local)
    3. Fallback chain for resilience
    """
    workflow = StateGraph(TriageState)
    
    # Add nodes
    workflow.add_node("symptom_analyzer", symptom_analyzer_node)
    workflow.add_node("llama_cpp", llama_cpp_node)
    workflow.add_node("openrouter", openrouter_node)
    workflow.add_node("fallback", fallback_node)
    
    # Set entry point
    workflow.set_entry_point("symptom_analyzer")
    
    # Intelligent routing after symptom analysis
    workflow.add_conditional_edges(
        "symptom_analyzer",
        should_escalate_to_cloud,
        {
            "cloud": "openrouter",  # Critical/urgent → cloud
            "local": "llama_cpp",   # Standard → local
        }
    )
    
    # llama.cpp result check: success or escalate to cloud
    workflow.add_conditional_edges(
        "llama_cpp",
        check_llama_result,
        {"done": END, "escalate": "openrouter"}
    )
    
    # OpenRouter result check: success or fallback
    workflow.add_conditional_edges(
        "openrouter",
        check_openrouter_result,
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
    escalated_to_cloud: bool = False
    ai_model: str
    inference_time_ms: int
    complexity_score: Optional[float] = None
    workflow_messages: Optional[List[str]] = None
    disclaimer: str = "This is an AI-assisted assessment. Always consult a healthcare professional."

# Chat models
class ChatRequest(BaseModel):
    """Request for chat with local AI + RAG"""
    message: str = Field(..., description="User message/question")
    use_rag: bool = Field(default=True, description="Enable RAG context retrieval")
    conversation_history: Optional[List[Dict[str, str]]] = Field(default=None, description="Previous messages")
    max_tokens: int = Field(default=150, description="Maximum response tokens (reduced for speed)")
    temperature: float = Field(default=0.3, description="Response creativity (0-1)")
    force_cloud: bool = Field(default=False, description="Force cloud escalation (OpenRouter)")

class ChatResponse(BaseModel):
    """Response from chat endpoint"""
    success: bool
    response: str
    model: str
    backend: str = "unknown"
    response_time_ms: int
    rag_context_used: bool = False
    sources_count: int = 0
    error: Optional[str] = None

# ==================== APP SETUP ====================

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    print("🚀 ClinixAI Triage Service Starting...")
    print("=" * 50)
    print("🤖 Local LLM: llama.cpp (Qwen2.5-1.5B-Instruct)")
    print("☁️  Cloud LLM: OpenRouter (Claude 3.5 Sonnet / GPT-4o)")
    print("📊 Escalation Threshold:", os.getenv("CLOUD_ESCALATION_THRESHOLD", "0.7"))
    print("🔗 GraphRAG: Neo4j Knowledge Base")
    print("=" * 50)
    yield
    # Shutdown
    print("👋 ClinixAI Triage Service Shutting Down...")

app = FastAPI(
    title="ClinixAI Triage Service",
    description="""
    LangGraph-powered AI analysis for medical triage.
    
    **Architecture:**
    - **Local (llama.cpp)**: Fast, free inference for standard cases
    - **Cloud (OpenRouter)**: Escalation for critical/urgent cases
    
    **Intelligent Routing:**
    - Critical symptoms → Cloud (highest accuracy)
    - Urgent symptoms → Cloud (better safety)
    - Standard cases → Local (fast, cost-effective)
    """,
    version="3.0.0",
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
    """Health check endpoint"""
    # Check llama.cpp status
    llama_status = "unknown"
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            resp = await client.get(f"{os.getenv('LLAMA_CPP_URL', 'http://llama-cpp:8080')}/health")
            llama_status = "healthy" if resp.status_code == 200 else "unhealthy"
    except:
        llama_status = "unavailable"
    
    return {
        "status": "healthy",
        "service": "clinixai-triage-service",
        "version": "3.0.0",
        "engine": "langgraph",
        "llama_cpp": llama_status,
        "timestamp": datetime.utcnow().isoformat(),
    }


@app.post("/analyze", response_model=TriageResponse)
async def analyze_triage(request: TriageRequest):
    """
    Perform AI triage analysis.
    
    **Intelligent Routing:**
    - Critical/Urgent cases → OpenRouter (cloud)
    - Standard cases → llama.cpp (local)
    """
    
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
        logger.error(f"LangGraph workflow failed: {e}")
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
        return {"format": "mermaid", "graph": mermaid}
    except Exception as e:
        return {
            "format": "text",
            "graph": """
graph TD
    A[Symptom Analyzer] --> B{Critical/Urgent?}
    B -->|Yes| C[OpenRouter Cloud]
    B -->|No| D[llama.cpp Local]
    D -->|Success| END
    D -->|Fail| C
    C -->|Success| END
    C -->|Fail| E[Rule Fallback]
    E --> END
""",
            "error": str(e),
        }


@app.get("/models")
async def get_available_models():
    """Get status of available AI models"""
    # Check llama.cpp
    llama_available = False
    try:
        async with httpx.AsyncClient(timeout=5.0) as client:
            resp = await client.get(f"{os.getenv('LLAMA_CPP_URL', 'http://llama-cpp:8080')}/health")
            llama_available = resp.status_code == 200
    except:
        pass
    
    # Check OpenRouter
    openrouter_configured = bool(os.getenv("OPENROUTER_API_KEY")) and os.getenv("OPENROUTER_API_KEY") != "your-openrouter-key"
    
    return {
        "local": {
            "llama_cpp": {
                "model": "Qwen2.5-1.5B-Instruct (GGUF Q4_K_M)",
                "available": llama_available,
                "url": os.getenv("LLAMA_CPP_URL", "http://llama-cpp:8080"),
                "description": "Fast local inference for standard cases"
            }
        },
        "cloud": {
            "openrouter": {
                "configured": openrouter_configured,
                "critical_model": os.getenv("OPENROUTER_CRITICAL_MODEL", "anthropic/claude-3.5-sonnet"),
                "urgent_model": os.getenv("OPENROUTER_URGENT_MODEL", "openai/gpt-4o-mini"),
                "standard_model": os.getenv("OPENROUTER_STANDARD_MODEL", "meta-llama/llama-3.1-70b-instruct"),
                "description": "Cloud escalation for critical/urgent cases"
            }
        },
        "fallback": {
            "rule_based": {
                "available": True,
                "description": "Always-available rule-based fallback"
            }
        },
        "escalation_threshold": float(os.getenv("CLOUD_ESCALATION_THRESHOLD", "0.7")),
    }


# ==================== CHAT ENDPOINT ====================

@app.post("/chat", response_model=ChatResponse)
async def chat_with_ai(request: ChatRequest):
    """
    Chat with AI enhanced with RAG knowledge.
    
    **Routing:**
    - Standard questions → llama.cpp (local, free)
    - force_cloud=true → OpenRouter (cloud)
    
    **RAG Integration:**
    - Retrieves relevant medical knowledge from Neo4j
    - Augments LLM responses with context
    """
    import time
    start_time = time.time()
    
    # Step 1: Get RAG context (if enabled)
    rag_context = ""
    sources_count = 0
    
    if request.use_rag:
        try:
            rag_service = get_advanced_rag_service()
            context = rag_service.retrieve(
                query=request.message,
                top_k=3,
                include_entities=True,
                include_graph_context=True
            )
            rag_context = rag_service.format_context_for_llm(context)
            sources_count = len(context.chunks)
        except Exception as e:
            logger.warning(f"RAG retrieval failed: {e}")
    
    # Step 2: Build messages
    system_prompt = """You are ClinixAI, a helpful AI medical assistant. Your role is to:
1. Provide accurate, helpful medical information
2. NEVER diagnose - always recommend consulting healthcare professionals  
3. Prioritize patient safety above all else
4. Be clear, concise, and compassionate

If medical knowledge context is provided, use it to inform your response."""

    messages = [{"role": "system", "content": system_prompt}]
    
    if request.conversation_history:
        for msg in request.conversation_history[-5:]:
            messages.append(msg)
    
    if rag_context:
        user_content = f"""Based on the following medical knowledge:

{rag_context}

User Question: {request.message}

Provide a helpful, accurate response."""
    else:
        user_content = request.message
    
    messages.append({"role": "user", "content": user_content})
    
    # Step 3: Call appropriate backend
    result = None
    
    if request.force_cloud:
        # User requested cloud escalation
        result = await call_openrouter(messages, temperature=request.temperature, max_tokens=request.max_tokens)
    else:
        # Try local first, then escalate to cloud if needed
        result = await call_llama_cpp(messages, temperature=request.temperature, max_tokens=request.max_tokens)
        if not result:
            result = await call_openrouter(messages, temperature=request.temperature, max_tokens=request.max_tokens)
    
    response_time = int((time.time() - start_time) * 1000)
    
    if result:
        return ChatResponse(
            success=True,
            response=result["content"],
            model=result.get("model", "unknown"),
            backend=result["backend"],
            response_time_ms=response_time,
            rag_context_used=bool(rag_context),
            sources_count=sources_count
        )
    else:
        return ChatResponse(
            success=False,
            response="I'm sorry, I'm unable to process your request at the moment. Please try again or consult a healthcare professional directly.",
            model="none",
            backend="none",
            response_time_ms=response_time,
            rag_context_used=bool(rag_context),
            sources_count=sources_count,
            error="All backends unavailable. Check if llama.cpp is running or configure OPENROUTER_API_KEY."
        )


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
            context="", sources=[], entities=[], relationships=[],
            confidence=0.0, success=False, error=str(e)
        )


@app.post("/graphrag/search/entities")
async def search_entities(request: EntitySearchRequest):
    """Search for medical entities in the knowledge graph"""
    try:
        service = get_graph_rag_service()
        entities = await service.search_entities(
            query=request.query, entity_type=request.entity_type, limit=request.limit
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
        stats = service.get_graph_stats()
        return {"stats": stats, "success": True}
    except Exception as e:
        return {"stats": {}, "success": False, "error": str(e)}


@app.post("/graphrag/ingest")
async def ingest_documents(directory: str = None, background_tasks: BackgroundTasks = None):
    """Ingest documents into the knowledge graph (background task)"""
    try:
        service = get_graph_rag_service()
        if directory:
            background_tasks.add_task(service.ingest_directory, directory)
            return {"message": f"Started ingesting documents from {directory}", "success": True}
        return {"message": "No directory specified", "success": False}
    except Exception as e:
        return {"message": str(e), "success": False}


# ==================== ADVANCED RAG ENDPOINTS ====================

_advanced_rag_service = None

def get_advanced_rag_service():
    """Get or create the advanced RAG service"""
    global _advanced_rag_service
    if _advanced_rag_service is None:
        try:
            from graphrag.advanced_rag_service import AdvancedRAGService
            _advanced_rag_service = AdvancedRAGService()
            _advanced_rag_service.initialize()
        except Exception as e:
            logger.error(f"Failed to initialize AdvancedRAGService: {e}")
            raise HTTPException(status_code=500, detail=f"RAG service unavailable: {e}")
    return _advanced_rag_service


class PDFUploadResponse(BaseModel):
    success: bool
    document_id: Optional[str] = None
    file_name: str
    chunks: int = 0
    entities_extracted: int = 0
    relationships_extracted: int = 0
    message: str = ""


class RAGQueryRequest(BaseModel):
    query: str
    top_k: int = 5
    include_entities: bool = True
    include_graph_context: bool = True


class RAGQueryResponse(BaseModel):
    success: bool
    query: str
    chunks: List[Dict[str, Any]] = []
    entities: List[Dict[str, Any]] = []
    graph_paths: List[str] = []
    formatted_context: str = ""
    retrieval_method: str = "hybrid"


@app.post("/rag/upload-pdf", response_model=PDFUploadResponse)
async def upload_pdf_for_rag(
    file: UploadFile = File(...),
    extract_entities: bool = False,
    batch_size: int = 10,
    background_tasks: BackgroundTasks = None
):
    """
    Upload a PDF document to be ingested into the medical knowledge graph.
    
    - Embeddings: FREE (local sentence-transformers)
    - Entity extraction: Uses OpenRouter if enabled (costs credits)
    """
    import tempfile
    import os as _os
    
    if not file.filename.lower().endswith('.pdf'):
        raise HTTPException(status_code=400, detail="Only PDF files are supported")
    
    try:
        with tempfile.NamedTemporaryFile(delete=False, suffix='.pdf') as tmp:
            content = await file.read()
            tmp.write(content)
            tmp_path = tmp.name
        
        rag_service = get_advanced_rag_service()
        stats = await rag_service.ingest_pdf(
            pdf_path=tmp_path,
            extract_entities=extract_entities,
            batch_size=batch_size
        )
        _os.unlink(tmp_path)
        
        cost_msg = " (entity extraction used OpenRouter credits)" if extract_entities else " (FREE - no API credits used)"
        
        return PDFUploadResponse(
            success=True,
            document_id=stats.get("document_id"),
            file_name=file.filename,
            chunks=stats.get("chunks", 0),
            entities_extracted=stats.get("entities_extracted", 0),
            relationships_extracted=stats.get("relationships_extracted", 0),
            message=f"Successfully ingested {file.filename}{cost_msg}"
        )
    except Exception as e:
        logger.error(f"PDF upload failed: {e}")
        return PDFUploadResponse(success=False, file_name=file.filename, message=f"Failed: {str(e)}")


@app.post("/rag/query", response_model=RAGQueryResponse)
async def query_rag(request: RAGQueryRequest):
    """Query the knowledge graph using hybrid retrieval"""
    try:
        rag_service = get_advanced_rag_service()
        context = rag_service.retrieve(
            query=request.query,
            top_k=request.top_k,
            include_entities=request.include_entities,
            include_graph_context=request.include_graph_context
        )
        
        chunks = [
            {
                "id": c.id,
                "text": c.text[:500],
                "document_id": c.document_id,
                "score": c.metadata.get("score", 0),
                "method": c.metadata.get("method", "unknown")
            }
            for c in context.chunks
        ]
        
        formatted_context = rag_service.format_context_for_llm(context)
        
        return RAGQueryResponse(
            success=True,
            query=request.query,
            chunks=chunks,
            entities=context.entities,
            graph_paths=context.graph_paths,
            formatted_context=formatted_context,
            retrieval_method=context.retrieval_method
        )
    except Exception as e:
        logger.error(f"RAG query failed: {e}")
        return RAGQueryResponse(success=False, query=request.query, formatted_context=f"Error: {str(e)}")


@app.get("/rag/stats")
async def get_rag_stats():
    """Get advanced RAG service statistics"""
    try:
        rag_service = get_advanced_rag_service()
        return {"success": True, **rag_service.get_stats()}
    except Exception as e:
        return {"success": False, "error": str(e)}


@app.post("/rag/ingest-directory")
async def ingest_directory(directory: str, extract_entities: bool = True, background_tasks: BackgroundTasks = None):
    """Ingest all PDFs in a directory (runs in background)"""
    try:
        rag_service = get_advanced_rag_service()
        
        async def _ingest():
            return await rag_service.ingest_directory(directory=directory, extract_entities=extract_entities)
        
        background_tasks.add_task(_ingest)
        return {"success": True, "message": f"Started ingesting PDFs from {directory}", "status": "processing"}
    except Exception as e:
        return {"success": False, "error": str(e)}


# ==================== RAG-ENHANCED TRIAGE ====================

@app.post("/analyze-with-rag")
async def analyze_with_rag(request: TriageRequest):
    """
    Perform AI triage analysis enhanced with RAG context.
    
    Combines symptom analysis with knowledge graph retrieval
    for more accurate assessments.
    """
    try:
        # Get RAG context
        rag_context = ""
        rag_entities = []
        rag_paths = []
        
        try:
            rag_service = get_advanced_rag_service()
            symptom_text = " ".join([s.description for s in request.symptoms])
            context = rag_service.retrieve(
                query=symptom_text,
                top_k=3,
                include_entities=True,
                include_graph_context=True
            )
            rag_context = rag_service.format_context_for_llm(context)
            rag_entities = context.entities
            rag_paths = context.graph_paths
        except Exception as e:
            logger.warning(f"RAG retrieval failed: {e}")
        
        # Prepare initial state with RAG context
        initial_state: TriageState = {
            "session_id": request.session_id,
            "symptoms": [s.model_dump() for s in request.symptoms],
            "vital_signs": request.vital_signs.model_dump() if request.vital_signs else None,
            "patient_info": {
                "age": request.patient_age,
                "gender": request.patient_gender,
                "medical_history": request.medical_history or [],
            },
            "symptom_features": {"rag_context": rag_context},
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
                differential_diagnoses.append(DifferentialDiagnosis(condition=d, probability=0.5))
        
        response = TriageResponse(
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
            workflow_messages=result.get("messages", []),
        )
        
        return {
            **response.model_dump(),
            "rag_enhanced": True,
            "knowledge_sources": len(rag_entities),
            "graph_insights": rag_paths[:5],
        }
        
    except Exception as e:
        logger.error(f"RAG-enhanced analysis failed: {e}")
        raise HTTPException(status_code=500, detail=str(e))


# ==================== ROOT ENDPOINT ====================

@app.get("/")
async def root():
    return {
        "service": "ClinixAI Triage Service",
        "version": "3.0.0",
        "architecture": {
            "local": "llama.cpp (Qwen2.5-1.5B-Instruct)",
            "cloud": "OpenRouter (Claude 3.5 Sonnet / GPT-4o)",
            "knowledge": "Neo4j GraphRAG"
        },
        "routing": {
            "standard_cases": "Local (llama.cpp) - Fast & Free",
            "critical_cases": "Cloud (OpenRouter) - Highest Accuracy",
            "urgent_cases": "Cloud (OpenRouter) - Better Safety"
        },
        "status": "running",
        "endpoints": {
            "health": "GET /health",
            "analyze": "POST /analyze (intelligent routing)",
            "analyze_with_rag": "POST /analyze-with-rag",
            "chat": "POST /chat (local AI + RAG)",
            "graph": "GET /graph",
            "models": "GET /models",
            "graphrag": "/graphrag/*",
            "rag": "/rag/*",
        },
    }


if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)
