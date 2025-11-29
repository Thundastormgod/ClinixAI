"""
vLLM Integration Node for ClinixAI
==================================
OpenAI-compatible API client for vLLM server.

Benefits for Team Collaboration:
- Single shared model server for all team members
- OpenAI-compatible API (easy to use)
- High throughput with continuous batching
- Supports Qwen, LiquidAI, and other models
- GPU acceleration with memory optimization
"""

import os
import json
import asyncio
from typing import Optional, Dict, Any, List
from datetime import datetime

import httpx
from pydantic import BaseModel, Field


class VLLMConfig(BaseModel):
    """Configuration for vLLM server connection"""
    
    # vLLM Server URLs
    base_url: str = Field(
        default="http://localhost:8090/v1",
        description="vLLM server base URL (OpenAI-compatible)"
    )
    lite_url: str = Field(
        default="http://localhost:8091/v1",
        description="vLLM lite server URL (CPU/low-resource)"
    )
    
    # Authentication
    api_key: str = Field(
        default="clinixai-vllm-key",
        description="vLLM API key"
    )
    
    # Model settings
    model_name: str = Field(
        default="qwen-medical",
        description="Served model name in vLLM"
    )
    lite_model_name: str = Field(
        default="qwen-lite",
        description="Lite model name for CPU inference"
    )
    
    # Inference settings
    max_tokens: int = 512
    temperature: float = 0.3
    top_p: float = 0.9
    timeout_seconds: int = 120
    
    # Fallback behavior
    use_lite_on_failure: bool = True


class VLLMNode:
    """
    LangGraph node for vLLM inference.
    Uses OpenAI-compatible API for easy integration.
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

    def __init__(self, config: Optional[VLLMConfig] = None):
        self.config = config or VLLMConfig(
            base_url=os.getenv("VLLM_BASE_URL", "http://localhost:8090/v1"),
            lite_url=os.getenv("VLLM_LITE_URL", "http://localhost:8091/v1"),
            api_key=os.getenv("VLLM_API_KEY", "clinixai-vllm-key"),
            model_name=os.getenv("VLLM_MODEL_NAME", "qwen-medical"),
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

    def _build_messages(self, state: Dict[str, Any]) -> List[Dict[str, str]]:
        """Build chat messages for vLLM"""
        # System message
        messages = [{"role": "system", "content": self.SYSTEM_PROMPT}]
        
        # Build user message with patient info
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
        
        messages.append({"role": "user", "content": "\n".join(parts)})
        return messages

    async def infer(
        self, 
        prompt: str, 
        state: Dict[str, Any],
        use_lite: bool = False
    ) -> Optional[Dict[str, Any]]:
        """
        Perform inference using vLLM server.
        
        Args:
            prompt: Pre-built prompt (optional, we build from state)
            state: Triage state dictionary
            use_lite: Use lite model for CPU inference
        """
        # Try main server first, then lite if configured
        result = await self._try_inference(state, use_lite=use_lite)
        
        if result is None and self.config.use_lite_on_failure and not use_lite:
            print("Main vLLM server unavailable, trying lite server...")
            result = await self._try_inference(state, use_lite=True)
        
        return result

    async def _try_inference(
        self, 
        state: Dict[str, Any],
        use_lite: bool = False
    ) -> Optional[Dict[str, Any]]:
        """Try inference on a specific vLLM server"""
        base_url = self.config.lite_url if use_lite else self.config.base_url
        model_name = self.config.lite_model_name if use_lite else self.config.model_name
        
        messages = self._build_messages(state)
        client = await self._get_client()
        
        try:
            response = await client.post(
                f"{base_url}/chat/completions",
                headers={
                    "Authorization": f"Bearer {self.config.api_key}",
                    "Content-Type": "application/json",
                },
                json={
                    "model": model_name,
                    "messages": messages,
                    "max_tokens": self.config.max_tokens,
                    "temperature": self.config.temperature,
                    "top_p": self.config.top_p,
                    "stream": False,
                },
            )
            
            if response.status_code == 200:
                data = response.json()
                content = data["choices"][0]["message"]["content"]
                result = self._extract_json(content)
                
                if result:
                    result["_model_used"] = model_name
                    result["_server"] = "lite" if use_lite else "main"
                    result["_usage"] = data.get("usage", {})
                
                return result
            else:
                print(f"vLLM error ({response.status_code}): {response.text}")
                return None
                
        except httpx.ConnectError:
            print(f"Cannot connect to vLLM server at {base_url}")
            return None
        except Exception as e:
            print(f"vLLM inference error: {e}")
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
        """Check vLLM server status"""
        status = {
            "main_server": "unknown",
            "lite_server": "unknown",
            "models": [],
        }
        
        client = await self._get_client()
        
        # Check main server
        try:
            resp = await client.get(
                f"{self.config.base_url}/models",
                headers={"Authorization": f"Bearer {self.config.api_key}"},
                timeout=10.0,
            )
            if resp.status_code == 200:
                status["main_server"] = "healthy"
                data = resp.json()
                status["models"].extend([m["id"] for m in data.get("data", [])])
            else:
                status["main_server"] = "error"
        except httpx.ConnectError:
            status["main_server"] = "offline"
        except Exception as e:
            status["main_server"] = f"error: {e}"
        
        # Check lite server
        try:
            resp = await client.get(
                f"{self.config.lite_url}/models",
                headers={"Authorization": f"Bearer {self.config.api_key}"},
                timeout=10.0,
            )
            if resp.status_code == 200:
                status["lite_server"] = "healthy"
                data = resp.json()
                status["models"].extend([m["id"] for m in data.get("data", [])])
            else:
                status["lite_server"] = "error"
        except httpx.ConnectError:
            status["lite_server"] = "offline"
        except Exception as e:
            status["lite_server"] = f"error: {e}"
        
        return status

    async def list_models(self) -> List[str]:
        """List available models on vLLM server"""
        models = []
        client = await self._get_client()
        
        for url in [self.config.base_url, self.config.lite_url]:
            try:
                resp = await client.get(
                    f"{url}/models",
                    headers={"Authorization": f"Bearer {self.config.api_key}"},
                    timeout=10.0,
                )
                if resp.status_code == 200:
                    data = resp.json()
                    models.extend([m["id"] for m in data.get("data", [])])
            except:
                pass
        
        return list(set(models))


# ==================== FACTORY ====================

_vllm_node: Optional[VLLMNode] = None


def get_vllm_node() -> VLLMNode:
    """Get or create the vLLM node singleton"""
    global _vllm_node
    if _vllm_node is None:
        _vllm_node = VLLMNode()
    return _vllm_node
