"""
Qwen and LiquidAI Model Integration for ClinixAI
=================================================
Custom HuggingFace Inference Endpoints for medical triage.

Supported Models:
- Qwen/Qwen2.5-72B-Instruct (or custom fine-tuned)
- LiquidAI/LFM-1B (Liquid Foundation Model)
- LiquidAI/LFM2-1.2B-RAG (RAG-optimized)

These models are optimized for:
- Medical reasoning
- Low-latency inference
- Multilingual support (important for Africa)
"""

import os
import json
import asyncio
from typing import Optional, Dict, Any, List
from datetime import datetime
from enum import Enum

import httpx
from pydantic import BaseModel, Field


class ModelProvider(str, Enum):
    """Available model providers"""
    QWEN = "qwen"
    LIQUID_AI = "liquid_ai"
    CUSTOM = "custom"


class HuggingFaceEndpointConfig(BaseModel):
    """Configuration for a HuggingFace Inference Endpoint"""
    name: str
    endpoint_url: str
    api_key: Optional[str] = None
    model_type: str = "text-generation"
    max_tokens: int = 512
    temperature: float = 0.3
    is_chat_model: bool = True
    supports_system_prompt: bool = True


class QwenLiquidConfig(BaseModel):
    """Configuration for Qwen and LiquidAI models"""
    
    # HuggingFace API Token (for Inference API)
    hf_api_token: str = Field(default="")
    
    # NEW: HuggingFace Endpoints Router (endpoints.huggingface.co)
    # Qwen Model Configuration
    qwen_endpoint: str = Field(
        default="https://api-inference.huggingface.co/models/Qwen/Qwen2.5-3B-Instruct",
        description="Qwen model endpoint URL (legacy API)"
    )
    qwen_chat_endpoint: str = Field(
        default="https://router.huggingface.co/hf-inference/models/Qwen/Qwen2.5-3B-Instruct/v1/chat/completions",
        description="Qwen chat completions endpoint (new router)"
    )
    qwen_model_id: str = "Qwen/Qwen2.5-3B-Instruct"
    
    # LiquidAI Model Configuration  
    liquid_endpoint: str = Field(
        default="https://api-inference.huggingface.co/models/LiquidAI/LFM2-1.2B-Instruct",
        description="LiquidAI model endpoint URL (legacy API)"
    )
    liquid_chat_endpoint: str = Field(
        default="https://router.huggingface.co/hf-inference/models/microsoft/Phi-3-mini-4k-instruct/v1/chat/completions",
        description="Alternative chat endpoint (Phi-3 as LiquidAI alternative)"
    )
    liquid_model_id: str = "microsoft/Phi-3-mini-4k-instruct"
    
    # Custom Inference Endpoints (user-provided from endpoints.huggingface.co)
    custom_endpoints: Dict[str, HuggingFaceEndpointConfig] = Field(default_factory=dict)
    
    # Inference Settings
    default_max_tokens: int = 512
    default_temperature: float = 0.3
    timeout_seconds: int = 120  # Longer timeout for large models
    
    # Use new chat completions API
    use_chat_api: bool = True
    
    # Fallback chain order
    model_priority: List[str] = Field(
        default=["qwen", "liquid_ai", "fallback"],
        description="Order to try models"
    )

    class Config:
        env_prefix = "CLINIXAI_"


class QwenLiquidNode:
    """
    LangGraph node for Qwen and LiquidAI inference.
    Supports both public HuggingFace Inference API and custom endpoints.
    """
    
    # Medical triage system prompt optimized for Qwen/Liquid models
    SYSTEM_PROMPT = """You are ClinixAI, an advanced AI medical triage assistant designed for healthcare delivery in Africa.

CRITICAL GUIDELINES:
1. Patient safety is the top priority - when in doubt, recommend seeking professional care
2. Consider Africa-specific endemic diseases: malaria, typhoid, cholera, tuberculosis, HIV/AIDS
3. Account for resource-limited healthcare settings and distance to care
4. Provide clear, actionable guidance in simple language
5. NEVER diagnose - only provide triage assessment and guidance

TRIAGE URGENCY LEVELS:
- CRITICAL: Life-threatening, requires immediate emergency care (chest pain, difficulty breathing, severe bleeding, stroke, seizure)
- URGENT: Serious condition requiring care within 2-4 hours (high fever >39°C, severe pain, suspected fracture, dehydration)
- STANDARD: Non-emergency requiring care within 24-48 hours (persistent symptoms, moderate pain)
- NON-URGENT: Minor issues suitable for self-care or routine appointment

You MUST respond in valid JSON format:
{
  "urgency_level": "critical|urgent|standard|non-urgent",
  "confidence_score": 0.0-1.0,
  "primary_assessment": "Concise clinical assessment",
  "recommended_action": "Specific, actionable steps for the patient",
  "differential_diagnoses": [
    {"condition": "Condition name", "probability": 0.0-1.0, "reasoning": "Clinical reasoning"}
  ],
  "red_flags": ["Warning signs to watch for"],
  "follow_up_questions": ["Questions to better assess condition"]
}"""

    QWEN_CHAT_TEMPLATE = """<|im_start|>system
{system_prompt}<|im_end|>
<|im_start|>user
{user_prompt}<|im_end|>
<|im_start|>assistant
"""

    LIQUID_CHAT_TEMPLATE = """<|system|>
{system_prompt}
<|user|>
{user_prompt}
<|assistant|>
"""

    def __init__(self, config: Optional[QwenLiquidConfig] = None):
        self.config = config or QwenLiquidConfig(
            hf_api_token=os.getenv("HUGGINGFACE_API_KEY", "")
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

    def _build_prompt(self, state: Dict[str, Any], model_type: str = "qwen") -> str:
        """Build the medical triage prompt"""
        parts = []
        
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
                parts.append(f"  - SpO2: {vitals['oxygen_saturation']}%")
        
        user_prompt = "\n".join(parts)
        user_prompt += "\n\nProvide your triage assessment in JSON format."
        
        # Apply chat template based on model
        if model_type == "qwen":
            return self.QWEN_CHAT_TEMPLATE.format(
                system_prompt=self.SYSTEM_PROMPT,
                user_prompt=user_prompt
            )
        else:  # liquid or other
            return self.LIQUID_CHAT_TEMPLATE.format(
                system_prompt=self.SYSTEM_PROMPT,
                user_prompt=user_prompt
            )

    async def infer(
        self, 
        prompt: str, 
        state: Dict[str, Any],
        model_type: str = "auto"
    ) -> Optional[Dict[str, Any]]:
        """
        Perform inference using configured model priority.
        Tries models in order until one succeeds.
        
        Args:
            prompt: The pre-built prompt (used if model doesn't need rebuilding)
            state: The triage state dictionary
            model_type: "qwen", "liquid", or "auto" (uses priority list)
        """
        # If specific model requested, try that first
        if model_type == "qwen":
            result = await self._infer_qwen(state)
            if result:
                result["_model_used"] = "qwen"
                return result
        elif model_type == "liquid":
            result = await self._infer_liquid(state)
            if result:
                result["_model_used"] = "liquid_ai"
                return result
        
        # Auto mode: try all models in priority order
        for model_name in self.config.model_priority:
            if model_name == "fallback":
                continue
                
            result = await self._try_model(model_name, state)
            if result:
                result["_model_used"] = model_name
                return result
        
        return None

    async def _try_model(self, model_name: str, state: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Try inference with a specific model"""
        try:
            if model_name == "qwen":
                return await self._infer_qwen(state)
            elif model_name == "liquid_ai":
                return await self._infer_liquid(state)
            elif model_name in self.config.custom_endpoints:
                endpoint = self.config.custom_endpoints[model_name]
                return await self._infer_custom(state, endpoint)
        except Exception as e:
            print(f"Model {model_name} failed: {e}")
        return None

    async def _infer_qwen(self, state: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Inference using Qwen model via HuggingFace chat completions API"""
        if not self.config.hf_api_token:
            print("No HuggingFace API token configured")
            return None
        
        client = await self._get_client()
        
        # Build user message content
        user_content = self._build_user_message(state)
        
        try:
            # Use new chat completions API (OpenAI-compatible)
            if self.config.use_chat_api:
                response = await client.post(
                    self.config.qwen_chat_endpoint,
                    headers={
                        "Authorization": f"Bearer {self.config.hf_api_token}",
                        "Content-Type": "application/json",
                    },
                    json={
                        "model": self.config.qwen_model_id,
                        "messages": [
                            {"role": "system", "content": self.SYSTEM_PROMPT},
                            {"role": "user", "content": user_content},
                        ],
                        "max_tokens": self.config.default_max_tokens,
                        "temperature": self.config.default_temperature,
                        "top_p": 0.9,
                        "stream": False,
                    },
                )
            else:
                # Legacy API fallback
                prompt = self._build_prompt(state, "qwen")
                response = await client.post(
                    self.config.qwen_endpoint,
                    headers={
                        "Authorization": f"Bearer {self.config.hf_api_token}",
                        "Content-Type": "application/json",
                    },
                    json={
                        "inputs": prompt,
                        "parameters": {
                            "max_new_tokens": self.config.default_max_tokens,
                            "temperature": self.config.default_temperature,
                            "top_p": 0.9,
                            "do_sample": True,
                            "return_full_text": False,
                        },
                        "options": {"wait_for_model": True},
                    },
                )
            
            if response.status_code == 200:
                data = response.json()
                # Parse chat completions format
                if "choices" in data:
                    content = data["choices"][0]["message"]["content"]
                    return self._extract_json(content)
                else:
                    return self._parse_response(data)
            elif response.status_code == 503:
                print("Qwen model is loading...")
                await asyncio.sleep(20)
                return await self._infer_qwen(state)
            else:
                print(f"Qwen API error ({response.status_code}): {response.text[:200]}")
                return None
                
        except Exception as e:
            print(f"Qwen inference error: {e}")
            return None
    
    def _build_user_message(self, state: Dict[str, Any]) -> str:
        """Build user message for chat completions"""
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

    async def _infer_liquid(self, state: Dict[str, Any]) -> Optional[Dict[str, Any]]:
        """Inference using LiquidAI/alternative model via chat completions API"""
        if not self.config.hf_api_token:
            print("No HuggingFace API token configured")
            return None
        
        client = await self._get_client()
        user_content = self._build_user_message(state)
        
        try:
            # Use new chat completions API
            if self.config.use_chat_api:
                response = await client.post(
                    self.config.liquid_chat_endpoint,
                    headers={
                        "Authorization": f"Bearer {self.config.hf_api_token}",
                        "Content-Type": "application/json",
                    },
                    json={
                        "model": self.config.liquid_model_id,
                        "messages": [
                            {"role": "system", "content": self.SYSTEM_PROMPT},
                            {"role": "user", "content": user_content},
                        ],
                        "max_tokens": self.config.default_max_tokens,
                        "temperature": self.config.default_temperature,
                        "top_p": 0.9,
                        "stream": False,
                    },
                )
            else:
                # Legacy API fallback
                prompt = self._build_prompt(state, "liquid")
                response = await client.post(
                    self.config.liquid_endpoint,
                    headers={
                        "Authorization": f"Bearer {self.config.hf_api_token}",
                        "Content-Type": "application/json",
                    },
                    json={
                        "inputs": prompt,
                        "parameters": {
                            "max_new_tokens": self.config.default_max_tokens,
                            "temperature": self.config.default_temperature,
                            "top_p": 0.9,
                            "do_sample": True,
                            "return_full_text": False,
                        },
                        "options": {"wait_for_model": True},
                    },
                )
            
            if response.status_code == 200:
                data = response.json()
                if "choices" in data:
                    content = data["choices"][0]["message"]["content"]
                    return self._extract_json(content)
                else:
                    return self._parse_response(data)
            elif response.status_code == 503:
                print("Model is loading...")
                await asyncio.sleep(20)
                return await self._infer_liquid(state)
            else:
                print(f"LiquidAI API error ({response.status_code}): {response.text[:200]}")
                return None
                return None
                
        except Exception as e:
            print(f"LiquidAI inference error: {e}")
            return None

    async def _infer_custom(
        self, 
        state: Dict[str, Any], 
        endpoint: HuggingFaceEndpointConfig
    ) -> Optional[Dict[str, Any]]:
        """Inference using custom endpoint"""
        api_key = endpoint.api_key or self.config.hf_api_token
        if not api_key:
            return None
        
        prompt = self._build_prompt(state, "liquid")  # Use generic template
        client = await self._get_client()
        
        try:
            response = await client.post(
                endpoint.endpoint_url,
                headers={
                    "Authorization": f"Bearer {api_key}",
                    "Content-Type": "application/json",
                },
                json={
                    "inputs": prompt,
                    "parameters": {
                        "max_new_tokens": endpoint.max_tokens,
                        "temperature": endpoint.temperature,
                        "top_p": 0.9,
                        "do_sample": True,
                        "return_full_text": False,
                    },
                    "options": {
                        "wait_for_model": True,
                    }
                },
            )
            
            if response.status_code == 200:
                return self._parse_response(response.json())
            else:
                print(f"Custom endpoint error: {response.status_code}")
                return None
                
        except Exception as e:
            print(f"Custom endpoint inference error: {e}")
            return None

    def _parse_response(self, data: Any) -> Optional[Dict[str, Any]]:
        """Parse model response and extract JSON"""
        try:
            # Extract generated text
            if isinstance(data, list) and len(data) > 0:
                text = data[0].get("generated_text", "")
            elif isinstance(data, dict):
                text = data.get("generated_text", "")
            else:
                text = str(data)
            
            # Try to parse JSON
            return self._extract_json(text)
            
        except Exception as e:
            print(f"Response parsing error: {e}")
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
                json_str = text[start:end]
                return json.loads(json_str)
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
        """Check model availability"""
        status = {
            "qwen": "not_configured",
            "liquid_ai": "not_configured",
            "custom_endpoints": {},
        }
        
        if self.config.hf_api_token:
            # Check Qwen
            try:
                client = await self._get_client()
                resp = await client.get(
                    f"https://huggingface.co/api/models/{self.config.qwen_model_id}",
                    headers={"Authorization": f"Bearer {self.config.hf_api_token}"},
                    timeout=10.0,
                )
                status["qwen"] = "available" if resp.status_code == 200 else "error"
            except:
                status["qwen"] = "error"
            
            # Check LiquidAI
            try:
                resp = await client.get(
                    f"https://huggingface.co/api/models/{self.config.liquid_model_id}",
                    headers={"Authorization": f"Bearer {self.config.hf_api_token}"},
                    timeout=10.0,
                )
                status["liquid_ai"] = "available" if resp.status_code == 200 else "error"
            except:
                status["liquid_ai"] = "error"
        
        # Check custom endpoints
        for name, endpoint in self.config.custom_endpoints.items():
            status["custom_endpoints"][name] = "configured"
        
        return status


# ==================== FACTORY ====================

_qwen_liquid_node: Optional[QwenLiquidNode] = None


def get_qwen_liquid_node() -> QwenLiquidNode:
    """Get or create the QwenLiquid node"""
    global _qwen_liquid_node
    if _qwen_liquid_node is None:
        config = QwenLiquidConfig(
            hf_api_token=os.getenv("HUGGINGFACE_API_KEY", ""),
            qwen_endpoint=os.getenv(
                "QWEN_ENDPOINT",
                "https://api-inference.huggingface.co/models/Qwen/Qwen2.5-7B-Instruct"
            ),
            liquid_endpoint=os.getenv(
                "LIQUID_ENDPOINT",
                "https://api-inference.huggingface.co/models/LiquidAI/LFM2-1.2B-Instruct"
            ),
        )
        _qwen_liquid_node = QwenLiquidNode(config)
    return _qwen_liquid_node


def configure_custom_endpoint(
    name: str,
    endpoint_url: str,
    api_key: Optional[str] = None,
    **kwargs
) -> None:
    """Add a custom HuggingFace endpoint"""
    node = get_qwen_liquid_node()
    node.config.custom_endpoints[name] = HuggingFaceEndpointConfig(
        name=name,
        endpoint_url=endpoint_url,
        api_key=api_key,
        **kwargs
    )
    # Add to priority list
    if name not in node.config.model_priority:
        node.config.model_priority.insert(0, name)
