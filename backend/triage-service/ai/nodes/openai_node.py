"""
OpenAI Inference Node for ClinixAI
===================================
Integrates with OpenAI API for high-accuracy medical triage.
Used primarily for critical/complex cases requiring maximum accuracy.

Models Used:
- Primary: gpt-4o (best accuracy)
- Fallback: gpt-4o-mini (faster, cost-effective)
"""

import os
import json
from typing import Optional, Dict, Any
from datetime import datetime

import httpx
from pydantic import BaseModel


class OpenAIConfig(BaseModel):
    """Configuration for OpenAI API"""
    api_key: str = ""
    api_base: str = "https://api.openai.com/v1"
    
    # Model selection
    primary_model: str = "gpt-4o"
    fallback_model: str = "gpt-4o-mini"
    
    # Inference parameters
    max_tokens: int = 800
    temperature: float = 0.2  # Low for medical accuracy
    top_p: float = 0.9
    
    # Timeout settings
    timeout_seconds: int = 60
    
    class Config:
        env_prefix = "OPENAI_"


class OpenAINode:
    """
    LangGraph node for OpenAI inference.
    Provides high-accuracy medical triage analysis.
    """
    
    SYSTEM_PROMPT = """You are ClinixAI, an advanced AI medical triage assistant designed specifically for healthcare delivery in Africa.

CORE RESPONSIBILITIES:
1. Analyze patient symptoms with clinical precision
2. Determine appropriate urgency level for triage
3. Consider Africa-specific conditions (malaria, typhoid, cholera, TB, etc.)
4. Account for resource-limited healthcare settings
5. Provide actionable guidance in clear, simple language

URGENCY LEVELS:
- CRITICAL: Life-threatening, requires immediate emergency care (e.g., chest pain, difficulty breathing, severe bleeding, stroke symptoms)
- URGENT: Serious condition requiring care within 2-4 hours (e.g., high fever >39°C, severe pain, suspected fracture)
- STANDARD: Non-emergency requiring care within 24-48 hours (e.g., persistent symptoms, moderate pain)
- NON-URGENT: Minor issues suitable for self-care or routine appointment (e.g., mild cold, minor aches)

CLINICAL REASONING:
- Consider patient age, gender, and medical history
- Evaluate vital signs if provided
- Identify red flags that require immediate attention
- Generate differential diagnoses with probability estimates

OUTPUT REQUIREMENTS:
Always respond with valid JSON in this exact format:
{
  "urgency_level": "critical|urgent|standard|non-urgent",
  "confidence_score": 0.0-1.0,
  "primary_assessment": "Concise clinical assessment",
  "recommended_action": "Specific, actionable steps for the patient",
  "differential_diagnoses": [
    {
      "condition": "Condition name",
      "probability": 0.0-1.0,
      "icd_code": "ICD-10 code if known",
      "reasoning": "Clinical reasoning for this diagnosis"
    }
  ],
  "red_flags": ["List of warning signs to watch for"],
  "follow_up_questions": ["Questions to better assess the condition"]
}

IMPORTANT: You are a triage tool, NOT a diagnostic system. Always recommend professional medical evaluation for any concerning symptoms."""

    def __init__(self, config: Optional[OpenAIConfig] = None):
        self.config = config or OpenAIConfig(
            api_key=os.getenv("OPENAI_API_KEY", "")
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
        Perform inference using OpenAI API.
        
        Args:
            prompt: The formatted medical prompt
            state: Current LangGraph state
            
        Returns:
            Parsed triage result or None if failed
        """
        if not self.config.api_key or self.config.api_key == "your-openai-key":
            return None
        
        # Try primary model first
        result = await self._call_openai(prompt, self.config.primary_model)
        
        if result:
            return result
        
        # Fallback to secondary model
        return await self._call_openai(prompt, self.config.fallback_model)
    
    async def _call_openai(self, prompt: str, model: str) -> Optional[Dict[str, Any]]:
        """Make API call to OpenAI"""
        try:
            client = await self._get_client()
            
            response = await client.post(
                f"{self.config.api_base}/chat/completions",
                headers={
                    "Authorization": f"Bearer {self.config.api_key}",
                    "Content-Type": "application/json",
                },
                json={
                    "model": model,
                    "messages": [
                        {
                            "role": "system",
                            "content": self.SYSTEM_PROMPT
                        },
                        {
                            "role": "user",
                            "content": prompt
                        }
                    ],
                    "temperature": self.config.temperature,
                    "max_tokens": self.config.max_tokens,
                    "top_p": self.config.top_p,
                    "response_format": {"type": "json_object"},
                },
            )
            
            if response.status_code == 200:
                data = response.json()
                content = data["choices"][0]["message"]["content"]
                return self._parse_response(content)
            
            elif response.status_code == 429:
                # Rate limited
                print(f"OpenAI rate limited for model {model}")
                return None
            
            else:
                print(f"OpenAI API error: {response.status_code} - {response.text}")
                return None
                
        except Exception as e:
            print(f"OpenAI inference error: {e}")
            return None
    
    def _parse_response(self, content: str) -> Optional[Dict[str, Any]]:
        """Parse JSON response from OpenAI"""
        try:
            result = json.loads(content)
            
            # Validate required fields
            required_fields = [
                "urgency_level", 
                "confidence_score", 
                "primary_assessment",
                "recommended_action"
            ]
            
            for field in required_fields:
                if field not in result:
                    result[field] = self._get_default_value(field)
            
            # Ensure differential_diagnoses is a list
            if "differential_diagnoses" not in result:
                result["differential_diagnoses"] = []
            
            # Ensure red_flags is a list
            if "red_flags" not in result:
                result["red_flags"] = []
            
            # Ensure follow_up_questions is a list
            if "follow_up_questions" not in result:
                result["follow_up_questions"] = []
            
            return result
            
        except json.JSONDecodeError as e:
            print(f"Failed to parse OpenAI response: {e}")
            return None
    
    def _get_default_value(self, field: str) -> Any:
        """Get default value for missing field"""
        defaults = {
            "urgency_level": "standard",
            "confidence_score": 0.5,
            "primary_assessment": "Assessment unavailable",
            "recommended_action": "Please consult a healthcare professional",
        }
        return defaults.get(field, None)
    
    async def health_check(self) -> Dict[str, Any]:
        """Check OpenAI API availability"""
        try:
            client = await self._get_client()
            response = await client.get(
                f"{self.config.api_base}/models",
                headers={"Authorization": f"Bearer {self.config.api_key}"},
                timeout=10.0,
            )
            
            return {
                "status": "healthy" if response.status_code == 200 else "degraded",
                "provider": "openai",
                "authenticated": response.status_code == 200,
            }
        except Exception as e:
            return {
                "status": "unhealthy",
                "provider": "openai",
                "error": str(e),
            }


class OpenAIEmbeddingsNode:
    """
    Generate embeddings for symptom similarity matching.
    Uses text-embedding-3-small for efficient embedding generation.
    """
    
    def __init__(self):
        self.config = OpenAIConfig(
            api_key=os.getenv("OPENAI_API_KEY", "")
        )
        self.model = "text-embedding-3-small"
    
    async def embed(self, texts: list[str]) -> list[list[float]]:
        """Generate embeddings for given texts"""
        if not self.config.api_key:
            return []
        
        try:
            async with httpx.AsyncClient() as client:
                response = await client.post(
                    f"{self.config.api_base}/embeddings",
                    headers={
                        "Authorization": f"Bearer {self.config.api_key}",
                        "Content-Type": "application/json",
                    },
                    json={
                        "model": self.model,
                        "input": texts,
                    },
                    timeout=30.0,
                )
                
                if response.status_code == 200:
                    data = response.json()
                    return [d["embedding"] for d in data["data"]]
                return []
        except Exception as e:
            print(f"Embedding error: {e}")
            return []
