"""
ClinixAI LangGraph Orchestrator
================================
A state-machine based AI inference pipeline for medical triage.
Supports hybrid inference with automatic routing between:
- On-device (Cactus/local LLM)
- Cloud providers (HuggingFace, OpenAI, Anthropic)

Graph Flow:
1. symptom_intake -> 2. risk_assessment -> 3. route_decision
4a. local_inference (low risk) OR 4b. cloud_inference (high risk)
5. result_aggregation -> 6. response_formatting
"""

import os
import json
import asyncio
from datetime import datetime
from typing import TypedDict, Annotated, Literal, Optional, List, Any
from enum import Enum

from langgraph.graph import StateGraph, END
from langgraph.graph.message import add_messages
from langgraph.checkpoint.memory import MemorySaver
from pydantic import BaseModel, Field


# ==================== STATE DEFINITIONS ====================

class UrgencyLevel(str, Enum):
    CRITICAL = "critical"
    URGENT = "urgent"
    STANDARD = "standard"
    NON_URGENT = "non-urgent"


class InferenceProvider(str, Enum):
    LOCAL = "local"
    OLLAMA = "ollama"      # Ollama Docker (Team collaboration - recommended)
    VLLM = "vllm"          # vLLM Docker (GPU required)
    QWEN = "qwen"
    LIQUID_AI = "liquid_ai"
    HUGGINGFACE = "huggingface"
    OPENAI = "openai"
    ANTHROPIC = "anthropic"
    FALLBACK = "fallback"


class SymptomInput(BaseModel):
    """Input symptom from patient"""
    description: str
    severity: Optional[int] = Field(None, ge=1, le=10)
    duration_hours: Optional[int] = None
    body_location: Optional[str] = None


class VitalSignsInput(BaseModel):
    """Patient vital signs"""
    temperature: Optional[float] = None
    heart_rate: Optional[int] = None
    blood_pressure: Optional[str] = None
    oxygen_saturation: Optional[int] = None
    respiratory_rate: Optional[int] = None


class DifferentialDiagnosis(BaseModel):
    """Possible condition with probability"""
    condition: str
    probability: float = Field(ge=0.0, le=1.0)
    icd_code: Optional[str] = None
    reasoning: Optional[str] = None


class TriageResult(BaseModel):
    """Final triage assessment result"""
    urgency_level: UrgencyLevel
    confidence_score: float = Field(ge=0.0, le=1.0)
    primary_assessment: str
    recommended_action: str
    differential_diagnoses: List[DifferentialDiagnosis]
    red_flags: List[str] = []
    follow_up_questions: List[str] = []


class TriageState(TypedDict):
    """
    LangGraph state for the triage pipeline.
    This state flows through all nodes and accumulates information.
    """
    # Input data
    session_id: str
    symptoms: List[dict]
    vital_signs: Optional[dict]
    patient_age: Optional[int]
    patient_gender: Optional[str]
    medical_history: List[str]
    
    # Processing state
    messages: Annotated[list, add_messages]
    risk_score: float
    complexity_score: float
    requires_cloud: bool
    selected_provider: str
    
    # Inference results
    local_result: Optional[dict]
    cloud_result: Optional[dict]
    aggregated_result: Optional[dict]
    
    # Metadata
    inference_start_time: str
    inference_end_time: Optional[str]
    inference_time_ms: int
    provider_used: str
    error: Optional[str]
    
    # Output
    final_response: Optional[dict]


# ==================== NODE IMPLEMENTATIONS ====================

class SymptomIntakeNode:
    """
    Node 1: Intake and normalize symptom data
    Standardizes input and extracts key features for routing
    """
    
    # Keywords that indicate critical symptoms
    CRITICAL_KEYWORDS = [
        "chest pain", "difficulty breathing", "shortness of breath",
        "unconscious", "unresponsive", "severe bleeding", "stroke",
        "seizure", "convulsion", "heart attack", "not breathing",
        "choking", "anaphylaxis", "severe allergic"
    ]
    
    URGENT_KEYWORDS = [
        "high fever", "severe pain", "vomiting blood", "blood in stool",
        "head injury", "broken bone", "fracture", "deep cut",
        "persistent vomiting", "dehydration", "diabetic emergency",
        "severe headache", "vision loss", "paralysis", "numbness"
    ]
    
    AFRICA_SPECIFIC_KEYWORDS = [
        "malaria", "typhoid", "cholera", "yellow fever", "dengue",
        "snake bite", "scorpion sting", "rabies", "tuberculosis",
        "hiv", "aids"
    ]
    
    def __call__(self, state: TriageState) -> dict:
        """Process and normalize symptom input"""
        symptoms = state.get("symptoms", [])
        vital_signs = state.get("vital_signs")
        
        # Extract symptom text
        symptom_text = " ".join([
            s.get("description", "").lower() 
            for s in symptoms
        ])
        
        # Calculate initial risk indicators
        max_severity = max([s.get("severity", 5) for s in symptoms], default=5)
        
        # Check for critical keywords
        critical_found = any(
            kw in symptom_text for kw in self.CRITICAL_KEYWORDS
        )
        urgent_found = any(
            kw in symptom_text for kw in self.URGENT_KEYWORDS
        )
        africa_specific = any(
            kw in symptom_text for kw in self.AFRICA_SPECIFIC_KEYWORDS
        )
        
        # Calculate risk score (0-1)
        risk_score = 0.3  # baseline
        if critical_found:
            risk_score = 0.95
        elif urgent_found:
            risk_score = 0.75
        elif max_severity >= 8:
            risk_score = 0.7
        elif max_severity >= 6:
            risk_score = 0.5
        
        # Adjust for vital signs
        if vital_signs:
            temp = vital_signs.get("temperature")
            hr = vital_signs.get("heart_rate")
            o2 = vital_signs.get("oxygen_saturation")
            
            if temp and temp >= 39.5:  # High fever
                risk_score = max(risk_score, 0.7)
            if hr and (hr > 120 or hr < 50):  # Abnormal heart rate
                risk_score = max(risk_score, 0.75)
            if o2 and o2 < 92:  # Low oxygen
                risk_score = max(risk_score, 0.85)
        
        # Calculate complexity score for routing
        complexity_score = len(symptoms) * 0.1
        if state.get("medical_history"):
            complexity_score += len(state["medical_history"]) * 0.05
        if africa_specific:
            complexity_score += 0.2  # Region-specific conditions need more analysis
        complexity_score = min(complexity_score, 1.0)
        
        return {
            "risk_score": risk_score,
            "complexity_score": complexity_score,
            "inference_start_time": datetime.utcnow().isoformat(),
            "messages": [{
                "role": "system",
                "content": f"Symptom intake complete. Risk: {risk_score:.2f}, Complexity: {complexity_score:.2f}"
            }]
        }


class RiskAssessmentNode:
    """
    Node 2: Assess risk level and determine routing
    Decides whether to use local or cloud inference
    """
    
    # Thresholds for routing decisions
    CLOUD_RISK_THRESHOLD = 0.6
    CLOUD_COMPLEXITY_THRESHOLD = 0.5
    
    def __call__(self, state: TriageState) -> dict:
        """Assess risk and determine inference routing"""
        risk_score = state.get("risk_score", 0.5)
        complexity_score = state.get("complexity_score", 0.3)
        
        # Determine if cloud inference is needed
        requires_cloud = (
            risk_score >= self.CLOUD_RISK_THRESHOLD or
            complexity_score >= self.CLOUD_COMPLEXITY_THRESHOLD
        )
        
        # Select provider based on availability and risk
        if not requires_cloud:
            selected_provider = InferenceProvider.LOCAL.value
        elif risk_score >= 0.8:
            # Critical cases prefer OpenAI for best accuracy
            selected_provider = InferenceProvider.OPENAI.value
        else:
            # Use HuggingFace for cost-effective cloud inference
            selected_provider = InferenceProvider.HUGGINGFACE.value
        
        return {
            "requires_cloud": requires_cloud,
            "selected_provider": selected_provider,
            "messages": [{
                "role": "system", 
                "content": f"Routing decision: {'cloud' if requires_cloud else 'local'} inference via {selected_provider}"
            }]
        }


def route_to_inference(state: TriageState) -> str:
    """
    Conditional edge: Route to appropriate inference node
    """
    if state.get("requires_cloud", False):
        return "cloud_inference"
    return "local_inference"


class LocalInferenceNode:
    """
    Node 4a: Local/On-device inference
    Uses rule-based analysis when cloud is not needed
    Future: Will integrate with Cactus SDK for on-device LLM
    """
    
    def __call__(self, state: TriageState) -> dict:
        """Perform local inference"""
        symptoms = state.get("symptoms", [])
        risk_score = state.get("risk_score", 0.5)
        patient_age = state.get("patient_age")
        
        # Determine urgency based on risk score
        if risk_score >= 0.8:
            urgency = UrgencyLevel.CRITICAL
        elif risk_score >= 0.6:
            urgency = UrgencyLevel.URGENT
        elif risk_score >= 0.4:
            urgency = UrgencyLevel.STANDARD
        else:
            urgency = UrgencyLevel.NON_URGENT
        
        # Build assessment based on symptoms
        symptom_text = ", ".join([s.get("description", "") for s in symptoms])
        
        # Age-specific considerations
        age_note = ""
        if patient_age:
            if patient_age < 5:
                age_note = " Special attention needed for pediatric patient."
            elif patient_age > 65:
                age_note = " Consider age-related complications."
        
        result = {
            "urgency_level": urgency.value,
            "confidence_score": 0.7,  # Lower confidence for local
            "primary_assessment": f"Local analysis of symptoms: {symptom_text}.{age_note}",
            "recommended_action": self._get_action_for_urgency(urgency),
            "differential_diagnoses": [
                {
                    "condition": "Requires clinical evaluation",
                    "probability": 0.8,
                    "reasoning": "Local inference suggests in-person assessment"
                }
            ],
            "red_flags": self._identify_red_flags(symptoms),
            "follow_up_questions": self._generate_follow_ups(symptoms)
        }
        
        return {
            "local_result": result,
            "provider_used": InferenceProvider.LOCAL.value,
            "messages": [{
                "role": "assistant",
                "content": f"Local inference complete: {urgency.value}"
            }]
        }
    
    def _get_action_for_urgency(self, urgency: UrgencyLevel) -> str:
        actions = {
            UrgencyLevel.CRITICAL: "Seek emergency medical care immediately. Call emergency services.",
            UrgencyLevel.URGENT: "Visit a healthcare facility within the next 2-4 hours.",
            UrgencyLevel.STANDARD: "Schedule an appointment within 24-48 hours. Monitor symptoms.",
            UrgencyLevel.NON_URGENT: "Self-care at home. Seek medical advice if symptoms worsen."
        }
        return actions.get(urgency, actions[UrgencyLevel.STANDARD])
    
    def _identify_red_flags(self, symptoms: List[dict]) -> List[str]:
        red_flags = []
        for s in symptoms:
            desc = s.get("description", "").lower()
            severity = s.get("severity", 5)
            
            if "chest" in desc and "pain" in desc:
                red_flags.append("Chest pain - cardiac evaluation recommended")
            if "breath" in desc and severity >= 7:
                red_flags.append("Respiratory distress - monitor oxygen levels")
            if "head" in desc and "injury" in desc:
                red_flags.append("Head trauma - watch for neurological changes")
        
        return red_flags
    
    def _generate_follow_ups(self, symptoms: List[dict]) -> List[str]:
        questions = []
        for s in symptoms:
            desc = s.get("description", "").lower()
            
            if "pain" in desc and not s.get("severity"):
                questions.append("On a scale of 1-10, how would you rate your pain?")
            if "fever" in desc:
                questions.append("Have you measured your temperature? What was the reading?")
            if not s.get("duration_hours"):
                questions.append("How long have you been experiencing these symptoms?")
        
        return questions[:3]  # Limit to 3 questions


class CloudInferenceNode:
    """
    Node 4b: Cloud-based inference
    Orchestrates calls to Ollama, vLLM, Qwen, LiquidAI, HuggingFace, OpenAI, or Anthropic
    Priority: Ollama (team Docker) -> vLLM -> Qwen -> LiquidAI -> HuggingFace -> OpenAI -> Anthropic
    """
    
    def __init__(self):
        from .nodes.huggingface_node import HuggingFaceNode
        from .nodes.openai_node import OpenAINode
        from .nodes.anthropic_node import AnthropicNode
        from .nodes.qwen_liquid_node import QwenLiquidNode
        from .nodes.vllm_node import VLLMNode
        from .nodes.ollama_node import OllamaNode
        
        # Initialize providers
        self.ollama = OllamaNode()
        self.vllm = VLLMNode()
        self.qwen_liquid = QwenLiquidNode()
        
        self.providers = {
            InferenceProvider.OLLAMA.value: self.ollama,
            InferenceProvider.VLLM.value: self.vllm,
            InferenceProvider.QWEN.value: self.qwen_liquid,
            InferenceProvider.LIQUID_AI.value: self.qwen_liquid,
            InferenceProvider.HUGGINGFACE.value: HuggingFaceNode(),
            InferenceProvider.OPENAI.value: OpenAINode(),
            InferenceProvider.ANTHROPIC.value: AnthropicNode(),
        }
    
    async def __call__(self, state: TriageState) -> dict:
        """Perform cloud inference with fallback chain"""
        selected = state.get("selected_provider", InferenceProvider.OLLAMA.value)
        
        # Build the prompt
        prompt = self._build_medical_prompt(state)
        
        # Try selected provider first
        result = None
        provider_used = selected
        
        # Provider fallback chain - Ollama first for team collaboration
        fallback_order = [
            InferenceProvider.OLLAMA.value,
            InferenceProvider.VLLM.value,
            InferenceProvider.QWEN.value,
            InferenceProvider.LIQUID_AI.value,
            InferenceProvider.HUGGINGFACE.value,
            InferenceProvider.OPENAI.value,
            InferenceProvider.ANTHROPIC.value,
        ]
        
        # Put selected provider first
        if selected in fallback_order:
            fallback_order.remove(selected)
            fallback_order.insert(0, selected)
        
        for provider_name in fallback_order:
            provider = self.providers.get(provider_name)
            if provider:
                try:
                    # Special handling for Qwen/Liquid provider
                    if provider_name in [InferenceProvider.QWEN.value, InferenceProvider.LIQUID_AI.value]:
                        model_type = "qwen" if provider_name == InferenceProvider.QWEN.value else "liquid"
                        result = await provider.infer(prompt, state, model_type=model_type)
                    else:
                        result = await provider.infer(prompt, state)
                    
                    if result:
                        provider_used = provider_name
                        break
                except Exception as e:
                    print(f"Provider {provider_name} failed: {e}")
                    continue
        
        if not result:
            # Ultimate fallback
            result = self._create_fallback_result(state)
            provider_used = InferenceProvider.FALLBACK.value
        
        return {
            "cloud_result": result,
            "provider_used": provider_used,
            "messages": [{
                "role": "assistant",
                "content": f"Cloud inference complete via {provider_used}"
            }]
        }
    
    def _build_medical_prompt(self, state: TriageState) -> str:
        """Build a structured medical triage prompt"""
        parts = []
        
        parts.append("You are ClinixAI, an AI medical triage assistant for healthcare in Africa.")
        parts.append("Analyze the following patient information and provide a triage assessment.\n")
        
        # Patient info
        if state.get("patient_age"):
            parts.append(f"Patient Age: {state['patient_age']} years")
        if state.get("patient_gender"):
            parts.append(f"Patient Gender: {state['patient_gender']}")
        if state.get("medical_history"):
            parts.append(f"Medical History: {', '.join(state['medical_history'])}")
        
        # Symptoms
        parts.append("\nSymptoms:")
        for i, s in enumerate(state.get("symptoms", []), 1):
            line = f"  {i}. {s.get('description', 'Unknown')}"
            if s.get("severity"):
                line += f" (Severity: {s['severity']}/10)"
            if s.get("duration_hours"):
                line += f" (Duration: {s['duration_hours']} hours)"
            if s.get("body_location"):
                line += f" (Location: {s['body_location']})"
            parts.append(line)
        
        # Vital signs
        vitals = state.get("vital_signs")
        if vitals:
            parts.append("\nVital Signs:")
            if vitals.get("temperature"):
                parts.append(f"  - Temperature: {vitals['temperature']}°C")
            if vitals.get("heart_rate"):
                parts.append(f"  - Heart Rate: {vitals['heart_rate']} bpm")
            if vitals.get("blood_pressure"):
                parts.append(f"  - Blood Pressure: {vitals['blood_pressure']}")
            if vitals.get("oxygen_saturation"):
                parts.append(f"  - Oxygen Saturation: {vitals['oxygen_saturation']}%")
        
        parts.append("\nProvide your assessment in the following JSON format:")
        parts.append("""{
  "urgency_level": "critical|urgent|standard|non-urgent",
  "confidence_score": 0.0-1.0,
  "primary_assessment": "Brief assessment description",
  "recommended_action": "What the patient should do",
  "differential_diagnoses": [
    {"condition": "Name", "probability": 0.0-1.0, "icd_code": "optional", "reasoning": "why"}
  ],
  "red_flags": ["Warning signs to watch for"],
  "follow_up_questions": ["Questions to ask patient"]
}""")
        
        return "\n".join(parts)
    
    def _create_fallback_result(self, state: TriageState) -> dict:
        """Create fallback result when all providers fail"""
        risk_score = state.get("risk_score", 0.5)
        
        if risk_score >= 0.8:
            urgency = "critical"
            action = "Seek immediate emergency care"
        elif risk_score >= 0.6:
            urgency = "urgent"
            action = "Visit healthcare facility within 2-4 hours"
        else:
            urgency = "standard"
            action = "Schedule appointment within 24-48 hours"
        
        return {
            "urgency_level": urgency,
            "confidence_score": 0.5,
            "primary_assessment": "Cloud AI unavailable. Assessment based on symptom analysis.",
            "recommended_action": action,
            "differential_diagnoses": [
                {"condition": "Requires clinical evaluation", "probability": 1.0}
            ],
            "red_flags": [],
            "follow_up_questions": []
        }


class ResultAggregationNode:
    """
    Node 5: Aggregate results from inference
    Combines local and cloud results if both available
    """
    
    def __call__(self, state: TriageState) -> dict:
        """Aggregate inference results"""
        local_result = state.get("local_result")
        cloud_result = state.get("cloud_result")
        
        # Use cloud result if available (higher confidence)
        if cloud_result:
            aggregated = cloud_result
        elif local_result:
            aggregated = local_result
        else:
            # Should not happen, but handle gracefully
            aggregated = {
                "urgency_level": "standard",
                "confidence_score": 0.3,
                "primary_assessment": "Unable to complete assessment",
                "recommended_action": "Please consult a healthcare professional",
                "differential_diagnoses": [],
                "red_flags": [],
                "follow_up_questions": []
            }
        
        # Calculate final inference time
        start_time = state.get("inference_start_time")
        end_time = datetime.utcnow()
        
        if start_time:
            start_dt = datetime.fromisoformat(start_time)
            inference_time_ms = int((end_time - start_dt).total_seconds() * 1000)
        else:
            inference_time_ms = 0
        
        return {
            "aggregated_result": aggregated,
            "inference_end_time": end_time.isoformat(),
            "inference_time_ms": inference_time_ms,
            "messages": [{
                "role": "system",
                "content": f"Result aggregation complete. Inference time: {inference_time_ms}ms"
            }]
        }


class ResponseFormattingNode:
    """
    Node 6: Format final response
    Ensures consistent output format with disclaimer
    """
    
    DISCLAIMER = (
        "This is an AI-assisted triage assessment and should not replace "
        "professional medical advice. Always consult a qualified healthcare "
        "provider for medical decisions."
    )
    
    def __call__(self, state: TriageState) -> dict:
        """Format the final triage response"""
        result = state.get("aggregated_result", {})
        
        # Ensure all required fields
        final_response = {
            "session_id": state.get("session_id", "unknown"),
            "urgency_level": result.get("urgency_level", "standard"),
            "confidence_score": result.get("confidence_score", 0.5),
            "primary_assessment": result.get("primary_assessment", "Assessment unavailable"),
            "recommended_action": result.get("recommended_action", "Consult healthcare provider"),
            "differential_diagnoses": result.get("differential_diagnoses", []),
            "red_flags": result.get("red_flags", []),
            "follow_up_questions": result.get("follow_up_questions", []),
            "provider_used": state.get("provider_used", "unknown"),
            "inference_time_ms": state.get("inference_time_ms", 0),
            "escalated_to_cloud": state.get("requires_cloud", False),
            "disclaimer": self.DISCLAIMER,
            "timestamp": datetime.utcnow().isoformat(),
        }
        
        return {
            "final_response": final_response,
            "messages": [{
                "role": "assistant",
                "content": "Triage assessment complete"
            }]
        }


# ==================== GRAPH CONSTRUCTION ====================

class TriageGraph:
    """
    Main LangGraph orchestrator for medical triage.
    Builds and manages the state machine graph.
    """
    
    def __init__(self, enable_memory: bool = True):
        self.graph = self._build_graph()
        self.memory = MemorySaver() if enable_memory else None
        self.compiled = self.graph.compile(
            checkpointer=self.memory
        )
    
    def _build_graph(self) -> StateGraph:
        """Build the triage state graph"""
        # Create graph with state schema
        graph = StateGraph(TriageState)
        
        # Add nodes
        graph.add_node("symptom_intake", SymptomIntakeNode())
        graph.add_node("risk_assessment", RiskAssessmentNode())
        graph.add_node("local_inference", LocalInferenceNode())
        graph.add_node("cloud_inference", CloudInferenceNode())
        graph.add_node("result_aggregation", ResultAggregationNode())
        graph.add_node("response_formatting", ResponseFormattingNode())
        
        # Set entry point
        graph.set_entry_point("symptom_intake")
        
        # Add edges
        graph.add_edge("symptom_intake", "risk_assessment")
        
        # Conditional routing based on risk assessment
        graph.add_conditional_edges(
            "risk_assessment",
            route_to_inference,
            {
                "local_inference": "local_inference",
                "cloud_inference": "cloud_inference"
            }
        )
        
        # Both inference paths lead to aggregation
        graph.add_edge("local_inference", "result_aggregation")
        graph.add_edge("cloud_inference", "result_aggregation")
        
        # Final formatting
        graph.add_edge("result_aggregation", "response_formatting")
        graph.add_edge("response_formatting", END)
        
        return graph
    
    async def run(
        self,
        session_id: str,
        symptoms: List[dict],
        vital_signs: Optional[dict] = None,
        patient_age: Optional[int] = None,
        patient_gender: Optional[str] = None,
        medical_history: Optional[List[str]] = None,
    ) -> dict:
        """
        Execute the triage graph with given inputs.
        
        Args:
            session_id: Unique session identifier
            symptoms: List of symptom dictionaries
            vital_signs: Optional vital signs
            patient_age: Optional patient age
            patient_gender: Optional patient gender
            medical_history: Optional list of medical conditions
            
        Returns:
            Final triage response dictionary
        """
        # Initialize state
        initial_state: TriageState = {
            "session_id": session_id,
            "symptoms": symptoms,
            "vital_signs": vital_signs,
            "patient_age": patient_age,
            "patient_gender": patient_gender,
            "medical_history": medical_history or [],
            "messages": [],
            "risk_score": 0.0,
            "complexity_score": 0.0,
            "requires_cloud": False,
            "selected_provider": "",
            "local_result": None,
            "cloud_result": None,
            "aggregated_result": None,
            "inference_start_time": "",
            "inference_end_time": None,
            "inference_time_ms": 0,
            "provider_used": "",
            "error": None,
            "final_response": None,
        }
        
        # Run the graph
        config = {"configurable": {"thread_id": session_id}}
        
        try:
            # Execute graph
            result = await self.compiled.ainvoke(initial_state, config)
            return result.get("final_response", {})
        except Exception as e:
            return {
                "session_id": session_id,
                "urgency_level": "standard",
                "confidence_score": 0.0,
                "primary_assessment": f"Error during assessment: {str(e)}",
                "recommended_action": "Please consult a healthcare professional",
                "error": str(e),
                "timestamp": datetime.utcnow().isoformat(),
            }
    
    def get_graph_visualization(self) -> str:
        """Get Mermaid diagram of the graph"""
        return self.compiled.get_graph().draw_mermaid()


# ==================== FACTORY FUNCTION ====================

_triage_graph_instance: Optional[TriageGraph] = None


def get_triage_graph() -> TriageGraph:
    """Get or create the singleton triage graph instance"""
    global _triage_graph_instance
    if _triage_graph_instance is None:
        _triage_graph_instance = TriageGraph()
    return _triage_graph_instance
