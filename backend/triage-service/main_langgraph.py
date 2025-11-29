"""
ClinixAI Triage Service
========================
Cloud-based AI analysis for medical triage with LangGraph orchestration.

Features:
- LangGraph-based hybrid inference pipeline
- Multiple AI providers (HuggingFace, OpenAI, Anthropic)
- Local LLM fallback for offline operation
- Africa-specific medical knowledge
"""

import os
import json
from datetime import datetime
from typing import Optional, List, Dict, Any
from contextlib import asynccontextmanager

from fastapi import FastAPI, HTTPException, BackgroundTasks, Depends
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

# Import LangGraph orchestrator
from ai.langgraph_orchestrator import TriageGraph, get_triage_graph

# ==================== MODELS ====================

class Symptom(BaseModel):
    """Individual symptom input"""
    description: str = Field(..., min_length=1, description="Symptom description")
    severity: Optional[int] = Field(None, ge=1, le=10, description="Severity 1-10")
    duration_hours: Optional[int] = Field(None, ge=0, description="Duration in hours")
    body_location: Optional[str] = Field(None, description="Body location")


class VitalSigns(BaseModel):
    """Patient vital signs"""
    temperature: Optional[float] = Field(None, ge=30.0, le=45.0, description="Temperature in Celsius")
    heart_rate: Optional[int] = Field(None, ge=20, le=250, description="Heart rate in BPM")
    blood_pressure: Optional[str] = Field(None, description="Blood pressure e.g. '120/80'")
    oxygen_saturation: Optional[int] = Field(None, ge=0, le=100, description="SpO2 percentage")
    respiratory_rate: Optional[int] = Field(None, ge=5, le=60, description="Breaths per minute")


class TriageRequest(BaseModel):
    """Triage analysis request"""
    session_id: str = Field(..., description="Unique session identifier")
    symptoms: List[Symptom] = Field(..., min_items=1, description="List of symptoms")
    vital_signs: Optional[VitalSigns] = Field(None, description="Optional vital signs")
    patient_age: Optional[int] = Field(None, ge=0, le=150, description="Patient age")
    patient_gender: Optional[str] = Field(None, description="Patient gender")
    medical_history: Optional[List[str]] = Field(None, description="Medical history")


class DifferentialDiagnosis(BaseModel):
    """Possible condition with probability"""
    condition: str
    probability: float = Field(ge=0.0, le=1.0)
    icd_code: Optional[str] = None
    reasoning: Optional[str] = None


class TriageResponse(BaseModel):
    """Triage analysis response"""
    session_id: str
    urgency_level: str
    confidence_score: float
    primary_assessment: str
    recommended_action: str
    differential_diagnoses: List[DifferentialDiagnosis]
    red_flags: List[str] = []
    follow_up_questions: List[str] = []
    escalated_to_cloud: bool = True
    provider_used: str
    inference_time_ms: int
    disclaimer: str = "This is an AI-assisted assessment. Always consult a healthcare professional."
    timestamp: str


class HealthResponse(BaseModel):
    """Health check response"""
    status: str
    service: str
    timestamp: str
    version: str
    ai_providers: Dict[str, str] = {}


class GraphVisualizationResponse(BaseModel):
    """Graph visualization response"""
    mermaid_diagram: str


# ==================== APP SETUP ====================

@asynccontextmanager
async def lifespan(app: FastAPI):
    """Application lifespan management"""
    # Startup
    print("🚀 ClinixAI Triage Service Starting...")
    print("📊 Initializing LangGraph orchestrator...")
    
    # Initialize the triage graph
    try:
        graph = get_triage_graph()
        print("✅ LangGraph orchestrator initialized")
    except Exception as e:
        print(f"⚠️ LangGraph initialization warning: {e}")
    
    # Check AI provider configurations
    providers_status = {}
    if os.getenv("HUGGINGFACE_API_KEY"):
        providers_status["huggingface"] = "configured"
        print("✅ HuggingFace API configured")
    else:
        providers_status["huggingface"] = "not_configured"
        print("⚠️ HuggingFace API not configured")
    
    if os.getenv("OPENAI_API_KEY") and os.getenv("OPENAI_API_KEY") != "your-openai-key":
        providers_status["openai"] = "configured"
        print("✅ OpenAI API configured")
    else:
        providers_status["openai"] = "not_configured"
        print("⚠️ OpenAI API not configured")
    
    if os.getenv("ANTHROPIC_API_KEY") and os.getenv("ANTHROPIC_API_KEY") != "your-anthropic-key":
        providers_status["anthropic"] = "configured"
        print("✅ Anthropic API configured")
    else:
        providers_status["anthropic"] = "not_configured"
        print("⚠️ Anthropic API not configured")
    
    app.state.providers_status = providers_status
    print("🎯 ClinixAI Triage Service Ready!")
    
    yield
    
    # Shutdown
    print("👋 ClinixAI Triage Service Shutting Down...")


app = FastAPI(
    title="ClinixAI Triage Service",
    description="""
    AI-powered medical triage analysis service for ClinixAI.
    
    ## Features
    - **LangGraph Orchestration**: State-machine based inference pipeline
    - **Multi-Provider Support**: HuggingFace, OpenAI, Anthropic
    - **Hybrid Inference**: Automatic routing between local and cloud
    - **Africa-Optimized**: Region-specific medical knowledge
    
    ## Endpoints
    - `/analyze` - Main triage analysis endpoint
    - `/health` - Service health check
    - `/graph` - View inference pipeline visualization
    """,
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


# ==================== DEPENDENCIES ====================

def get_graph() -> TriageGraph:
    """Dependency to get the triage graph"""
    return get_triage_graph()


# ==================== ROUTES ====================

@app.get("/health", response_model=HealthResponse, tags=["System"])
async def health_check():
    """
    Check service health and AI provider status.
    """
    providers_status = getattr(app.state, 'providers_status', {})
    
    return HealthResponse(
        status="healthy",
        service="clinixai-triage-service",
        timestamp=datetime.utcnow().isoformat(),
        version="2.0.0",
        ai_providers=providers_status
    )


@app.get("/", tags=["System"])
async def root():
    """
    Service information endpoint.
    """
    return {
        "service": "ClinixAI Triage Service",
        "version": "2.0.0",
        "description": "LangGraph-powered medical triage AI",
        "status": "running",
        "endpoints": {
            "health": "GET /health",
            "analyze": "POST /analyze",
            "graph": "GET /graph",
            "docs": "GET /docs",
        },
        "ai_framework": "LangGraph",
    }


@app.post("/analyze", response_model=TriageResponse, tags=["Triage"])
async def analyze_triage(
    request: TriageRequest,
    graph: TriageGraph = Depends(get_graph)
):
    """
    Perform AI-powered triage analysis.
    
    The analysis pipeline:
    1. **Symptom Intake**: Normalize and preprocess symptoms
    2. **Risk Assessment**: Calculate risk score and complexity
    3. **Routing Decision**: Determine local vs cloud inference
    4. **AI Inference**: Run selected inference provider
    5. **Result Aggregation**: Combine and validate results
    6. **Response Formatting**: Format final response
    
    ## Request Body
    - **session_id**: Unique identifier for this triage session
    - **symptoms**: List of symptoms with optional severity and duration
    - **vital_signs**: Optional vital signs measurements
    - **patient_age**: Optional patient age
    - **patient_gender**: Optional patient gender
    - **medical_history**: Optional list of medical conditions
    
    ## Response
    Returns urgency level, confidence score, assessment, and recommendations.
    """
    try:
        # Convert request to dict for graph
        symptoms_dict = [s.model_dump() for s in request.symptoms]
        vital_signs_dict = request.vital_signs.model_dump() if request.vital_signs else None
        
        # Run the LangGraph pipeline
        result = await graph.run(
            session_id=request.session_id,
            symptoms=symptoms_dict,
            vital_signs=vital_signs_dict,
            patient_age=request.patient_age,
            patient_gender=request.patient_gender,
            medical_history=request.medical_history,
        )
        
        # Parse differential diagnoses
        diagnoses = []
        for d in result.get("differential_diagnoses", []):
            if isinstance(d, dict):
                diagnoses.append(DifferentialDiagnosis(
                    condition=d.get("condition", "Unknown"),
                    probability=d.get("probability", 0.5),
                    icd_code=d.get("icd_code"),
                    reasoning=d.get("reasoning"),
                ))
        
        return TriageResponse(
            session_id=result.get("session_id", request.session_id),
            urgency_level=result.get("urgency_level", "standard"),
            confidence_score=result.get("confidence_score", 0.5),
            primary_assessment=result.get("primary_assessment", "Assessment unavailable"),
            recommended_action=result.get("recommended_action", "Consult healthcare provider"),
            differential_diagnoses=diagnoses,
            red_flags=result.get("red_flags", []),
            follow_up_questions=result.get("follow_up_questions", []),
            escalated_to_cloud=result.get("escalated_to_cloud", False),
            provider_used=result.get("provider_used", "unknown"),
            inference_time_ms=result.get("inference_time_ms", 0),
            timestamp=result.get("timestamp", datetime.utcnow().isoformat()),
        )
        
    except Exception as e:
        print(f"Triage analysis error: {e}")
        raise HTTPException(
            status_code=500,
            detail=f"Triage analysis failed: {str(e)}"
        )


@app.get("/graph", response_model=GraphVisualizationResponse, tags=["System"])
async def get_graph_visualization(graph: TriageGraph = Depends(get_graph)):
    """
    Get Mermaid diagram of the LangGraph inference pipeline.
    
    Can be rendered using Mermaid.js or any Mermaid-compatible viewer.
    """
    try:
        mermaid = graph.get_graph_visualization()
        return GraphVisualizationResponse(mermaid_diagram=mermaid)
    except Exception as e:
        return GraphVisualizationResponse(
            mermaid_diagram=f"Error generating visualization: {e}"
        )


@app.get("/providers", tags=["System"])
async def get_providers_status():
    """
    Get detailed status of AI providers.
    """
    providers_status = getattr(app.state, 'providers_status', {})
    
    return {
        "providers": providers_status,
        "fallback_available": True,  # Rule-based fallback always available
        "recommended_action": "Configure at least one cloud provider for best results"
    }


# ==================== LEGACY COMPATIBILITY ====================
# Keep old endpoint for backward compatibility

@app.post("/api/v1/triage/analyze", response_model=TriageResponse, tags=["Legacy"])
async def legacy_analyze_triage(
    request: TriageRequest,
    graph: TriageGraph = Depends(get_graph)
):
    """
    Legacy endpoint for backward compatibility.
    Redirects to /analyze.
    """
    return await analyze_triage(request, graph)


# ==================== MAIN ====================

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(
        "main:app",
        host="0.0.0.0",
        port=8000,
        reload=True,
        log_level="info"
    )
