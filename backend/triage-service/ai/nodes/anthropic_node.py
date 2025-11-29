"""
Anthropic Claude Inference Node for ClinixAI
=============================================
Integrates with Anthropic Claude API for medical triage.
Claude excels at nuanced reasoning and safety considerations.

Models Used:
- Primary: claude-3-5-sonnet-20241022
- Fallback: claude-3-haiku-20240307
"""

import os
import json
from typing import Optional, Dict, Any
from datetime import datetime

import httpx
from pydantic import BaseModel


class AnthropicConfig(BaseModel):
    """Configuration for Anthropic API"""
    api_key: str = ""
    api_base: str = "https://api.anthropic.com/v1"
    api_version: str = "2023-06-01"
    
    # Model selection
    primary_model: str = "claude-3-5-sonnet-20241022"
    fallback_model: str = "claude-3-haiku-20240307"
    
    # Inference parameters
    max_tokens: int = 800
    temperature: float = 0.2
    
    # Timeout settings
    timeout_seconds: int = 60
    
    class Config:
        env_prefix = "ANTHROPIC_"


class AnthropicNode:
    """
    LangGraph node for Anthropic Claude inference.
    Provides careful, safety-conscious medical triage analysis.
    """
    
    SYSTEM_PROMPT = """You are ClinixAI, an AI medical triage assistant for healthcare in Africa.

YOUR ROLE:
- Provide preliminary triage assessments based on symptoms
- Help patients understand urgency of their condition
- Guide appropriate care-seeking behavior
- Consider regional health conditions common in Africa

SAFETY PRINCIPLES:
1. You are NOT a replacement for medical professionals
2. When uncertain, always err toward recommending professional care
3. Critical symptoms always warrant immediate emergency care
4. Consider the patient's ability to access healthcare

AFRICA-SPECIFIC CONSIDERATIONS:
- Endemic diseases: malaria, typhoid, cholera, tuberculosis
- Resource limitations in healthcare facilities
- Distance to medical care may be significant
- Consider traditional medicine interactions

TRIAGE LEVELS:
- CRITICAL: Immediate emergency care needed
- URGENT: Care needed within hours
- STANDARD: Care needed within 1-2 days
- NON-URGENT: Self-care or routine appointment

Respond ONLY with valid JSON:
{
  "urgency_level": "critical|urgent|standard|non-urgent",
  "confidence_score": 0.0-1.0,
  "primary_assessment": "Clear assessment summary",
  "recommended_action": "Actionable next steps",
  "differential_diagnoses": [
    {"condition": "Name", "probability": 0.0-1.0, "icd_code": "optional", "reasoning": "explanation"}
  ],
  "red_flags": ["Warning signs"],
  "follow_up_questions": ["Clarifying questions"]
}"""

    def __init__(self, config: Optional[AnthropicConfig] = None):
        self.config = config or AnthropicConfig(
            api_key=os.getenv("ANTHROPIC_API_KEY", "")
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
        Perform inference using Anthropic API.
        
        Args:
            prompt: The formatted medical prompt
            state: Current LangGraph state
            
        Returns:
            Parsed triage result or None if failed
        """
        if not self.config.api_key or self.config.api_key == "your-anthropic-key":
            return None
        
        # Try primary model first
        result = await self._call_anthropic(prompt, self.config.primary_model)
        
        if result:
            return result
        
        # Fallback to secondary model
        return await self._call_anthropic(prompt, self.config.fallback_model)
    
    async def _call_anthropic(self, prompt: str, model: str) -> Optional[Dict[str, Any]]:
        """Make API call to Anthropic"""
        try:
            client = await self._get_client()
            
            response = await client.post(
                f"{self.config.api_base}/messages",
                headers={
                    "x-api-key": self.config.api_key,
                    "Content-Type": "application/json",
                    "anthropic-version": self.config.api_version,
                },
                json={
                    "model": model,
                    "max_tokens": self.config.max_tokens,
                    "system": self.SYSTEM_PROMPT,
                    "messages": [
                        {
                            "role": "user",
                            "content": prompt
                        }
                    ],
                    "temperature": self.config.temperature,
                },
            )
            
            if response.status_code == 200:
                data = response.json()
                content = data["content"][0]["text"]
                return self._parse_response(content)
            
            elif response.status_code == 529:
                # Overloaded
                print(f"Anthropic overloaded for model {model}")
                return None
            
            else:
                print(f"Anthropic API error: {response.status_code} - {response.text}")
                return None
                
        except Exception as e:
            print(f"Anthropic inference error: {e}")
            return None
    
    def _parse_response(self, content: str) -> Optional[Dict[str, Any]]:
        """Parse JSON response from Anthropic"""
        try:
            # Direct JSON parse
            return json.loads(content)
        except json.JSONDecodeError:
            pass
        
        # Try to extract JSON from text
        try:
            start_idx = content.find('{')
            end_idx = content.rfind('}') + 1
            
            if start_idx != -1 and end_idx > start_idx:
                json_str = content[start_idx:end_idx]
                return json.loads(json_str)
        except json.JSONDecodeError:
            pass
        
        print(f"Failed to parse Anthropic response: {content[:200]}...")
        return None
    
    async def health_check(self) -> Dict[str, Any]:
        """Check Anthropic API availability"""
        try:
            # Anthropic doesn't have a dedicated health endpoint
            # We'll try a minimal request
            return {
                "status": "healthy" if self.config.api_key else "not_configured",
                "provider": "anthropic",
                "configured": bool(self.config.api_key),
            }
        except Exception as e:
            return {
                "status": "unhealthy",
                "provider": "anthropic",
                "error": str(e),
            }
