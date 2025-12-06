"""
OpenRouter Inference Node for ClinixAI
======================================
Unified cloud API that provides access to multiple LLM providers:
- OpenAI (GPT-4o, GPT-4o-mini)
- Anthropic (Claude 3.5 Sonnet, Claude 3 Opus)
- Meta (Llama 3.1 70B, Llama 3.1 405B)
- Mistral (Mistral Large, Mixtral)
- Google (Gemini Pro)
- And many more...

Benefits:
- Single API key for all providers
- Automatic fallback between models
- Cost tracking and optimization
- No vendor lock-in

Get your API key at: https://openrouter.ai/keys
"""

import os
import json
from typing import Optional, Dict, Any, List
from datetime import datetime

import httpx
from pydantic import BaseModel, Field


class OpenRouterConfig(BaseModel):
    """Configuration for OpenRouter API"""
    api_key: str = ""
    api_base: str = "https://openrouter.ai/api/v1"
    
    # Model selection by use case
    default_model: str = "anthropic/claude-3.5-sonnet"
    critical_model: str = "openai/gpt-4o"
    simple_model: str = "meta-llama/llama-3.1-70b-instruct"
    
    # Site info for tracking
    site_url: str = "https://clinixai.health"
    site_name: str = "ClinixAI"
    
    # Inference parameters
    max_tokens: int = 1024
    temperature: float = 0.2  # Low for medical accuracy
    top_p: float = 0.9
    
    # Timeout settings
    timeout_seconds: int = 90
    
    class Config:
        env_prefix = "OPENROUTER_"


class OpenRouterNode:
    """
    LangGraph node for OpenRouter inference.
    Provides unified access to multiple LLM providers with automatic fallback.
    """
    
    SYSTEM_PROMPT = """You are ClinixAI, an advanced AI medical triage assistant designed specifically for healthcare delivery in Africa.

CORE RESPONSIBILITIES:
1. Analyze patient symptoms with clinical precision
2. Determine appropriate urgency level for triage
3. Consider Africa-specific conditions (malaria, typhoid, cholera, TB, HIV/AIDS, Lassa fever, etc.)
4. Account for resource-limited healthcare settings
5. Provide actionable guidance in clear, simple language

URGENCY LEVELS:
- CRITICAL: Life-threatening, requires immediate emergency care (e.g., chest pain, difficulty breathing, severe bleeding, stroke symptoms, suspected malaria with altered consciousness)
- URGENT: Serious condition requiring care within 2-4 hours (e.g., high fever >39°C, severe pain, suspected fracture, signs of dehydration)
- STANDARD: Non-emergency requiring care within 24-48 hours (e.g., persistent symptoms, moderate pain, suspected uncomplicated malaria)
- NON-URGENT: Minor issues suitable for self-care or routine appointment (e.g., mild cold, minor aches)

CLINICAL REASONING:
- Consider patient age, gender, and medical history
- Evaluate vital signs if provided
- Identify red flags that require immediate attention
- Generate differential diagnoses with probability estimates
- Consider endemic diseases common in the patient's region

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

    # Fallback chain for resilience
    FALLBACK_MODELS = [
        "anthropic/claude-3.5-sonnet",
        "openai/gpt-4o",
        "openai/gpt-4o-mini",
        "meta-llama/llama-3.1-70b-instruct",
        "mistralai/mistral-large",
        "google/gemini-pro-1.5",
    ]

    def __init__(self, config: Optional[OpenRouterConfig] = None):
        self.config = config or OpenRouterConfig(
            api_key=os.getenv("OPENROUTER_API_KEY", ""),
            default_model=os.getenv("OPENROUTER_DEFAULT_MODEL", "anthropic/claude-3.5-sonnet"),
            critical_model=os.getenv("OPENROUTER_CRITICAL_MODEL", "openai/gpt-4o"),
            simple_model=os.getenv("OPENROUTER_SIMPLE_MODEL", "meta-llama/llama-3.1-70b-instruct"),
            site_url=os.getenv("OPENROUTER_SITE_URL", "https://clinixai.health"),
            site_name=os.getenv("OPENROUTER_SITE_NAME", "ClinixAI"),
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

    def _select_model(self, state: Dict[str, Any]) -> str:
        """Select appropriate model based on case complexity"""
        risk_score = state.get("risk_score", 0.5)
        complexity_score = state.get("complexity_score", 0.5)
        
        # Critical cases get the best model
        if risk_score >= 0.8:
            return self.config.critical_model
        
        # Simple cases use cost-effective model
        if risk_score < 0.4 and complexity_score < 0.4:
            return self.config.simple_model
        
        # Default for standard cases
        return self.config.default_model

    def _build_prompt(self, state: Dict[str, Any]) -> str:
        """Build the medical triage prompt from state"""
        parts = []
        
        # Patient demographics
        if state.get("patient_age"):
            parts.append(f"Patient Age: {state['patient_age']} years")
        if state.get("patient_gender"):
            parts.append(f"Patient Gender: {state['patient_gender']}")
        if state.get("medical_history"):
            history = state["medical_history"]
            if isinstance(history, list):
                parts.append(f"Medical History: {', '.join(history)}")
            else:
                parts.append(f"Medical History: {history}")
        
        # Symptoms
        parts.append("\nSymptoms:")
        symptoms = state.get("symptoms", [])
        for i, s in enumerate(symptoms, 1):
            if isinstance(s, dict):
                line = f"  {i}. {s.get('description', 'Unknown')}"
                if s.get("severity"):
                    line += f" (Severity: {s['severity']}/10)"
                if s.get("duration_hours"):
                    line += f" (Duration: {s['duration_hours']} hours)"
                if s.get("body_location"):
                    line += f" (Location: {s['body_location']})"
                parts.append(line)
            else:
                parts.append(f"  {i}. {s}")
        
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
                parts.append(f"  - SpO2: {vitals['oxygen_saturation']}%")
            if vitals.get("respiratory_rate"):
                parts.append(f"  - Respiratory Rate: {vitals['respiratory_rate']}/min")
        
        parts.append("\nProvide your triage assessment in the specified JSON format.")
        return "\n".join(parts)

    async def infer(
        self, 
        prompt: str, 
        state: Dict[str, Any],
        model: Optional[str] = None
    ) -> Optional[Dict[str, Any]]:
        """
        Perform inference using OpenRouter API.
        
        Args:
            prompt: Pre-built prompt (optional, we can build from state)
            state: Current LangGraph state
            model: Override model selection
            
        Returns:
            Parsed triage result or None if failed
        """
        if not self.config.api_key:
            print("OpenRouter API key not configured")
            return None
        
        # Build prompt from state if not provided
        user_prompt = prompt if prompt else self._build_prompt(state)
        
        # Select model based on case complexity
        selected_model = model or self._select_model(state)
        
        # Try selected model first
        result = await self._call_openrouter(user_prompt, selected_model)
        
        if result:
            result["_model_used"] = selected_model
            result["_provider"] = "openrouter"
            return result
        
        # Try fallback models
        for fallback_model in self.FALLBACK_MODELS:
            if fallback_model != selected_model:
                print(f"Trying fallback model: {fallback_model}")
                result = await self._call_openrouter(user_prompt, fallback_model)
                if result:
                    result["_model_used"] = fallback_model
                    result["_provider"] = "openrouter"
                    result["_fallback"] = True
                    return result
        
        return None

    async def _call_openrouter(self, prompt: str, model: str) -> Optional[Dict[str, Any]]:
        """Make API call to OpenRouter"""
        try:
            client = await self._get_client()
            
            headers = {
                "Authorization": f"Bearer {self.config.api_key}",
                "Content-Type": "application/json",
                "HTTP-Referer": self.config.site_url,
                "X-Title": self.config.site_name,
            }
            
            payload = {
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
            }
            
            # Add JSON mode for supported models
            if "gpt-4" in model or "claude" in model:
                payload["response_format"] = {"type": "json_object"}
            
            response = await client.post(
                f"{self.config.api_base}/chat/completions",
                headers=headers,
                json=payload,
            )
            
            if response.status_code == 200:
                data = response.json()
                content = data["choices"][0]["message"]["content"]
                result = self._parse_response(content)
                
                # Add usage info if available
                if result and "usage" in data:
                    result["_tokens"] = {
                        "prompt": data["usage"].get("prompt_tokens", 0),
                        "completion": data["usage"].get("completion_tokens", 0),
                        "total": data["usage"].get("total_tokens", 0),
                    }
                
                return result
            
            elif response.status_code == 429:
                print(f"OpenRouter rate limited for model {model}")
                return None
            
            elif response.status_code == 402:
                print(f"OpenRouter insufficient credits for model {model}")
                return None
            
            else:
                print(f"OpenRouter API error: {response.status_code} - {response.text}")
                return None
                
        except Exception as e:
            print(f"OpenRouter inference error: {e}")
            return None

    def _parse_response(self, content: str) -> Optional[Dict[str, Any]]:
        """Parse JSON response from LLM"""
        # Try direct parse
        try:
            return json.loads(content)
        except json.JSONDecodeError:
            pass
        
        # Try to extract JSON from markdown code block
        try:
            if "```json" in content:
                json_str = content.split("```json")[1].split("```")[0]
                return json.loads(json_str)
            elif "```" in content:
                json_str = content.split("```")[1].split("```")[0]
                return json.loads(json_str)
        except (json.JSONDecodeError, IndexError):
            pass
        
        # Try to find JSON object in text
        try:
            start = content.find('{')
            end = content.rfind('}') + 1
            if start != -1 and end > start:
                return json.loads(content[start:end])
        except json.JSONDecodeError:
            pass
        
        print(f"Failed to parse response: {content[:200]}...")
        return None

    async def health_check(self) -> Dict[str, Any]:
        """Check OpenRouter API availability and credits"""
        if not self.config.api_key:
            return {
                "status": "not_configured",
                "provider": "openrouter",
                "error": "API key not set",
            }
        
        try:
            client = await self._get_client()
            
            # Check API key validity
            response = await client.get(
                f"{self.config.api_base}/auth/key",
                headers={"Authorization": f"Bearer {self.config.api_key}"},
                timeout=10.0,
            )
            
            if response.status_code == 200:
                data = response.json()
                return {
                    "status": "healthy",
                    "provider": "openrouter",
                    "credits": data.get("data", {}).get("limit_remaining"),
                    "models_available": True,
                }
            else:
                return {
                    "status": "degraded",
                    "provider": "openrouter",
                    "error": f"API returned {response.status_code}",
                }
                
        except Exception as e:
            return {
                "status": "unhealthy",
                "provider": "openrouter",
                "error": str(e),
            }

    async def list_models(self) -> List[Dict[str, Any]]:
        """List available models from OpenRouter"""
        try:
            client = await self._get_client()
            
            response = await client.get(
                f"{self.config.api_base}/models",
                headers={"Authorization": f"Bearer {self.config.api_key}"},
                timeout=30.0,
            )
            
            if response.status_code == 200:
                data = response.json()
                return data.get("data", [])
            return []
            
        except Exception as e:
            print(f"Failed to list models: {e}")
            return []


# ==================== CHAT COMPLETION FOR RAG ====================

class OpenRouterChatNode:
    """
    OpenRouter node for general chat/RAG completion.
    Used for the Cactus AI companion and clinical copilot features.
    """
    
    def __init__(self, config: Optional[OpenRouterConfig] = None):
        self.config = config or OpenRouterConfig(
            api_key=os.getenv("OPENROUTER_API_KEY", ""),
        )
        self._client: Optional[httpx.AsyncClient] = None
    
    async def _get_client(self) -> httpx.AsyncClient:
        if self._client is None or self._client.is_closed:
            self._client = httpx.AsyncClient(
                timeout=httpx.Timeout(self.config.timeout_seconds)
            )
        return self._client
    
    async def chat(
        self,
        messages: List[Dict[str, str]],
        system_prompt: Optional[str] = None,
        model: Optional[str] = None,
        max_tokens: int = 1024,
        temperature: float = 0.7,
    ) -> Optional[str]:
        """
        General chat completion for RAG and copilot features.
        
        Args:
            messages: List of {"role": "user|assistant", "content": "..."}
            system_prompt: Optional system prompt override
            model: Model to use (defaults to default_model)
            max_tokens: Maximum response tokens
            temperature: Sampling temperature
            
        Returns:
            Response text or None if failed
        """
        if not self.config.api_key:
            return None
        
        client = await self._get_client()
        
        # Build messages list
        all_messages = []
        if system_prompt:
            all_messages.append({"role": "system", "content": system_prompt})
        all_messages.extend(messages)
        
        try:
            response = await client.post(
                f"{self.config.api_base}/chat/completions",
                headers={
                    "Authorization": f"Bearer {self.config.api_key}",
                    "Content-Type": "application/json",
                    "HTTP-Referer": self.config.site_url,
                    "X-Title": self.config.site_name,
                },
                json={
                    "model": model or self.config.default_model,
                    "messages": all_messages,
                    "max_tokens": max_tokens,
                    "temperature": temperature,
                },
            )
            
            if response.status_code == 200:
                data = response.json()
                return data["choices"][0]["message"]["content"]
            
            return None
            
        except Exception as e:
            print(f"OpenRouter chat error: {e}")
            return None


# ==================== FACTORY FUNCTIONS ====================

_openrouter_node: Optional[OpenRouterNode] = None
_openrouter_chat: Optional[OpenRouterChatNode] = None


def get_openrouter_node() -> OpenRouterNode:
    """Get or create the OpenRouter node singleton"""
    global _openrouter_node
    if _openrouter_node is None:
        _openrouter_node = OpenRouterNode()
    return _openrouter_node


def get_openrouter_chat() -> OpenRouterChatNode:
    """Get or create the OpenRouter chat singleton"""
    global _openrouter_chat
    if _openrouter_chat is None:
        _openrouter_chat = OpenRouterChatNode()
    return _openrouter_chat
