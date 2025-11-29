"""
Ollama Integration Node for ClinixAI
====================================
OpenAI-compatible API client for Ollama server.

Benefits for Team Collaboration:
- Easy model management (ollama pull, ollama run)
- Works on Windows/WSL/Mac/Linux
- OpenAI-compatible API
- No cloud costs - fully local
- Supports Qwen, Llama, Mistral, and many more
"""

import os
import json
import asyncio
from typing import Optional, Dict, Any, List
from datetime import datetime

import httpx
from pydantic import BaseModel, Field


class OllamaConfig(BaseModel):
    """Configuration for Ollama server connection"""
    
    # Ollama Server URL
    base_url: str = Field(
        default="http://localhost:11434",
        description="Ollama server base URL"
    )
    
    # Model settings
    model_name: str = Field(
        default="qwen2.5:3b",
        description="Ollama model name (run 'ollama list' to see available)"
    )
    
    # Inference settings
    max_tokens: int = 512
    temperature: float = 0.3
    top_p: float = 0.9
    timeout_seconds: int = 120


class OllamaNode:
    """
    LangGraph node for Ollama inference.
    Uses Ollama's native API and OpenAI-compatible endpoint.
    """
    
    SYSTEM_PROMPT = """You are ClinixAI, an advanced AI medical triage assistant designed for healthcare delivery in Africa.

CRITICAL GUIDELINES:
1. Patient safety is the top priority - when in doubt, recommend seeking professional care
2. Consider Africa-specific endemic diseases: malaria, typhoid, cholera, tuberculosis, HIV/AIDS
3. Account for resource-limited healthcare settings and distance to care
4. Provide clear, actionable guidance in simple language
5. NEVER diagnose - only provide triage assessment and guidance

TRIAGE URGENCY LEVELS:
- CRITICAL: Life-threatening emergency requiring immediate care
- URGENT: Serious condition requiring care within 2-4 hours
- STANDARD: Non-emergency requiring care within 24-48 hours
- NON-URGENT: Minor issues suitable for self-care

Respond ONLY in valid JSON format:
{
  "urgency_level": "critical|urgent|standard|non-urgent",
  "confidence_score": 0.0-1.0,
  "primary_assessment": "Brief clinical assessment",
  "recommended_action": "Specific actionable steps",
  "differential_diagnoses": [{"condition": "Name", "probability": 0.0-1.0, "reasoning": "Why"}],
  "red_flags": ["Warning signs to watch for"],
  "follow_up_questions": ["Questions to ask patient"]
}"""

    def __init__(self, config: Optional[OllamaConfig] = None):
        self.config = config or OllamaConfig(
            base_url=os.getenv("OLLAMA_BASE_URL", "http://localhost:11434"),
            model_name=os.getenv("OLLAMA_MODEL", "qwen2.5:3b"),
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

    def _build_prompt(self, state: Dict[str, Any]) -> str:
        """Build the medical triage prompt"""
        parts = []
        
        if state.get("patient_age"):
            parts.append(f"Patient Age: {state['patient_age']} years")
        if state.get("patient_gender"):
            parts.append(f"Patient Gender: {state['patient_gender']}")
        if state.get("medical_history"):
            parts.append(f"Medical History: {', '.join(state['medical_history'])}")
        
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
        
        parts.append("\nProvide your triage assessment in JSON format.")
        return "\n".join(parts)

    async def infer(
        self, 
        prompt: str, 
        state: Dict[str, Any],
        model: Optional[str] = None
    ) -> Optional[Dict[str, Any]]:
        """
        Perform inference using Ollama server.
        
        Args:
            prompt: Pre-built prompt (optional, we build from state)
            state: Triage state dictionary
            model: Override model name
        """
        user_prompt = self._build_prompt(state)
        model_name = model or self.config.model_name
        
        # Try chat API first (recommended)
        result = await self._chat_completion(user_prompt, model_name)
        
        if result is None:
            # Fallback to generate API
            result = await self._generate(user_prompt, model_name)
        
        return result

    async def _chat_completion(
        self, 
        user_prompt: str,
        model_name: str
    ) -> Optional[Dict[str, Any]]:
        """Use Ollama chat completion API"""
        client = await self._get_client()
        
        try:
            response = await client.post(
                f"{self.config.base_url}/api/chat",
                json={
                    "model": model_name,
                    "messages": [
                        {"role": "system", "content": self.SYSTEM_PROMPT},
                        {"role": "user", "content": user_prompt},
                    ],
                    "stream": False,
                    "options": {
                        "num_predict": self.config.max_tokens,
                        "temperature": self.config.temperature,
                        "top_p": self.config.top_p,
                    },
                },
            )
            
            if response.status_code == 200:
                data = response.json()
                content = data.get("message", {}).get("content", "")
                result = self._extract_json(content)
                
                if result:
                    result["_model_used"] = model_name
                    result["_backend"] = "ollama"
                    result["_eval_count"] = data.get("eval_count", 0)
                    result["_eval_duration_ms"] = data.get("eval_duration", 0) / 1_000_000
                
                return result
            else:
                print(f"Ollama chat error ({response.status_code}): {response.text}")
                return None
                
        except httpx.ConnectError:
            print(f"Cannot connect to Ollama at {self.config.base_url}")
            return None
        except Exception as e:
            print(f"Ollama chat error: {e}")
            return None

    async def _generate(
        self, 
        user_prompt: str,
        model_name: str
    ) -> Optional[Dict[str, Any]]:
        """Use Ollama generate API (fallback)"""
        client = await self._get_client()
        
        full_prompt = f"{self.SYSTEM_PROMPT}\n\n{user_prompt}"
        
        try:
            response = await client.post(
                f"{self.config.base_url}/api/generate",
                json={
                    "model": model_name,
                    "prompt": full_prompt,
                    "stream": False,
                    "options": {
                        "num_predict": self.config.max_tokens,
                        "temperature": self.config.temperature,
                        "top_p": self.config.top_p,
                    },
                },
            )
            
            if response.status_code == 200:
                data = response.json()
                content = data.get("response", "")
                result = self._extract_json(content)
                
                if result:
                    result["_model_used"] = model_name
                    result["_backend"] = "ollama_generate"
                
                return result
            else:
                print(f"Ollama generate error ({response.status_code}): {response.text}")
                return None
                
        except Exception as e:
            print(f"Ollama generate error: {e}")
            return None

    def _extract_json(self, text: str) -> Optional[Dict[str, Any]]:
        """Extract JSON from model output"""
        # Try direct parse
        try:
            return json.loads(text)
        except json.JSONDecodeError:
            pass
        
        # Try to find JSON in text
        try:
            start = text.find('{')
            end = text.rfind('}') + 1
            if start != -1 and end > start:
                return json.loads(text[start:end])
        except json.JSONDecodeError:
            pass
        
        # Try code block
        try:
            if "```json" in text:
                json_str = text.split("```json")[1].split("```")[0]
                return json.loads(json_str)
            elif "```" in text:
                json_str = text.split("```")[1].split("```")[0]
                return json.loads(json_str)
        except (json.JSONDecodeError, IndexError):
            pass
        
        return None

    async def health_check(self) -> Dict[str, Any]:
        """Check Ollama server status"""
        status = {
            "server": "unknown",
            "models": [],
            "version": None,
        }
        
        client = await self._get_client()
        
        try:
            # Check server
            resp = await client.get(f"{self.config.base_url}/api/tags", timeout=10.0)
            if resp.status_code == 200:
                status["server"] = "healthy"
                data = resp.json()
                status["models"] = [m["name"] for m in data.get("models", [])]
            else:
                status["server"] = "error"
        except httpx.ConnectError:
            status["server"] = "offline"
        except Exception as e:
            status["server"] = f"error: {e}"
        
        # Get version
        try:
            resp = await client.get(f"{self.config.base_url}/api/version", timeout=5.0)
            if resp.status_code == 200:
                status["version"] = resp.json().get("version")
        except:
            pass
        
        return status

    async def list_models(self) -> List[str]:
        """List available models on Ollama server"""
        client = await self._get_client()
        
        try:
            resp = await client.get(f"{self.config.base_url}/api/tags", timeout=10.0)
            if resp.status_code == 200:
                data = resp.json()
                return [m["name"] for m in data.get("models", [])]
        except:
            pass
        
        return []

    async def pull_model(self, model_name: str) -> bool:
        """Pull a model from Ollama registry"""
        client = await self._get_client()
        
        try:
            print(f"Pulling model {model_name}... (this may take a while)")
            response = await client.post(
                f"{self.config.base_url}/api/pull",
                json={"name": model_name, "stream": False},
                timeout=httpx.Timeout(600.0),  # 10 min timeout for large models
            )
            return response.status_code == 200
        except Exception as e:
            print(f"Failed to pull model: {e}")
            return False


# ==================== FACTORY ====================

_ollama_node: Optional[OllamaNode] = None


def get_ollama_node() -> OllamaNode:
    """Get or create the Ollama node singleton"""
    global _ollama_node
    if _ollama_node is None:
        _ollama_node = OllamaNode()
    return _ollama_node
