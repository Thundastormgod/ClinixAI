# ClinixAI Frontend Implementation Plan

## Executive Summary

ClinixAI is a Flutter-based mobile application providing AI-powered emergency medical triage for underserved communities in Africa. The app leverages on-device LLM inference via the Cactus SDK for offline-first operation, with cloud fallback for enhanced capabilities.

---

## 1. Technology Stack

### Core Framework
| Technology | Version | Purpose |
|------------|---------|---------|
| **Flutter** | 3.2.0+ | Cross-platform mobile framework |
| **Dart** | 3.2.0+ | Programming language |
| **Cactus SDK** | 1.2.0 | On-device LLM inference (llama.cpp) |

### State Management
| Package | Purpose |
|---------|---------|
| `flutter_riverpod` | Reactive state management |
| `riverpod_annotation` | Code generation for providers |

### Local Storage
| Package | Purpose |
|---------|---------|
| `isar` | High-performance NoSQL database |
| `flutter_secure_storage` | Encrypted credential storage |
| `path_provider` | File system access |

### Networking
| Package | Purpose |
|---------|---------|
| `dio` | HTTP client for API calls |
| `connectivity_plus` | Network connectivity detection |

### AI/ML
| Package | Purpose |
|---------|---------|
| `cactus` | On-device LLM (Qwen), STT (Whisper), RAG, Embeddings |

---

## 2. Architecture Overview

### Clean Architecture Layers

```
┌─────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                        │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Screens   │  │   Widgets   │  │  State (Riverpod)   │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                            │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │  Entities   │  │  Use Cases  │  │  Repository (I/F)   │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────┐
│                       DATA LAYER                             │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────────────┐  │
│  │   Models    │  │ Data Sources│  │ Repository (Impl)   │  │
│  │             │  │ Local/Remote│  │                     │  │
│  └─────────────┘  └─────────────┘  └─────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

### Folder Structure

```
lib/
├── main.dart                    # App entry point
├── core/                        # Shared core functionality
│   ├── ai/                      # AI service layer
│   │   ├── cactus_service.dart      # On-device LLM wrapper
│   │   ├── openrouter_service.dart  # Cloud AI fallback
│   │   ├── hybrid_router.dart       # Intelligent routing
│   │   ├── clinix_ai_service.dart   # Unified AI interface
│   │   └── ai_providers.dart        # Riverpod providers
│   ├── constants/               # App-wide constants
│   ├── database/                # Local database
│   │   ├── local_database.dart      # Isar database setup
│   │   └── collections/             # Isar collections
│   ├── error/                   # Error handling
│   └── utils/                   # Utility functions
├── features/                    # Feature modules
│   ├── triage/                  # Emergency triage feature
│   │   ├── data/
│   │   ├── domain/
│   │   │   └── usecases/
│   │   │       └── perform_triage.dart
│   │   └── presentation/
│   │       └── voice_triage_screen.dart
│   ├── knowledge_base/          # Medical knowledge RAG
│   └── ehr_integration/         # EHR system integration
└── shared/                      # Shared UI components
    └── widgets/
```

---

## 3. Feature Implementation Details

### 3.1 Emergency Triage System

#### Voice-First Interface
```dart
// User flow:
1. User opens app → Voice Triage Screen
2. User describes symptoms via voice or text
3. On-device Whisper STT transcribes audio
4. Local Qwen LLM analyzes symptoms
5. RAG retrieves relevant medical guidelines
6. Triage result with urgency level displayed
```

#### Triage Urgency Levels
| Level | Color | Description | Action Required |
|-------|-------|-------------|-----------------|
| **1 - Critical** | 🔴 Red | Life-threatening | Immediate emergency care |
| **2 - Emergent** | 🟠 Orange | Urgent condition | Emergency within 1 hour |
| **3 - Urgent** | 🟡 Yellow | Serious but stable | Medical attention within 4 hours |
| **4 - Less Urgent** | 🟢 Green | Minor condition | Scheduled care acceptable |
| **5 - Non-Urgent** | 🔵 Blue | Routine care | Self-care or scheduled visit |

#### Key Components

**VoiceTriageScreen** (`lib/features/triage/presentation/voice_triage_screen.dart`)
- Voice input with real-time transcription
- Text input fallback
- Symptom history display
- Triage result visualization

**PerformTriage UseCase** (`lib/features/triage/domain/usecases/perform_triage.dart`)
- Orchestrates triage workflow
- Manages local vs cloud routing
- Handles offline scenarios

### 3.2 AI Service Architecture

#### Hybrid AI Router
```
┌──────────────────────────────────────────────────────────────┐
│                      HybridRouter                             │
│  ┌────────────────────────────────────────────────────────┐  │
│  │  1. Check device connectivity                          │  │
│  │  2. Check local model availability                     │  │
│  │  3. Route to appropriate service                       │  │
│  └────────────────────────────────────────────────────────┘  │
│                              │                                │
│          ┌───────────────────┼───────────────────┐           │
│          ▼                   │                   ▼           │
│  ┌───────────────┐           │         ┌──────────────────┐  │
│  │ CactusService │           │         │ OpenRouterService│  │
│  │ (On-Device)   │           │         │ (Cloud Fallback) │  │
│  │               │           │         │                  │  │
│  │ • Qwen LLM    │           │         │ • GPT-4o-mini    │  │
│  │ • Whisper STT │           │         │ • Claude Haiku   │  │
│  │ • RAG/Embed   │           │         │ • Gemini Flash   │  │
│  └───────────────┘           │         └──────────────────┘  │
│                              │                                │
└──────────────────────────────┴───────────────────────────────┘
```

#### CactusService Implementation
```dart
class CactusService {
  CactusLM? _lm;           // Language model
  CactusRAG? _rag;         // RAG system
  CactusSTT? _stt;         // Speech-to-text
  
  // Model lifecycle
  Future<void> downloadModel(String modelId);
  Future<void> loadModel(String modelPath);
  Future<void> dispose();
  
  // Inference
  Future<CactusResult> runInference(String prompt);
  Future<TranscriptionResult> transcribe(String audioPath);
  
  // RAG operations
  Future<void> initializeRAG({required String embeddingPath});
  Future<void> addRAGDocument(String content, {Map<String, dynamic>? metadata});
  Future<List<String>> queryRAG(String query, {int topK = 5});
}
```

### 3.3 Local Database Schema

#### Isar Collections

**LocalPatientProfile**
```dart
@collection
class LocalPatientProfile {
  Id id = Isar.autoIncrement;
  String? patientId;
  String? name;
  int? age;
  String? gender;
  List<String>? medicalHistory;
  List<String>? allergies;
  DateTime? createdAt;
  DateTime? updatedAt;
}
```

**LocalTriageSession**
```dart
@collection
class LocalTriageSession {
  Id id = Isar.autoIncrement;
  String? sessionId;
  String? patientId;
  List<String>? symptoms;
  String? transcript;
  DateTime? startedAt;
  DateTime? completedAt;
  bool? isOnline;
}
```

**LocalTriageResult**
```dart
@collection
class LocalTriageResult {
  Id id = Isar.autoIncrement;
  String? resultId;
  String? sessionId;
  int? urgencyLevel;        // 1-5
  String? diagnosis;
  List<String>? recommendations;
  double? confidenceScore;
  String? aiModel;          // "local" or "cloud:model-name"
  DateTime? createdAt;
}
```

**LocalSymptom**
```dart
@collection
class LocalSymptom {
  Id id = Isar.autoIncrement;
  String? symptomId;
  String? sessionId;
  String? description;
  String? bodyLocation;
  int? severity;            // 1-10
  int? duration;            // minutes
  DateTime? reportedAt;
}
```

---

## 4. UI/UX Implementation

### 4.1 Design System

#### Color Palette (Nothing Phone Inspired)
```dart
// Primary colors
static const Color primary = Color(0xFFE53935);      // Nothing Red
static const Color secondary = Color(0xFF212121);    // Dark Gray
static const Color surface = Color(0xFF121212);      // Near Black
static const Color onSurface = Color(0xFFFFFFFF);    // White text

// Urgency colors
static const Color critical = Color(0xFFD32F2F);     // Red
static const Color emergent = Color(0xFFFF9800);     // Orange
static const Color urgent = Color(0xFFFFEB3B);       // Yellow
static const Color lessUrgent = Color(0xFF4CAF50);   // Green
static const Color nonUrgent = Color(0xFF2196F3);    // Blue
```

#### Typography (Nothing Sans)
```dart
// Headings
static const TextStyle h1 = TextStyle(
  fontFamily: 'NothingSans',
  fontSize: 32,
  fontWeight: FontWeight.bold,
);

// Body text
static const TextStyle body = TextStyle(
  fontFamily: 'NothingSans',
  fontSize: 16,
  fontWeight: FontWeight.normal,
);
```

### 4.2 Screen Inventory

| Screen | Route | Description |
|--------|-------|-------------|
| **Splash** | `/` | App loading, model initialization |
| **Home** | `/home` | Dashboard with quick actions |
| **Voice Triage** | `/triage/voice` | Main triage interface |
| **Text Triage** | `/triage/text` | Text-based symptom input |
| **Triage Result** | `/triage/result` | Results with recommendations |
| **History** | `/history` | Past triage sessions |
| **Settings** | `/settings` | App configuration |
| **Model Manager** | `/settings/models` | Download/manage AI models |

### 4.3 Key Widgets

```dart
// Custom widgets to implement
lib/shared/widgets/
├── urgency_indicator.dart       // Color-coded urgency display
├── symptom_chip.dart            // Symptom tag component
├── voice_input_button.dart      // Animated voice recording button
├── triage_result_card.dart      // Result summary card
├── recommendation_tile.dart     // Action recommendation item
├── model_status_indicator.dart  // AI model loading status
└── offline_banner.dart          // Offline mode indicator
```

---

## 5. Implementation Phases

### Phase 1: Core Infrastructure (Week 1)
- [x] Project setup with Clean Architecture
- [x] Cactus SDK integration
- [x] Local database setup (Isar)
- [x] State management (Riverpod)
- [x] Hybrid router implementation

### Phase 2: Triage Feature (Week 2)
- [ ] Voice triage screen UI
- [ ] STT integration (Whisper)
- [ ] LLM inference pipeline
- [ ] Triage result display
- [ ] Offline mode handling

### Phase 3: Knowledge Base (Week 3)
- [ ] RAG system setup
- [ ] Medical guidelines ingestion
- [ ] Query interface
- [ ] Context-aware responses

### Phase 4: Polish & Testing (Week 4)
- [ ] UI/UX refinement
- [ ] Unit tests (80%+ coverage)
- [ ] Integration tests
- [ ] Performance optimization
- [ ] Accessibility (a11y)

---

## 6. Testing Strategy

### Unit Tests
```dart
// Test coverage targets
- AI Services: 90%
- Use Cases: 95%
- Repositories: 85%
- Utilities: 100%
```

### Widget Tests
```dart
// Key screens to test
- VoiceTriageScreen
- TriageResultScreen
- HistoryScreen
```

### Integration Tests
```dart
// End-to-end flows
- Complete triage flow (voice → result)
- Offline triage scenario
- Model download and initialization
```

---

## 7. Performance Requirements

| Metric | Target | Measurement |
|--------|--------|-------------|
| App launch | < 3s | Cold start to interactive |
| Model load | < 10s | Local LLM initialization |
| STT latency | < 2s | Audio → text conversion |
| LLM inference | < 5s | Prompt → response |
| UI frame rate | 60fps | Smooth animations |
| APK size | < 50MB | Without models |

---

## 8. Offline-First Strategy

### Data Sync Flow
```
┌─────────────┐     ┌─────────────┐     ┌─────────────┐
│   Local     │────▶│   Sync      │────▶│   Cloud     │
│   Isar DB   │◀────│   Manager   │◀────│   Backend   │
└─────────────┘     └─────────────┘     └─────────────┘
       │                   │
       │  Offline Mode     │  Online Mode
       │  • All features   │  • Enhanced AI
       │  • Local models   │  • Data sync
       │  • Queue changes  │  • Analytics
       ▼                   ▼
```

### Offline Capabilities
- ✅ Voice-to-text (Whisper on-device)
- ✅ Triage inference (Qwen on-device)
- ✅ RAG queries (local embeddings)
- ✅ Session storage (Isar)
- ✅ Patient profiles (local)
- ⏳ EHR sync (queued for online)

---

## 9. Security Considerations

### Data Protection
- All PII encrypted at rest (flutter_secure_storage)
- No PHI transmitted without consent
- Local-first processing for privacy
- HIPAA-compliant data handling

### API Security
- API keys stored securely
- TLS 1.3 for all network calls
- Certificate pinning (production)
- Rate limiting on cloud APIs

---

## 10. Deployment Checklist

### Pre-Release
- [ ] Remove debug flags
- [ ] Configure release signing
- [ ] Optimize ProGuard rules
- [ ] Enable crash reporting
- [ ] Set up analytics

### App Store Requirements
- [ ] Privacy policy URL
- [ ] Medical app disclaimers
- [ ] Age rating (Medical)
- [ ] Screenshots (6.5", 5.5")
- [ ] App description

### Model Distribution
- [ ] Host models on CDN
- [ ] Implement incremental downloads
- [ ] Add model versioning
- [ ] Create update mechanism

---

## Appendix A: API Reference

See [API_DOCUMENTATION.md](./API_DOCUMENTATION.md) for complete API reference.

## Appendix B: Model Specifications

See [MODEL_SPECIFICATIONS.md](./MODEL_SPECIFICATIONS.md) for AI model details.

---

*Document Version: 1.0.0*  
*Last Updated: November 29, 2025*
