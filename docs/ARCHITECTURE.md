# ClinixAI System Architecture

## Overview

ClinixAI is an AI-powered emergency medical triage system designed for resource-constrained environments in Africa. The architecture prioritizes offline-first operation, privacy-preserving local inference, and seamless cloud integration when available.

---

## High-Level Architecture

```
┌────────────────────────────────────────────────────────────────────────────┐
│                              CLINIXAI SYSTEM                                │
├────────────────────────────────────────────────────────────────────────────┤
│                                                                            │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                         MOBILE APPLICATION                           │  │
│  │                         (Flutter/Dart)                               │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌────────────┐  │  │
│  │  │   Triage    │  │  Knowledge  │  │     EHR     │  │  Settings  │  │  │
│  │  │   Feature   │  │    Base     │  │ Integration │  │   Module   │  │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └────────────┘  │  │
│  │                         │                                            │  │
│  │  ┌───────────────────────────────────────────────────────────────┐  │  │
│  │  │                    CORE AI LAYER                               │  │  │
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐    │  │  │
│  │  │  │CactusService│  │HybridRouter │  │ OpenRouterService   │    │  │  │
│  │  │  │(On-Device)  │  │(Intelligent │  │ (Cloud Fallback)    │    │  │  │
│  │  │  │             │  │ Routing)    │  │                     │    │  │  │
│  │  │  │• Qwen LLM   │  │             │  │• GPT-4o-mini        │    │  │  │
│  │  │  │• Whisper STT│  │             │  │• Claude Haiku       │    │  │  │
│  │  │  │• RAG System │  │             │  │• Gemini Flash       │    │  │  │
│  │  │  └─────────────┘  └─────────────┘  └─────────────────────┘    │  │  │
│  │  └───────────────────────────────────────────────────────────────┘  │  │
│  │                         │                                            │  │
│  │  ┌───────────────────────────────────────────────────────────────┐  │  │
│  │  │                    DATA LAYER                                  │  │  │
│  │  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐    │  │  │
│  │  │  │  Isar DB    │  │  Secure     │  │   Model Storage     │    │  │  │
│  │  │  │  (Local)    │  │  Storage    │  │   (On-Device)       │    │  │  │
│  │  │  └─────────────┘  └─────────────┘  └─────────────────────┘    │  │  │
│  │  └───────────────────────────────────────────────────────────────┘  │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                   │                                        │
│                                   │ HTTPS (when online)                    │
│                                   ▼                                        │
│  ┌─────────────────────────────────────────────────────────────────────┐  │
│  │                         BACKEND SERVICES                             │  │
│  │  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  ┌────────────┐  │  │
│  │  │ API Gateway │  │   Triage    │  │ EHR Bridge  │  │  Database  │  │  │
│  │  │  (FastAPI)  │  │   Service   │  │  (DHIS2/    │  │ (Postgres) │  │  │
│  │  │             │  │             │  │   OpenMRS)  │  │            │  │  │
│  │  └─────────────┘  └─────────────┘  └─────────────┘  └────────────┘  │  │
│  └─────────────────────────────────────────────────────────────────────┘  │
│                                                                            │
└────────────────────────────────────────────────────────────────────────────┘
```

---

## Component Details

### 1. Mobile Application Layer

#### 1.1 Feature Modules

| Module | Responsibility |
|--------|---------------|
| **Triage** | Voice/text symptom capture, AI analysis, urgency classification |
| **Knowledge Base** | Medical guidelines RAG, offline reference |
| **EHR Integration** | Patient records sync with DHIS2/OpenMRS |
| **Settings** | Model management, preferences, sync configuration |

#### 1.2 Clean Architecture Layers

```
┌──────────────────────────────────────────┐
│          PRESENTATION LAYER              │
│  • Screens (StatelessWidget)             │
│  • Widgets (Reusable components)         │
│  • Providers (Riverpod state)            │
│  • View Models (UI logic)                │
└─────────────────┬────────────────────────┘
                  │ Depends on
                  ▼
┌──────────────────────────────────────────┐
│            DOMAIN LAYER                  │
│  • Entities (Business objects)           │
│  • Use Cases (Business logic)            │
│  • Repository Interfaces                 │
└─────────────────┬────────────────────────┘
                  │ Depends on
                  ▼
┌──────────────────────────────────────────┐
│             DATA LAYER                   │
│  • Models (Data transfer objects)        │
│  • Data Sources (Local/Remote)           │
│  • Repository Implementations            │
└──────────────────────────────────────────┘
```

### 2. Core AI Layer

#### 2.1 CactusService (On-Device AI)

The Cactus SDK provides llama.cpp-based inference directly on mobile devices.

```dart
CactusService
├── CactusLM      // Qwen 0.5B/1.5B language model
├── CactusSTT     // Whisper tiny/base speech-to-text
├── CactusRAG     // Vector embeddings + retrieval
└── ModelManager  // Download, cache, version management
```

**Capabilities:**
- Text generation (Qwen 0.5B-1.5B)
- Speech recognition (Whisper tiny/base)
- Embeddings (384-dimensional)
- RAG with local vector store

**Performance Targets:**
| Operation | Target Latency | Memory |
|-----------|---------------|--------|
| LLM inference | < 5s | 500MB-1GB |
| STT transcription | < 2s | 200MB |
| RAG query | < 500ms | 100MB |

#### 2.2 HybridRouter (Intelligent Routing)

```dart
class HybridRouter {
  Future<AIResponse> route(AIRequest request) async {
    // 1. Check connectivity
    final isOnline = await _checkConnectivity();
    
    // 2. Check local model availability
    final localAvailable = _cactusService.isLMLoaded;
    
    // 3. Route based on conditions
    if (!isOnline) {
      return _routeToLocal(request);  // Offline: local only
    }
    
    if (request.preferLocal && localAvailable) {
      return _routeToLocal(request);  // Privacy-sensitive
    }
    
    if (request.complexity == 'high') {
      return _routeToCloud(request);  // Complex queries
    }
    
    return _routeToLocal(request);    // Default: local
  }
}
```

**Routing Decision Matrix:**

| Connectivity | Local Model | Complexity | Route |
|--------------|-------------|------------|-------|
| Offline | Any | Any | Local |
| Online | Loaded | Low | Local |
| Online | Loaded | High | Cloud |
| Online | Not Loaded | Any | Cloud |

#### 2.3 OpenRouterService (Cloud Fallback)

Provides access to multiple cloud LLM providers through a unified API.

**Supported Models:**
- OpenAI GPT-4o-mini
- Anthropic Claude 3 Haiku
- Google Gemini 1.5 Flash
- Meta Llama 3.1 8B

### 3. Data Layer

#### 3.1 Local Database (Isar)

```
Isar Collections
├── LocalPatientProfile    // Patient demographics, history
├── LocalTriageSession     // Triage interaction sessions
├── LocalTriageResult      // AI analysis results
├── LocalSymptom           // Individual symptom records
└── LocalMedicalGuideline  // Cached medical knowledge
```

**Schema Design Principles:**
- Denormalized for offline performance
- Indexed for fast queries
- Encrypted sensitive fields

#### 3.2 Secure Storage

```dart
// Credentials stored via flutter_secure_storage
- API keys (OpenRouter, backend)
- User authentication tokens
- Encryption keys
```

#### 3.3 Model Storage

```
/data/data/com.clinixai.app/
├── files/
│   └── models/
│       ├── qwen-0.5b-q4.gguf      // LLM model
│       ├── whisper-tiny.bin       // STT model
│       └── embeddings.bin         // RAG embeddings
└── databases/
    └── clinix.isar               // Local database
```

### 4. Backend Services

#### 4.1 API Gateway (FastAPI)

```python
# Endpoints
POST /api/v1/triage/analyze     # Cloud triage analysis
POST /api/v1/triage/sync        # Sync offline sessions
GET  /api/v1/knowledge/query    # Knowledge base queries
POST /api/v1/ehr/patient        # Patient record operations
GET  /api/v1/models/catalog     # Available AI models
```

#### 4.2 Service Architecture

```
┌─────────────────────────────────────────────────────────┐
│                    API GATEWAY                          │
│                    (FastAPI)                            │
│  • Authentication (JWT)                                 │
│  • Rate limiting                                        │
│  • Request validation                                   │
│  • Response caching                                     │
└─────────────────┬───────────────────────────────────────┘
                  │
    ┌─────────────┼─────────────┐
    ▼             ▼             ▼
┌─────────┐ ┌─────────┐ ┌─────────────┐
│ Triage  │ │Knowledge│ │    EHR      │
│ Service │ │  Base   │ │   Bridge    │
│         │ │ Service │ │             │
│• Ollama │ │• RAG    │ │• DHIS2 API  │
│• OpenAI │ │• Vector │ │• OpenMRS    │
│         │ │  Store  │ │• HL7 FHIR   │
└────┬────┘ └────┬────┘ └──────┬──────┘
     │           │             │
     └───────────┴─────────────┘
                 │
                 ▼
        ┌─────────────────┐
        │   PostgreSQL    │
        │   + pgvector    │
        └─────────────────┘
```

---

## Data Flow Diagrams

### Triage Flow (Offline)

```
┌─────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│User │───▶│ Voice   │───▶│ Whisper │───▶│ Qwen    │───▶│ Result  │
│     │    │ Input   │    │ STT     │    │ LLM     │    │ Screen  │
└─────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
              │                             │               │
              │ Audio                       │ Prompt        │ Save
              ▼                             ▼               ▼
           [File]                        [RAG]          [Isar DB]
```

### Triage Flow (Online)

```
┌─────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
│User │───▶│ Voice   │───▶│ Hybrid  │───▶│ Cloud   │───▶│ Result  │
│     │    │ Input   │    │ Router  │    │ API     │    │ Screen  │
└─────┘    └─────────┘    └─────────┘    └─────────┘    └─────────┘
                               │               │
                               │ Decision      │ Response
                               ▼               ▼
                          [Local/Cloud]   [Sync to Isar]
```

### Data Sync Flow

```
┌───────────────┐         ┌───────────────┐         ┌───────────────┐
│  Local Isar   │         │  Sync Manager │         │  Cloud DB     │
│               │         │               │         │               │
│ ┌───────────┐ │   Push  │ ┌───────────┐ │  HTTP   │ ┌───────────┐ │
│ │ Sessions  │─┼────────▶│ │ Conflict  │─┼────────▶│ │ Sessions  │ │
│ └───────────┘ │         │ │ Resolution│ │         │ └───────────┘ │
│               │         │ └───────────┘ │         │               │
│ ┌───────────┐ │   Pull  │               │  HTTP   │ ┌───────────┐ │
│ │ Guidelines│◀┼─────────│               │◀────────┼─│ Guidelines│ │
│ └───────────┘ │         │               │         │ └───────────┘ │
└───────────────┘         └───────────────┘         └───────────────┘
```

---

## Deployment Architecture

### Development

```
┌─────────────────────────────────────────────────────┐
│                  DEVELOPMENT                         │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │   Flutter   │  │   Docker    │  │   Ollama    │  │
│  │   Debug     │  │   Compose   │  │   Local     │  │
│  │             │  │             │  │             │  │
│  │ • Hot reload│  │ • Backend   │  │ • Qwen 0.5B │  │
│  │ • DevTools  │  │ • Postgres  │  │ • Whisper   │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────────┘
```

### Production

```
┌─────────────────────────────────────────────────────────────────────┐
│                         PRODUCTION                                   │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                      MOBILE DEVICES                          │    │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────────────┐ │    │
│  │  │Android  │  │  iOS    │  │ Android │  │   Model CDN     │ │    │
│  │  │ Phone   │  │  Phone  │  │ Tablet  │  │   (CloudFront)  │ │    │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────┘    │
│                                │                                     │
│                                │ HTTPS                               │
│                                ▼                                     │
│  ┌─────────────────────────────────────────────────────────────┐    │
│  │                     CLOUD INFRASTRUCTURE                     │    │
│  │  ┌─────────┐  ┌─────────┐  ┌─────────┐  ┌─────────────────┐ │    │
│  │  │   ALB   │──│   ECS   │──│   RDS   │  │   OpenRouter    │ │    │
│  │  │         │  │ Fargate │  │Postgres │  │   (AI APIs)     │ │    │
│  │  └─────────┘  └─────────┘  └─────────┘  └─────────────────┘ │    │
│  └─────────────────────────────────────────────────────────────┘    │
└─────────────────────────────────────────────────────────────────────┘
```

---

## Security Architecture

### Data Protection Layers

```
┌─────────────────────────────────────────────────────┐
│                 SECURITY LAYERS                      │
├─────────────────────────────────────────────────────┤
│  Layer 1: Transport                                  │
│  • TLS 1.3 for all network traffic                  │
│  • Certificate pinning in production                │
├─────────────────────────────────────────────────────┤
│  Layer 2: Application                               │
│  • JWT authentication                               │
│  • API key rotation                                 │
│  • Input validation                                 │
├─────────────────────────────────────────────────────┤
│  Layer 3: Data at Rest                              │
│  • AES-256 encryption (flutter_secure_storage)      │
│  • Encrypted Isar fields                            │
│  • Secure enclave for keys (iOS/Android)            │
├─────────────────────────────────────────────────────┤
│  Layer 4: Privacy                                   │
│  • Local-first processing                           │
│  • No PII to cloud without consent                  │
│  • HIPAA-compliant data handling                    │
└─────────────────────────────────────────────────────┘
```

### Authentication Flow

```
┌─────────┐    ┌─────────────┐    ┌─────────────┐    ┌─────────────┐
│  User   │───▶│   Mobile    │───▶│ API Gateway │───▶│   Auth      │
│         │    │    App      │    │             │    │   Service   │
└─────────┘    └─────────────┘    └─────────────┘    └─────────────┘
    │                │                  │                  │
    │ Credentials    │ JWT Request      │ Validate         │
    │                │                  │                  │
    └────────────────┴──────────────────┴──────────────────┘
```

---

## Scalability Considerations

### Horizontal Scaling

| Component | Scaling Strategy |
|-----------|-----------------|
| API Gateway | Auto-scaling ECS tasks |
| Database | RDS read replicas |
| AI Processing | Queue-based with workers |
| Model Storage | CDN distribution |

### Performance Optimization

| Area | Optimization |
|------|-------------|
| Mobile | Lazy loading, image compression |
| Network | Request batching, caching |
| Database | Indexed queries, connection pooling |
| AI | Model quantization (Q4), batch inference |

---

## Monitoring & Observability

```
┌─────────────────────────────────────────────────────┐
│              OBSERVABILITY STACK                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐  │
│  │   Metrics   │  │   Logging   │  │   Tracing   │  │
│  │ (CloudWatch)│  │ (CloudWatch)│  │  (X-Ray)    │  │
│  │             │  │             │  │             │  │
│  │ • Latency   │  │ • Errors    │  │ • Requests  │  │
│  │ • Throughput│  │ • Events    │  │ • Flows     │  │
│  │ • Errors    │  │ • Audits    │  │ • Deps      │  │
│  └─────────────┘  └─────────────┘  └─────────────┘  │
└─────────────────────────────────────────────────────┘
```

---

## Appendix: Technology Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Mobile Framework | Flutter | Cross-platform, performance, Cactus SDK support |
| State Management | Riverpod | Type-safe, testable, compile-time verification |
| Local Database | Isar | High-performance, Flutter-native, encrypted |
| On-Device AI | Cactus SDK | llama.cpp wrapper, Whisper STT, RAG built-in |
| Backend Framework | FastAPI | Python async, OpenAPI, ML ecosystem |
| Cloud Database | PostgreSQL | Reliable, pgvector for embeddings |

---

*Document Version: 1.0.0*  
*Last Updated: November 29, 2025*
