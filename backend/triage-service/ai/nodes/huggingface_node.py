"""
Hugging Face Inference Node for ClinixAI
=========================================
Integrates with Hugging Face Inference API for cloud-based medical triage.
Supports multiple models optimized for medical/clinical NLP tasks.

Models Used:
- Primary: microsoft/BiomedNLP-PubMedBERT-base-uncased-abstract-fulltext
- Fallback: mistralai/Mistral-7B-Instruct-v0.2
- Text Generation: meta-llama/Llama-2-7b-chat-hf
"""

import os
import json
import asyncio
from typing import Optional, Dict, Any, List
from datetime import datetime

import httpx
from pydantic import BaseModel


class HuggingFaceConfig(BaseModel):
    """Configuration for Hugging Face Inference API"""
    api_key: str = ""
    inference_endpoint: str = "https://api-inference.huggingface.co/models"
    
    # Model selection for different tasks
    text_generation_model: str = "mistralai/Mistral-7B-Instruct-v0.2"
    medical_classification_model: str = "microsoft/BiomedNLP-PubMedBERT-base-uncased-abstract-fulltext"
    
    # Inference parameters
    max_new_tokens: int = 512
    temperature: float = 0.3
    top_p: float = 0.9
    do_sample: bool = True
    
    # Timeout settings
    timeout_seconds: int = 60
    max_retries: int = 2
    
    class Config:
        env_prefix = "HUGGINGFACE_"


class HuggingFaceNode:
    """
    LangGraph node for Hugging Face inference.
    Provides medical triage analysis using HF Inference API.
    """
    
    # Medical triage system prompt
    SYSTEM_PROMPT = """You are ClinixAI, an AI medical triage assistant designed for healthcare in Africa.
Your role is to analyze patient symptoms and provide preliminary triage assessments.

IMPORTANT GUIDELINES:
1. Always err on the side of caution - when in doubt, recommend seeking professional care
2. Consider region-specific conditions common in Africa (malaria, typhoid, cholera, etc.)
3. Account for limited healthcare infrastructure in recommendations
4. Provide clear, actionable advice in simple language
5. Never diagnose - only suggest possible conditions for clinical evaluation

OUTPUT FORMAT (JSON only):
{
  "urgency_level": "critical|urgent|standard|non-urgent",
  "confidence_score": 0.0-1.0,
  "primary_assessment": "Brief assessment description",
  "recommended_action": "Clear action steps for patient",
  "differential_diagnoses": [
    {"condition": "Name", "probability": 0.0-1.0, "icd_code": "if known", "reasoning": "clinical reasoning"}
  ],
  "red_flags": ["Warning signs to monitor"],
  "follow_up_questions": ["Questions to better assess condition"]
}"""

    def __init__(self, config: Optional[HuggingFaceConfig] = None):
        self.config = config or HuggingFaceConfig(
            api_key=os.getenv("HUGGINGFACE_API_KEY", "")
        )
        self._client: Optional[httpx.AsyncClient] = None
    
    async def _get_client(self) -> httpx.AsyncClient:
        """Get or create HTTP client"""
        if self._client is None or self._client.is_closed:
            self._client = httpx.AsyncClient(
                timeout=httpx.Timeout(self.config.timeout_seconds)
            )
        return self._client
    
    async def close(self):
        """Close the HTTP client"""
        if self._client and not self._client.is_closed:
            await self._client.aclose()
    
    async def infer(self, prompt: str, state: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Perform inference using Hugging Face API.
        
        Args:
            prompt: The formatted medical prompt
            state: Current LangGraph state
            
        Returns:
            Parsed triage result or None if failed
        """
        if not self.config.api_key:
            print("HuggingFace API key not configured")
            return None
        
        # Try text generation model first
        result = await self._generate_with_instruct_model(prompt)
        
        if result:
            return result
        
        # Fallback to classification-based approach
        return await self._classify_symptoms(state)
    
    async def _generate_with_instruct_model(self, prompt: str) -> Optional[Dict[str, Any]]:
        """Generate response using instruction-tuned model"""
        try:
            client = await self._get_client()
            
            # Format prompt for instruction model
            full_prompt = f"""<s>[INST] {self.SYSTEM_PROMPT}

{prompt} [/INST]"""
            
            url = f"{self.config.inference_endpoint}/{self.config.text_generation_model}"
            
            response = await client.post(
                url,
                headers={
                    "Authorization": f"Bearer {self.config.api_key}",
                    "Content-Type": "application/json",
                },
                json={
                    "inputs": full_prompt,
                    "parameters": {
                        "max_new_tokens": self.config.max_new_tokens,
                        "temperature": self.config.temperature,
                        "top_p": self.config.top_p,
                        "do_sample": self.config.do_sample,
                        "return_full_text": False,
                    },
                    "options": {
                        "wait_for_model": True,
                    }
                },
            )
            
            if response.status_code == 200:
                data = response.json()
                
                # Extract generated text
                if isinstance(data, list) and len(data) > 0:
                    generated_text = data[0].get("generated_text", "")
                else:
                    generated_text = data.get("generated_text", "")
                
                # Parse JSON from response
                return self._parse_json_response(generated_text)
            
            elif response.status_code == 503:
                # Model is loading
                print("HuggingFace model is loading, waiting...")
                await asyncio.sleep(20)
                return await self._generate_with_instruct_model(prompt)
            
            else:
                print(f"HuggingFace API error: {response.status_code} - {response.text}")
                return None
                
        except Exception as e:
            print(f"HuggingFace inference error: {e}")
            return None
    
    async def _classify_symptoms(self, state: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """
        Fallback classification-based analysis using PubMedBERT.
        Classifies symptoms into urgency categories.
        """
        try:
            client = await self._get_client()
            
            # Extract symptom text
            symptoms = state.get("symptoms", [])
            symptom_text = ". ".join([
                s.get("description", "") for s in symptoms
            ])
            
            if not symptom_text:
                return None
            
            # Use zero-shot classification
            url = f"{self.config.inference_endpoint}/facebook/bart-large-mnli"
            
            response = await client.post(
                url,
                headers={
                    "Authorization": f"Bearer {self.config.api_key}",
                    "Content-Type": "application/json",
                },
                json={
                    "inputs": symptom_text,
                    "parameters": {
                        "candidate_labels": [
                            "life-threatening emergency requiring immediate care",
                            "urgent condition requiring prompt medical attention",
                            "moderate condition requiring scheduled care",
                            "minor condition suitable for self-care"
                        ],
                    },
                    "options": {
                        "wait_for_model": True,
                    }
                },
            )
            
            if response.status_code == 200:
                data = response.json()
                return self._convert_classification_to_triage(data, state)
            
            return None
            
        except Exception as e:
            print(f"Classification error: {e}")
            return None
    
    def _parse_json_response(self, text: str) -> Optional[Dict[str, Any]]:
        """Parse JSON from model response"""
        try:
            # Try direct parsing
            return json.loads(text)
        except json.JSONDecodeError:
            pass
        
        # Try to extract JSON from text
        try:
            # Find JSON block
            start_idx = text.find('{')
            end_idx = text.rfind('}') + 1
            
            if start_idx != -1 and end_idx > start_idx:
                json_str = text[start_idx:end_idx]
                return json.loads(json_str)
        except json.JSONDecodeError:
            pass
        
        # Try to extract from code block
        try:
            if "```json" in text:
                json_str = text.split("```json")[1].split("```")[0]
                return json.loads(json_str)
            elif "```" in text:
                json_str = text.split("```")[1].split("```")[0]
                return json.loads(json_str)
        except (json.JSONDecodeError, IndexError):
            pass
        
        print(f"Could not parse JSON from response: {text[:200]}...")
        return None
    
    def _convert_classification_to_triage(
        self, 
        classification: Dict[str, Any],
        state: Dict[str, Any]
    ) -> Dict[str, Any]:
        """Convert zero-shot classification to triage format"""
        labels = classification.get("labels", [])
        scores = classification.get("scores", [])
        
        if not labels or not scores:
            return None
        
        # Map classification to urgency level
        top_label = labels[0]
        top_score = scores[0]
        
        urgency_map = {
            "life-threatening emergency requiring immediate care": "critical",
            "urgent condition requiring prompt medical attention": "urgent",
            "moderate condition requiring scheduled care": "standard",
            "minor condition suitable for self-care": "non-urgent",
        }
        
        urgency = urgency_map.get(top_label, "standard")
        
        action_map = {
            "critical": "Seek emergency medical care immediately. Call emergency services if available.",
            "urgent": "Visit a healthcare facility within the next 2-4 hours.",
            "standard": "Schedule an appointment within 24-48 hours. Monitor symptoms.",
            "non-urgent": "Self-care at home is appropriate. Seek care if symptoms worsen.",
        }
        
        return {
            "urgency_level": urgency,
            "confidence_score": round(top_score, 2),
            "primary_assessment": f"Based on symptom analysis, this appears to be a {urgency} case.",
            "recommended_action": action_map[urgency],
            "differential_diagnoses": [
                {
                    "condition": "Requires clinical evaluation",
                    "probability": top_score,
                    "reasoning": "Classification-based assessment"
                }
            ],
            "red_flags": [],
            "follow_up_questions": [
                "How long have you had these symptoms?",
                "Have the symptoms gotten worse recently?",
                "Are you currently taking any medications?"
            ],
        }
    
    async def health_check(self) -> Dict[str, Any]:
        """Check HuggingFace API availability"""
        try:
            client = await self._get_client()
            response = await client.get(
                "https://huggingface.co/api/whoami",
                headers={"Authorization": f"Bearer {self.config.api_key}"},
                timeout=10.0,
            )
            
            return {
                "status": "healthy" if response.status_code == 200 else "degraded",
                "provider": "huggingface",
                "authenticated": response.status_code == 200,
            }
        except Exception as e:
            return {
                "status": "unhealthy",
                "provider": "huggingface",
                "error": str(e),
            }


# ==================== SPECIALIZED MEDICAL MODELS ====================

class MedicalNERNode:
    """
    Named Entity Recognition for medical terms.
    Uses BioBERT or PubMedBERT for extracting medical entities.
    """
    
    def __init__(self):
        self.config = HuggingFaceConfig(
            api_key=os.getenv("HUGGINGFACE_API_KEY", "")
        )
        self.model = "d4data/biomedical-ner-all"
    
    async def extract_entities(self, text: str) -> List[Dict[str, Any]]:
        """Extract medical entities from text"""
        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"https://api-inference.huggingface.co/models/{self.model}",
                    headers={
                        "Authorization": f"Bearer {self.config.api_key}",
                        "Content-Type": "application/json",
                    },
                    json={"inputs": text},
                    timeout=30.0,
                )
                
                if response.status_code == 200:
                    return response.json()
                return []
        except Exception as e:
            print(f"NER extraction error: {e}")
            return []


class SymptomSimilarityNode:
    """
    Semantic similarity for symptom matching.
    Matches patient symptoms to known conditions.
    """
    
    def __init__(self):
        self.config = HuggingFaceConfig(
            api_key=os.getenv("HUGGINGFACE_API_KEY", "")
        )
        self.model = "sentence-transformers/all-MiniLM-L6-v2"
    
    async def find_similar_conditions(
        self, 
        symptoms: str, 
        conditions: List[str]
    ) -> List[Dict[str, float]]:
        """Find conditions most similar to given symptoms"""
        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"https://api-inference.huggingface.co/models/{self.model}",
                    headers={
                        "Authorization": f"Bearer {self.config.api_key}",
                        "Content-Type": "application/json",
                    },
                    json={
                        "inputs": {
                            "source_sentence": symptoms,
                            "sentences": conditions,
                        }
                    },
                    timeout=30.0,
                )
                
                if response.status_code == 200:
                    scores = response.json()
                    return [
                        {"condition": c, "similarity": s}
                        for c, s in zip(conditions, scores)
                    ]
                return []
        except Exception as e:
            print(f"Similarity search error: {e}")
            return []
