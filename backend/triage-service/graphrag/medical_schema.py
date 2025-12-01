"""
Medical Schema for Neo4j Knowledge Graph

Defines the medical ontology for ClinixAI GraphRAG:
- Node types (Disease, Symptom, Drug, etc.)
- Relationship types (CAUSES, TREATS, INDICATES, etc.)
- Property schemas for each entity type

Based on medical standards: ICD-10, SNOMED-CT, RxNorm
"""

from typing import List, Dict, Any
from dataclasses import dataclass, field
from enum import Enum


class NodeType(str, Enum):
    """Medical entity node types"""
    # Clinical Entities
    DISEASE = "Disease"
    SYMPTOM = "Symptom"
    SIGN = "Sign"
    SYNDROME = "Syndrome"
    CONDITION = "Condition"
    
    # Treatments
    DRUG = "Drug"
    MEDICATION = "Medication"
    PROCEDURE = "Procedure"
    THERAPY = "Therapy"
    INTERVENTION = "Intervention"
    
    # Anatomy
    BODY_PART = "BodyPart"
    ORGAN = "Organ"
    SYSTEM = "System"
    
    # Clinical Context
    VITAL_SIGN = "VitalSign"
    LAB_TEST = "LabTest"
    DIAGNOSTIC_TEST = "DiagnosticTest"
    
    # Demographics
    AGE_GROUP = "AgeGroup"
    RISK_FACTOR = "RiskFactor"
    
    # Triage Specific
    RED_FLAG = "RedFlag"
    TRIAGE_LEVEL = "TriageLevel"
    URGENCY = "Urgency"
    
    # Knowledge Source
    DOCUMENT = "Document"
    CHUNK = "Chunk"
    GUIDELINE = "Guideline"


class RelationType(str, Enum):
    """Medical relationship types"""
    # Symptom-Disease Relations
    INDICATES = "INDICATES"           # Symptom indicates Disease
    MANIFESTS_AS = "MANIFESTS_AS"     # Disease manifests as Symptom
    ASSOCIATED_WITH = "ASSOCIATED_WITH"
    
    # Treatment Relations
    TREATS = "TREATS"                 # Drug treats Disease
    INDICATED_FOR = "INDICATED_FOR"   # Drug indicated for Condition
    CONTRAINDICATED_FOR = "CONTRAINDICATED_FOR"
    INTERACTS_WITH = "INTERACTS_WITH" # Drug-Drug interaction
    
    # Causal Relations
    CAUSES = "CAUSES"
    RISK_FACTOR_FOR = "RISK_FACTOR_FOR"
    COMPLICATION_OF = "COMPLICATION_OF"
    PROGRESSES_TO = "PROGRESSES_TO"
    
    # Anatomical Relations
    AFFECTS = "AFFECTS"               # Disease affects BodyPart
    LOCATED_IN = "LOCATED_IN"
    PART_OF = "PART_OF"
    
    # Diagnostic Relations
    DIAGNOSED_BY = "DIAGNOSED_BY"     # Disease diagnosed by Test
    MEASURED_BY = "MEASURED_BY"       # Condition measured by VitalSign
    
    # Triage Relations
    REQUIRES_URGENCY = "REQUIRES_URGENCY"
    ESCALATES_TO = "ESCALATES_TO"
    RED_FLAG_FOR = "RED_FLAG_FOR"
    
    # Source Relations
    MENTIONED_IN = "MENTIONED_IN"     # Entity mentioned in Document/Chunk
    EXTRACTED_FROM = "EXTRACTED_FROM"
    DEFINED_IN = "DEFINED_IN"
    
    # Hierarchical
    SUBTYPE_OF = "SUBTYPE_OF"
    CATEGORY = "CATEGORY"


# Medical Node Types allowed for extraction
MEDICAL_NODE_TYPES: List[str] = [
    "Disease", "Symptom", "Sign", "Syndrome", "Condition",
    "Drug", "Medication", "Procedure", "Therapy",
    "BodyPart", "Organ", "System",
    "VitalSign", "LabTest", "DiagnosticTest",
    "RiskFactor", "RedFlag", "TriageLevel",
    "AgeGroup", "Guideline"
]

# Medical Relationships allowed for extraction
MEDICAL_RELATIONSHIPS: List[str] = [
    "INDICATES", "MANIFESTS_AS", "ASSOCIATED_WITH",
    "TREATS", "INDICATED_FOR", "CONTRAINDICATED_FOR", "INTERACTS_WITH",
    "CAUSES", "RISK_FACTOR_FOR", "COMPLICATION_OF", "PROGRESSES_TO",
    "AFFECTS", "LOCATED_IN", "PART_OF",
    "DIAGNOSED_BY", "MEASURED_BY",
    "REQUIRES_URGENCY", "RED_FLAG_FOR", "ESCALATES_TO",
    "MENTIONED_IN", "EXTRACTED_FROM",
    "SUBTYPE_OF", "CATEGORY"
]


@dataclass
class MedicalSchema:
    """Schema configuration for medical knowledge graph"""
    
    allowed_nodes: List[str] = field(default_factory=lambda: MEDICAL_NODE_TYPES)
    allowed_relationships: List[str] = field(default_factory=lambda: MEDICAL_RELATIONSHIPS)
    strict_mode: bool = True
    
    # Node property schemas
    node_properties: Dict[str, List[str]] = field(default_factory=lambda: {
        "Disease": ["name", "icd10_code", "description", "severity", "contagious"],
        "Symptom": ["name", "description", "severity", "duration", "location"],
        "Sign": ["name", "description", "measurable", "normal_range"],
        "Drug": ["name", "rxnorm_code", "drug_class", "dosage", "route"],
        "Procedure": ["name", "cpt_code", "description", "invasiveness"],
        "BodyPart": ["name", "system", "laterality"],
        "VitalSign": ["name", "unit", "normal_range_low", "normal_range_high"],
        "RedFlag": ["name", "severity", "requires_immediate_action", "timeframe"],
        "TriageLevel": ["name", "level", "color", "max_wait_time_minutes"],
        "Guideline": ["name", "source", "version", "effective_date"],
    })
    
    # Relationship property schemas
    relationship_properties: Dict[str, List[str]] = field(default_factory=lambda: {
        "INDICATES": ["strength", "specificity", "sensitivity"],
        "TREATS": ["efficacy", "evidence_level", "first_line"],
        "CAUSES": ["probability", "mechanism", "timeframe"],
        "RED_FLAG_FOR": ["urgency_level", "action_required"],
        "INTERACTS_WITH": ["severity", "mechanism", "management"],
    })
    
    def to_dict(self) -> Dict[str, Any]:
        """Convert schema to dictionary for LangChain"""
        return {
            "allowed_nodes": self.allowed_nodes,
            "allowed_relationships": self.allowed_relationships,
            "strict_mode": self.strict_mode,
            "node_properties": self.node_properties,
            "relationship_properties": self.relationship_properties,
        }


# Pre-defined schemas for different use cases
TRIAGE_SCHEMA = MedicalSchema(
    allowed_nodes=[
        "Disease", "Symptom", "Sign", "RedFlag", "TriageLevel",
        "VitalSign", "BodyPart", "RiskFactor", "AgeGroup"
    ],
    allowed_relationships=[
        "INDICATES", "MANIFESTS_AS", "RED_FLAG_FOR", "REQUIRES_URGENCY",
        "AFFECTS", "RISK_FACTOR_FOR", "ASSOCIATED_WITH"
    ],
    strict_mode=True
)

DRUG_SCHEMA = MedicalSchema(
    allowed_nodes=[
        "Drug", "Medication", "Disease", "Symptom", "Condition"
    ],
    allowed_relationships=[
        "TREATS", "INDICATED_FOR", "CONTRAINDICATED_FOR", 
        "INTERACTS_WITH", "CAUSES"
    ],
    strict_mode=True
)

FULL_MEDICAL_SCHEMA = MedicalSchema(
    strict_mode=False  # Allow all node/relationship types
)
