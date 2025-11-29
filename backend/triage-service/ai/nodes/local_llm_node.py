"""
Local LLM Inference Node for ClinixAI
======================================
Provides on-device/local LLM inference for offline-first triage.
Supports multiple local inference backends:
- llama.cpp via ctransformers
- GGUF models via llama-cpp-python
- Cactus SDK integration (when available)

Optimized for:
- Offline operation
- Low memory footprint (2GB target)
- Fast inference (<5s target)
"""

import os
import json
import asyncio
from typing import Optional, Dict, Any, List
from pathlib import Path
from datetime import datetime
from enum import Enum

from pydantic import BaseModel, Field


class LocalModelBackend(str, Enum):
    """Supported local inference backends"""
    LLAMA_CPP = "llama_cpp"
    CTRANSFORMERS = "ctransformers"
    CACTUS = "cactus"
    RULE_BASED = "rule_based"


class LocalLLMConfig(BaseModel):
    """Configuration for local LLM inference"""
    # Model settings
    model_path: str = "models/lfm2-1.2b-rag-q4_k_m.gguf"
    backend: LocalModelBackend = LocalModelBackend.RULE_BASED
    
    # Inference parameters
    max_tokens: int = 256
    temperature: float = 0.3
    top_p: float = 0.9
    top_k: int = 40
    repeat_penalty: float = 1.1
    
    # Resource constraints
    context_size: int = 2048
    n_threads: int = 4
    n_gpu_layers: int = 0  # CPU only for compatibility
    
    # Performance targets
    target_inference_time_ms: int = 5000
    
    class Config:
        env_prefix = "LOCAL_LLM_"


class LocalLLMNode:
    """
    LangGraph node for local/on-device LLM inference.
    Provides offline-capable medical triage analysis.
    """
    
    # System prompt optimized for small models
    SYSTEM_PROMPT = """You are a medical triage assistant. Analyze symptoms and respond with JSON:
{"urgency_level":"critical|urgent|standard|non-urgent","confidence":0.0-1.0,"assessment":"brief","action":"what to do","conditions":[{"name":"condition","probability":0.0-1.0}]}"""

    def __init__(self, config: Optional[LocalLLMConfig] = None):
        self.config = config or LocalLLMConfig()
        self._model = None
        self._initialized = False
        
        # Rule-based fallback data
        self._critical_keywords = {
            "chest pain", "difficulty breathing", "can't breathe", 
            "unconscious", "unresponsive", "severe bleeding",
            "stroke", "heart attack", "seizure", "choking",
            "anaphylaxis", "not breathing"
        }
        
        self._urgent_keywords = {
            "high fever", "severe pain", "vomiting blood",
            "head injury", "broken bone", "fracture",
            "severe headache", "vision loss", "paralysis",
            "dehydration", "diabetic", "blood in stool"
        }
        
        self._africa_conditions = {
            "malaria": {
                "keywords": ["fever", "chills", "headache", "muscle pain", "fatigue"],
                "urgency": "urgent",
                "action": "Get tested for malaria immediately. Start antimalarial treatment if positive."
            },
            "typhoid": {
                "keywords": ["fever", "abdominal pain", "headache", "weakness", "loss of appetite"],
                "urgency": "urgent", 
                "action": "Seek medical care for blood test and antibiotic treatment."
            },
            "cholera": {
                "keywords": ["watery diarrhea", "vomiting", "dehydration", "leg cramps"],
                "urgency": "critical",
                "action": "Emergency rehydration needed immediately. Seek care urgently."
            },
            "tuberculosis": {
                "keywords": ["persistent cough", "blood in sputum", "night sweats", "weight loss"],
                "urgency": "urgent",
                "action": "Get tested for TB. Avoid close contact with others until tested."
            }
        }
    
    async def initialize(self) -> bool:
        """Initialize the local model"""
        if self._initialized:
            return True
        
        if self.config.backend == LocalModelBackend.RULE_BASED:
            # Rule-based doesn't need initialization
            self._initialized = True
            return True
        
        # Try to load actual model
        try:
            if self.config.backend == LocalModelBackend.LLAMA_CPP:
                await self._init_llama_cpp()
            elif self.config.backend == LocalModelBackend.CTRANSFORMERS:
                await self._init_ctransformers()
            elif self.config.backend == LocalModelBackend.CACTUS:
                await self._init_cactus()
            
            self._initialized = True
            return True
            
        except Exception as e:
            print(f"Failed to initialize local model: {e}")
            print("Falling back to rule-based analysis")
            self.config.backend = LocalModelBackend.RULE_BASED
            self._initialized = True
            return True
    
    async def _init_llama_cpp(self):
        """Initialize llama-cpp-python backend"""
        try:
            from llama_cpp import Llama
            
            model_path = Path(self.config.model_path)
            if not model_path.exists():
                raise FileNotFoundError(f"Model not found: {model_path}")
            
            self._model = Llama(
                model_path=str(model_path),
                n_ctx=self.config.context_size,
                n_threads=self.config.n_threads,
                n_gpu_layers=self.config.n_gpu_layers,
                verbose=False,
            )
        except ImportError:
            raise ImportError("llama-cpp-python not installed")
    
    async def _init_ctransformers(self):
        """Initialize ctransformers backend"""
        try:
            from ctransformers import AutoModelForCausalLM
            
            model_path = Path(self.config.model_path)
            if not model_path.exists():
                raise FileNotFoundError(f"Model not found: {model_path}")
            
            self._model = AutoModelForCausalLM.from_pretrained(
                str(model_path.parent),
                model_file=model_path.name,
                model_type="llama",
                threads=self.config.n_threads,
                context_length=self.config.context_size,
            )
        except ImportError:
            raise ImportError("ctransformers not installed")
    
    async def _init_cactus(self):
        """Initialize Cactus SDK backend"""
        # Placeholder for Cactus SDK integration
        raise NotImplementedError("Cactus SDK integration pending")
    
    async def infer(self, prompt: str, state: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Perform local inference.
        
        Args:
            prompt: The formatted medical prompt
            state: Current LangGraph state
            
        Returns:
            Triage result dictionary
        """
        if not self._initialized:
            await self.initialize()
        
        start_time = datetime.utcnow()
        
        if self.config.backend == LocalModelBackend.RULE_BASED:
            result = self._rule_based_analysis(state)
        elif self._model is not None:
            result = await self._model_inference(prompt)
        else:
            result = self._rule_based_analysis(state)
        
        # Add timing info
        end_time = datetime.utcnow()
        inference_ms = int((end_time - start_time).total_seconds() * 1000)
        
        if result:
            result["_inference_time_ms"] = inference_ms
            result["_backend"] = self.config.backend.value
        
        return result
    
    async def _model_inference(self, prompt: str) -> Optional[Dict[str, Any]]:
        """Run inference with loaded model"""
        try:
            if self.config.backend == LocalModelBackend.LLAMA_CPP:
                # Run in thread pool to avoid blocking
                loop = asyncio.get_event_loop()
                response = await loop.run_in_executor(
                    None,
                    lambda: self._model(
                        f"{self.SYSTEM_PROMPT}\n\nUser: {prompt}\n\nAssistant:",
                        max_tokens=self.config.max_tokens,
                        temperature=self.config.temperature,
                        top_p=self.config.top_p,
                        top_k=self.config.top_k,
                        repeat_penalty=self.config.repeat_penalty,
                    )
                )
                
                text = response["choices"][0]["text"]
                return self._parse_model_response(text)
            
            elif self.config.backend == LocalModelBackend.CTRANSFORMERS:
                loop = asyncio.get_event_loop()
                text = await loop.run_in_executor(
                    None,
                    lambda: self._model(
                        f"{self.SYSTEM_PROMPT}\n\nUser: {prompt}\n\nAssistant:",
                        max_new_tokens=self.config.max_tokens,
                        temperature=self.config.temperature,
                        top_p=self.config.top_p,
                        top_k=self.config.top_k,
                        repetition_penalty=self.config.repeat_penalty,
                    )
                )
                return self._parse_model_response(text)
            
        except Exception as e:
            print(f"Model inference error: {e}")
            return None
        
        return None
    
    def _parse_model_response(self, text: str) -> Optional[Dict[str, Any]]:
        """Parse JSON from model response"""
        try:
            # Try direct parse
            return json.loads(text)
        except json.JSONDecodeError:
            pass
        
        # Extract JSON from text
        try:
            start = text.find('{')
            end = text.rfind('}') + 1
            if start != -1 and end > start:
                return json.loads(text[start:end])
        except json.JSONDecodeError:
            pass
        
        return None
    
    def _rule_based_analysis(self, state: Dict[str, Any]) -> Dict[str, Any]:
        """
        Perform rule-based symptom analysis.
        Used as fallback when LLM is not available.
        """
        symptoms = state.get("symptoms", [])
        vital_signs = state.get("vital_signs", {})
        patient_age = state.get("patient_age")
        
        # Extract symptom text
        symptom_text = " ".join([
            s.get("description", "").lower() for s in symptoms
        ])
        max_severity = max([s.get("severity", 5) for s in symptoms], default=5)
        
        # Initialize result
        urgency = "standard"
        confidence = 0.7
        assessment = "General symptoms requiring evaluation"
        action = "Schedule a medical appointment within 24-48 hours"
        conditions = []
        red_flags = []
        
        # Check for critical symptoms
        for keyword in self._critical_keywords:
            if keyword in symptom_text:
                urgency = "critical"
                confidence = 0.9
                assessment = f"Critical symptom detected: {keyword}. Immediate emergency care required."
                action = "Call emergency services or go to emergency room immediately."
                red_flags.append(f"Critical: {keyword}")
                conditions.append({
                    "condition": "Requires emergency evaluation",
                    "probability": 0.95,
                    "reasoning": f"Presence of critical symptom: {keyword}"
                })
                break
        
        # Check for urgent symptoms
        if urgency != "critical":
            for keyword in self._urgent_keywords:
                if keyword in symptom_text:
                    urgency = "urgent"
                    confidence = 0.8
                    assessment = f"Urgent symptom detected: {keyword}. Prompt medical attention needed."
                    action = "Visit a healthcare facility within 2-4 hours."
                    red_flags.append(f"Urgent: {keyword}")
                    conditions.append({
                        "condition": "Requires prompt evaluation",
                        "probability": 0.85,
                        "reasoning": f"Presence of urgent symptom: {keyword}"
                    })
                    break
        
        # Check for Africa-specific conditions
        for condition_name, condition_info in self._africa_conditions.items():
            matching_keywords = [
                kw for kw in condition_info["keywords"] 
                if kw in symptom_text
            ]
            if len(matching_keywords) >= 2:
                probability = min(len(matching_keywords) / len(condition_info["keywords"]) + 0.3, 0.9)
                conditions.append({
                    "condition": condition_name.title(),
                    "probability": round(probability, 2),
                    "reasoning": f"Symptoms match: {', '.join(matching_keywords)}"
                })
                
                if condition_info["urgency"] == "critical" and urgency != "critical":
                    urgency = "critical"
                    action = condition_info["action"]
                elif condition_info["urgency"] == "urgent" and urgency == "standard":
                    urgency = "urgent"
                    action = condition_info["action"]
        
        # Adjust for vital signs
        if vital_signs:
            temp = vital_signs.get("temperature")
            hr = vital_signs.get("heart_rate")
            o2 = vital_signs.get("oxygen_saturation")
            
            if temp and temp >= 39.5:
                red_flags.append(f"High fever: {temp}°C")
                if urgency == "standard":
                    urgency = "urgent"
                    action = "High fever detected. Seek medical care promptly."
            
            if hr and (hr > 130 or hr < 45):
                red_flags.append(f"Abnormal heart rate: {hr} bpm")
                urgency = "critical" if hr > 150 or hr < 40 else "urgent"
            
            if o2 and o2 < 92:
                red_flags.append(f"Low oxygen saturation: {o2}%")
                urgency = "critical"
                action = "Low oxygen level. Seek emergency care immediately."
        
        # Adjust for severity and age
        if max_severity >= 8:
            if urgency == "standard":
                urgency = "urgent"
                action = "High symptom severity reported. Visit healthcare facility within 4 hours."
        
        if patient_age:
            if patient_age < 5 or patient_age > 65:
                confidence = max(confidence - 0.1, 0.5)  # Less confident for vulnerable populations
                red_flags.append(f"Age consideration: {'pediatric' if patient_age < 5 else 'elderly'} patient")
        
        # Ensure we have at least one condition
        if not conditions:
            conditions.append({
                "condition": "Requires clinical evaluation",
                "probability": 0.7,
                "reasoning": "Symptoms require in-person assessment"
            })
        
        return {
            "urgency_level": urgency,
            "confidence_score": confidence,
            "primary_assessment": assessment,
            "recommended_action": action,
            "differential_diagnoses": conditions,
            "red_flags": red_flags,
            "follow_up_questions": self._generate_follow_up_questions(symptoms, vital_signs)
        }
    
    def _generate_follow_up_questions(
        self, 
        symptoms: List[Dict], 
        vital_signs: Optional[Dict]
    ) -> List[str]:
        """Generate relevant follow-up questions"""
        questions = []
        
        # Check what info is missing
        has_duration = any(s.get("duration_hours") for s in symptoms)
        has_severity = any(s.get("severity") for s in symptoms)
        
        if not has_duration:
            questions.append("How long have you been experiencing these symptoms?")
        
        if not has_severity:
            questions.append("On a scale of 1-10, how severe are your symptoms?")
        
        if not vital_signs or not vital_signs.get("temperature"):
            questions.append("Have you taken your temperature? What was the reading?")
        
        # Symptom-specific questions
        symptom_text = " ".join([s.get("description", "").lower() for s in symptoms])
        
        if "fever" in symptom_text:
            questions.append("Have you traveled recently or been in contact with anyone sick?")
        
        if "pain" in symptom_text:
            questions.append("Does anything make the pain better or worse?")
        
        if "cough" in symptom_text:
            questions.append("Is the cough dry or are you producing mucus?")
        
        return questions[:4]  # Limit to 4 questions
    
    async def health_check(self) -> Dict[str, Any]:
        """Check local LLM availability"""
        return {
            "status": "healthy",
            "provider": "local",
            "backend": self.config.backend.value,
            "model_loaded": self._model is not None,
            "initialized": self._initialized,
        }
