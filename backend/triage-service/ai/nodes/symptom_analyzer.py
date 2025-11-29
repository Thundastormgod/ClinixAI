"""
Symptom Analyzer Node for ClinixAI
===================================
Pre-processes and analyzes symptoms before LLM inference.
Extracts features, normalizes input, and identifies patterns.
"""

import re
from typing import Dict, Any, List, Optional, Tuple
from datetime import datetime
from enum import Enum

from pydantic import BaseModel


class BodySystem(str, Enum):
    """Body systems for symptom classification"""
    CARDIOVASCULAR = "cardiovascular"
    RESPIRATORY = "respiratory"
    GASTROINTESTINAL = "gastrointestinal"
    NEUROLOGICAL = "neurological"
    MUSCULOSKELETAL = "musculoskeletal"
    DERMATOLOGICAL = "dermatological"
    URINARY = "urinary"
    REPRODUCTIVE = "reproductive"
    ENDOCRINE = "endocrine"
    INFECTIOUS = "infectious"
    PSYCHOLOGICAL = "psychological"
    GENERAL = "general"


class SymptomFeatures(BaseModel):
    """Extracted features from symptoms"""
    primary_system: BodySystem
    affected_systems: List[BodySystem]
    severity_score: float  # 0-1
    duration_category: str  # acute, subacute, chronic
    has_vital_sign_abnormality: bool
    critical_symptom_count: int
    urgent_symptom_count: int
    africa_endemic_indicators: List[str]
    age_risk_factor: Optional[str]


class SymptomAnalyzerNode:
    """
    LangGraph node for symptom pre-processing and analysis.
    Extracts structured features from raw symptom input.
    """
    
    # Symptom to body system mapping
    SYSTEM_KEYWORDS = {
        BodySystem.CARDIOVASCULAR: [
            "chest pain", "heart", "palpitation", "blood pressure",
            "pulse", "circulation", "swelling legs", "shortness of breath"
        ],
        BodySystem.RESPIRATORY: [
            "cough", "breathing", "breath", "wheeze", "asthma",
            "lung", "chest tightness", "sputum", "congestion"
        ],
        BodySystem.GASTROINTESTINAL: [
            "stomach", "abdominal", "nausea", "vomiting", "diarrhea",
            "constipation", "bloating", "appetite", "bowel"
        ],
        BodySystem.NEUROLOGICAL: [
            "headache", "dizziness", "seizure", "numbness", "tingling",
            "confusion", "memory", "vision", "balance", "weakness"
        ],
        BodySystem.MUSCULOSKELETAL: [
            "joint", "muscle", "back pain", "neck pain", "stiffness",
            "swelling", "fracture", "sprain"
        ],
        BodySystem.DERMATOLOGICAL: [
            "rash", "itching", "skin", "wound", "burn", "lesion",
            "swelling", "discoloration"
        ],
        BodySystem.URINARY: [
            "urination", "urine", "bladder", "kidney", "burning urination"
        ],
        BodySystem.INFECTIOUS: [
            "fever", "chills", "malaria", "typhoid", "infection",
            "flu", "cold", "virus"
        ],
        BodySystem.GENERAL: [
            "fatigue", "weakness", "weight", "sleep", "tired", "energy"
        ]
    }
    
    # Africa-endemic disease indicators
    AFRICA_ENDEMIC_PATTERNS = {
        "malaria": ["fever", "chills", "sweating", "headache", "body ache"],
        "typhoid": ["fever", "abdominal pain", "weakness", "rose spots"],
        "cholera": ["watery diarrhea", "vomiting", "dehydration"],
        "dengue": ["fever", "rash", "joint pain", "eye pain"],
        "yellow_fever": ["fever", "jaundice", "bleeding"],
        "tuberculosis": ["cough", "night sweats", "weight loss", "blood sputum"],
        "hiv_opportunistic": ["weight loss", "chronic diarrhea", "recurrent infections"],
        "schistosomiasis": ["blood urine", "abdominal pain", "diarrhea"],
        "trypanosomiasis": ["fever", "swollen lymph nodes", "sleep disturbance"]
    }
    
    def __init__(self):
        self._symptom_severity_weights = {
            # Critical symptoms get highest weight
            "chest pain": 0.95,
            "difficulty breathing": 0.95,
            "unconscious": 1.0,
            "severe bleeding": 0.95,
            "seizure": 0.9,
            
            # Urgent symptoms
            "high fever": 0.75,
            "severe pain": 0.8,
            "vomiting blood": 0.85,
            "head injury": 0.85,
            
            # Standard symptoms
            "headache": 0.4,
            "cough": 0.3,
            "nausea": 0.35,
            "fatigue": 0.25,
            "diarrhea": 0.4,
        }
    
    def __call__(self, state: Dict[str, Any]) -> Dict[str, Any]:
        """
        Analyze symptoms and extract features.
        
        Args:
            state: LangGraph state containing symptoms
            
        Returns:
            Updated state with symptom features
        """
        symptoms = state.get("symptoms", [])
        vital_signs = state.get("vital_signs", {})
        patient_age = state.get("patient_age")
        
        # Extract features
        features = self._extract_features(symptoms, vital_signs, patient_age)
        
        # Build analysis summary
        analysis = {
            "symptom_features": features.dict(),
            "symptom_count": len(symptoms),
            "analysis_timestamp": datetime.utcnow().isoformat(),
        }
        
        return {
            "symptom_analysis": analysis,
            "messages": [{
                "role": "system",
                "content": f"Symptom analysis: {features.primary_system.value} system, severity {features.severity_score:.2f}"
            }]
        }
    
    def _extract_features(
        self,
        symptoms: List[Dict],
        vital_signs: Optional[Dict],
        patient_age: Optional[int]
    ) -> SymptomFeatures:
        """Extract structured features from symptoms"""
        
        # Get symptom text
        symptom_texts = [s.get("description", "").lower() for s in symptoms]
        combined_text = " ".join(symptom_texts)
        
        # Identify affected body systems
        affected_systems = self._identify_body_systems(combined_text)
        primary_system = affected_systems[0] if affected_systems else BodySystem.GENERAL
        
        # Calculate severity
        severity_score = self._calculate_severity(symptoms, combined_text)
        
        # Determine duration category
        duration_category = self._categorize_duration(symptoms)
        
        # Check vital signs
        has_vital_abnormality = self._check_vital_abnormalities(vital_signs)
        
        # Count critical/urgent symptoms
        critical_count, urgent_count = self._count_symptom_severity(combined_text)
        
        # Check for Africa-endemic indicators
        endemic_indicators = self._check_endemic_patterns(combined_text)
        
        # Age risk factor
        age_risk = self._assess_age_risk(patient_age)
        
        return SymptomFeatures(
            primary_system=primary_system,
            affected_systems=affected_systems,
            severity_score=severity_score,
            duration_category=duration_category,
            has_vital_sign_abnormality=has_vital_abnormality,
            critical_symptom_count=critical_count,
            urgent_symptom_count=urgent_count,
            africa_endemic_indicators=endemic_indicators,
            age_risk_factor=age_risk
        )
    
    def _identify_body_systems(self, text: str) -> List[BodySystem]:
        """Identify which body systems are affected"""
        system_scores = {}
        
        for system, keywords in self.SYSTEM_KEYWORDS.items():
            score = sum(1 for kw in keywords if kw in text)
            if score > 0:
                system_scores[system] = score
        
        # Sort by score
        sorted_systems = sorted(
            system_scores.items(), 
            key=lambda x: x[1], 
            reverse=True
        )
        
        if not sorted_systems:
            return [BodySystem.GENERAL]
        
        return [system for system, _ in sorted_systems]
    
    def _calculate_severity(
        self, 
        symptoms: List[Dict], 
        combined_text: str
    ) -> float:
        """Calculate overall severity score (0-1)"""
        scores = []
        
        # Patient-reported severity
        for s in symptoms:
            severity = s.get("severity")
            if severity:
                scores.append(severity / 10.0)
        
        # Keyword-based severity
        for keyword, weight in self._symptom_severity_weights.items():
            if keyword in combined_text:
                scores.append(weight)
        
        if not scores:
            return 0.5  # Default medium severity
        
        # Use max severity with some influence from mean
        return min(max(scores) * 0.7 + (sum(scores) / len(scores)) * 0.3, 1.0)
    
    def _categorize_duration(self, symptoms: List[Dict]) -> str:
        """Categorize symptom duration"""
        durations = [s.get("duration_hours") for s in symptoms if s.get("duration_hours")]
        
        if not durations:
            return "unknown"
        
        max_duration = max(durations)
        
        if max_duration < 24:
            return "acute"  # Less than 1 day
        elif max_duration < 168:  # 7 days
            return "subacute"
        else:
            return "chronic"
    
    def _check_vital_abnormalities(self, vital_signs: Optional[Dict]) -> bool:
        """Check for abnormal vital signs"""
        if not vital_signs:
            return False
        
        abnormalities = []
        
        temp = vital_signs.get("temperature")
        if temp and (temp < 35.5 or temp > 38.5):
            abnormalities.append(True)
        
        hr = vital_signs.get("heart_rate")
        if hr and (hr < 50 or hr > 120):
            abnormalities.append(True)
        
        o2 = vital_signs.get("oxygen_saturation")
        if o2 and o2 < 94:
            abnormalities.append(True)
        
        return any(abnormalities)
    
    def _count_symptom_severity(self, text: str) -> Tuple[int, int]:
        """Count critical and urgent symptoms"""
        critical_keywords = [
            "chest pain", "difficulty breathing", "unconscious",
            "severe bleeding", "seizure", "stroke", "heart attack"
        ]
        
        urgent_keywords = [
            "high fever", "severe pain", "vomiting blood",
            "head injury", "broken", "fracture"
        ]
        
        critical_count = sum(1 for kw in critical_keywords if kw in text)
        urgent_count = sum(1 for kw in urgent_keywords if kw in text)
        
        return critical_count, urgent_count
    
    def _check_endemic_patterns(self, text: str) -> List[str]:
        """Check for Africa-endemic disease patterns"""
        indicators = []
        
        for disease, symptoms in self.AFRICA_ENDEMIC_PATTERNS.items():
            matches = sum(1 for s in symptoms if s in text)
            if matches >= 2:  # At least 2 matching symptoms
                indicators.append(disease)
        
        return indicators
    
    def _assess_age_risk(self, age: Optional[int]) -> Optional[str]:
        """Assess age-related risk factors"""
        if age is None:
            return None
        
        if age < 1:
            return "infant_high_risk"
        elif age < 5:
            return "pediatric_elevated_risk"
        elif age > 65:
            return "elderly_elevated_risk"
        elif age > 80:
            return "elderly_high_risk"
        
        return None


class SymptomNormalizer:
    """Normalize and standardize symptom descriptions"""
    
    # Common misspellings and variations
    NORMALIZATIONS = {
        "headach": "headache",
        "stomache": "stomach",
        "diarrhoea": "diarrhea",
        "breathin": "breathing",
        "coughing": "cough",
        "vomitting": "vomiting",
        "nausea": "nausea",
        "feaver": "fever",
        "tiredness": "fatigue",
        "exhausted": "fatigue",
        "ache": "pain",
        "hurts": "pain",
    }
    
    def normalize(self, symptom: str) -> str:
        """Normalize a symptom description"""
        text = symptom.lower().strip()
        
        # Apply normalizations
        for wrong, correct in self.NORMALIZATIONS.items():
            text = text.replace(wrong, correct)
        
        # Remove extra whitespace
        text = re.sub(r'\s+', ' ', text)
        
        return text
    
    def extract_severity_from_text(self, text: str) -> Optional[int]:
        """Extract severity rating from text"""
        # Look for numeric ratings
        match = re.search(r'(\d+)\s*(?:out of|/)\s*10', text)
        if match:
            return min(int(match.group(1)), 10)
        
        # Look for descriptive severity
        severity_words = {
            "mild": 3,
            "moderate": 5,
            "severe": 8,
            "extreme": 9,
            "unbearable": 10,
            "slight": 2,
            "intense": 8,
        }
        
        text_lower = text.lower()
        for word, value in severity_words.items():
            if word in text_lower:
                return value
        
        return None
