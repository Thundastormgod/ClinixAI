# ClinixAI API Documentation

## Overview

ClinixAI provides both local on-device APIs (via Cactus SDK) and cloud backend APIs for medical triage functionality. This document covers both interfaces.

---

## Table of Contents

1. [On-Device APIs (Flutter/Dart)](#on-device-apis)
2. [Cloud Backend APIs (REST)](#cloud-backend-apis)
3. [Data Models](#data-models)
4. [Error Handling](#error-handling)
5. [Authentication](#authentication)

---

## On-Device APIs

### CactusService

The primary interface for on-device AI operations.

#### Initialization

```dart
import 'package:clinix_app/core/ai/cactus_service.dart';

final cactusService = CactusService();
```

#### Model Management

##### downloadModel
Downloads an AI model from the model repository.

```dart
Future<void> downloadModel(String modelId, {
  void Function(double progress)? onProgress,
})
```

**Parameters:**
| Name | Type | Description |
|------|------|-------------|
| `modelId` | `String` | Model identifier (e.g., "qwen-0.5b-q4") |
| `onProgress` | `Function(double)?` | Progress callback (0.0 - 1.0) |

**Example:**
```dart
await cactusService.downloadModel(
  'qwen-0.5b-q4',
  onProgress: (progress) => print('${(progress * 100).toInt()}%'),
);
```

##### loadModel
Loads a downloaded model into memory.

```dart
Future<void> loadModel(String modelPath)
```

**Parameters:**
| Name | Type | Description |
|------|------|-------------|
| `modelPath` | `String` | Path to the GGUF model file |

**Example:**
```dart
final modelPath = '${appDir}/models/qwen-0.5b-q4.gguf';
await cactusService.loadModel(modelPath);
```

##### dispose
Releases model resources.

```dart
Future<void> dispose()
```

#### Inference

##### runInference
Runs text generation with the loaded LLM.

```dart
Future<CactusResult> runInference(String prompt, {
  int maxTokens = 512,
  double temperature = 0.7,
  String? systemPrompt,
})
```

**Parameters:**
| Name | Type | Default | Description |
|------|------|---------|-------------|
| `prompt` | `String` | required | User input prompt |
| `maxTokens` | `int` | 512 | Maximum tokens to generate |
| `temperature` | `double` | 0.7 | Sampling temperature (0.0-1.0) |
| `systemPrompt` | `String?` | null | System context prompt |

**Returns:** `CactusResult`
```dart
class CactusResult {
  final String text;           // Generated text
  final int tokensGenerated;   // Token count
  final double durationMs;     // Inference time
  final bool success;          // Operation status
  final String? error;         // Error message if failed
}
```

**Example:**
```dart
final result = await cactusService.runInference(
  'Patient reports severe headache for 3 days with fever.',
  systemPrompt: 'You are a medical triage assistant. Classify urgency 1-5.',
  maxTokens: 256,
  temperature: 0.3,
);

if (result.success) {
  print('Triage: ${result.text}');
  print('Generated in ${result.durationMs}ms');
}
```

#### Speech-to-Text

##### transcribe
Transcribes audio to text using Whisper.

```dart
Future<TranscriptionResult> transcribe(String audioPath, {
  String language = 'en',
})
```

**Parameters:**
| Name | Type | Default | Description |
|------|------|---------|-------------|
| `audioPath` | `String` | required | Path to audio file (WAV, MP3) |
| `language` | `String` | "en" | Language code |

**Returns:** `TranscriptionResult`
```dart
class TranscriptionResult {
  final String text;           // Transcribed text
  final double confidence;     // Confidence score (0.0-1.0)
  final double durationMs;     // Processing time
  final bool success;          // Operation status
  final String? error;         // Error message if failed
}
```

**Example:**
```dart
final result = await cactusService.transcribe(
  '/path/to/symptoms.wav',
  language: 'en',
);

if (result.success) {
  print('Transcript: ${result.text}');
  print('Confidence: ${(result.confidence * 100).toInt()}%');
}
```

#### RAG Operations

##### initializeRAG
Initializes the RAG system with embeddings.

```dart
Future<void> initializeRAG({
  required String embeddingModelPath,
  int dimensions = 384,
})
```

##### addRAGDocument
Adds a document to the RAG knowledge base.

```dart
Future<void> addRAGDocument(String content, {
  Map<String, dynamic>? metadata,
})
```

**Parameters:**
| Name | Type | Description |
|------|------|-------------|
| `content` | `String` | Document text content |
| `metadata` | `Map?` | Optional metadata (title, source, etc.) |

**Example:**
```dart
await cactusService.addRAGDocument(
  'Chest pain assessment: Ask about onset, location, radiation...',
  metadata: {
    'category': 'cardiology',
    'source': 'WHO Guidelines',
  },
);
```

##### queryRAG
Queries the RAG system for relevant documents.

```dart
Future<List<RAGResult>> queryRAG(String query, {
  int topK = 5,
  double threshold = 0.7,
})
```

**Returns:** `List<RAGResult>`
```dart
class RAGResult {
  final String content;        // Document content
  final double score;          // Relevance score
  final Map<String, dynamic>? metadata;
}
```

#### Properties

| Property | Type | Description |
|----------|------|-------------|
| `isLMLoaded` | `bool` | Whether LLM is loaded |
| `isSTTLoaded` | `bool` | Whether STT model is loaded |
| `isRAGInitialized` | `bool` | Whether RAG is ready |
| `currentModelInfo` | `ModelInfo?` | Loaded model information |

---

### HybridRouter

Intelligent routing between local and cloud AI.

```dart
import 'package:clinix_app/core/ai/hybrid_router.dart';

final router = HybridRouter();
```

#### route

```dart
Future<AIResponse> route(AIRequest request)
```

**Parameters:**
```dart
class AIRequest {
  final String prompt;
  final AIRequestType type;      // triage, transcription, query
  final bool preferLocal;        // Prefer local processing
  final String? systemPrompt;
}
```

**Returns:** `AIResponse`
```dart
class AIResponse {
  final String text;
  final AISource source;         // local, cloud
  final String? modelUsed;
  final double latencyMs;
  final bool success;
  final String? error;
}
```

**Example:**
```dart
final response = await router.route(AIRequest(
  prompt: 'Analyze these symptoms: fever, cough, fatigue',
  type: AIRequestType.triage,
  preferLocal: true,
));

print('Response from ${response.source}: ${response.text}');
```

---

## Cloud Backend APIs

Base URL: `https://api.clinixai.com/v1`

### Authentication

All cloud API requests require authentication via Bearer token.

```http
Authorization: Bearer <access_token>
```

### Endpoints

#### POST /triage/analyze

Analyzes symptoms and returns triage assessment.

**Request:**
```json
{
  "symptoms": [
    {
      "description": "severe headache",
      "duration_minutes": 4320,
      "severity": 8
    },
    {
      "description": "fever",
      "duration_minutes": 2880,
      "severity": 7
    }
  ],
  "patient_context": {
    "age": 45,
    "gender": "female",
    "medical_history": ["hypertension", "diabetes"]
  },
  "model_preference": "gpt-4o-mini"
}
```

**Response:**
```json
{
  "triage_id": "tr_abc123",
  "urgency_level": 2,
  "urgency_label": "Emergent",
  "diagnosis_suggestions": [
    "Possible meningitis - requires immediate evaluation",
    "Severe migraine with systemic symptoms"
  ],
  "recommendations": [
    "Seek emergency medical care within 1 hour",
    "Do not drive yourself - have someone accompany you",
    "Bring list of current medications"
  ],
  "red_flags": [
    "Fever with severe headache in adult",
    "Symptoms persisting >48 hours"
  ],
  "confidence_score": 0.87,
  "model_used": "gpt-4o-mini",
  "processing_time_ms": 1234
}
```

**Status Codes:**
| Code | Description |
|------|-------------|
| 200 | Success |
| 400 | Invalid request |
| 401 | Unauthorized |
| 429 | Rate limit exceeded |
| 500 | Server error |

---

#### POST /triage/sync

Syncs offline triage sessions to the cloud.

**Request:**
```json
{
  "sessions": [
    {
      "session_id": "local_sess_123",
      "patient_id": "pat_456",
      "symptoms": ["headache", "nausea"],
      "transcript": "I've had a headache for two days...",
      "result": {
        "urgency_level": 3,
        "recommendations": ["..."]
      },
      "created_at": "2025-11-29T10:30:00Z",
      "processed_offline": true
    }
  ]
}
```

**Response:**
```json
{
  "synced_count": 1,
  "failed_count": 0,
  "session_mappings": [
    {
      "local_id": "local_sess_123",
      "cloud_id": "sess_xyz789"
    }
  ]
}
```

---

#### GET /knowledge/query

Queries the medical knowledge base.

**Request:**
```http
GET /knowledge/query?q=chest+pain+assessment&limit=5
```

**Response:**
```json
{
  "results": [
    {
      "content": "Chest pain assessment protocol: 1. Evaluate onset...",
      "source": "WHO Emergency Guidelines 2024",
      "relevance_score": 0.94,
      "category": "cardiology"
    }
  ],
  "total_results": 1,
  "query_time_ms": 45
}
```

---

#### GET /models/catalog

Returns available AI models.

**Response:**
```json
{
  "models": [
    {
      "id": "qwen-0.5b-q4",
      "name": "Qwen 0.5B (Q4)",
      "type": "llm",
      "size_mb": 350,
      "quantization": "Q4_K_M",
      "download_url": "https://cdn.clinixai.com/models/qwen-0.5b-q4.gguf",
      "checksum": "sha256:abc123..."
    },
    {
      "id": "whisper-tiny",
      "name": "Whisper Tiny",
      "type": "stt",
      "size_mb": 75,
      "download_url": "https://cdn.clinixai.com/models/whisper-tiny.bin",
      "checksum": "sha256:def456..."
    }
  ]
}
```

---

#### POST /ehr/patient

Creates or updates a patient record.

**Request:**
```json
{
  "patient_id": "pat_123",
  "demographics": {
    "name": "Jane Doe",
    "age": 35,
    "gender": "female",
    "contact": "+254700123456"
  },
  "medical_history": {
    "conditions": ["asthma"],
    "allergies": ["penicillin"],
    "medications": ["salbutamol"]
  }
}
```

**Response:**
```json
{
  "patient_id": "pat_123",
  "created": false,
  "updated": true,
  "ehr_sync_status": "pending"
}
```

---

## Data Models

### Triage Urgency Levels

| Level | Label | Description | Response Time |
|-------|-------|-------------|---------------|
| 1 | Critical | Life-threatening | Immediate |
| 2 | Emergent | High risk | < 1 hour |
| 3 | Urgent | Moderate risk | < 4 hours |
| 4 | Less Urgent | Low risk | Same day |
| 5 | Non-Urgent | Minimal risk | Scheduled |

### Symptom Schema

```typescript
interface Symptom {
  id: string;
  description: string;
  body_location?: string;      // "head", "chest", "abdomen", etc.
  severity: number;            // 1-10 scale
  duration_minutes: number;
  onset: "sudden" | "gradual";
  character?: string;          // "sharp", "dull", "burning", etc.
  reported_at: string;         // ISO 8601 timestamp
}
```

### Patient Context Schema

```typescript
interface PatientContext {
  age: number;
  gender: "male" | "female" | "other";
  weight_kg?: number;
  height_cm?: number;
  medical_history?: string[];
  allergies?: string[];
  current_medications?: string[];
  pregnancy_status?: "pregnant" | "not_pregnant" | "unknown";
}
```

---

## Error Handling

### Error Response Format

```json
{
  "error": {
    "code": "INVALID_REQUEST",
    "message": "Missing required field: symptoms",
    "details": {
      "field": "symptoms",
      "expected": "array"
    }
  },
  "request_id": "req_abc123"
}
```

### Error Codes

| Code | HTTP Status | Description |
|------|-------------|-------------|
| `INVALID_REQUEST` | 400 | Malformed request body |
| `MISSING_FIELD` | 400 | Required field missing |
| `UNAUTHORIZED` | 401 | Invalid or expired token |
| `FORBIDDEN` | 403 | Insufficient permissions |
| `NOT_FOUND` | 404 | Resource not found |
| `RATE_LIMITED` | 429 | Too many requests |
| `MODEL_ERROR` | 500 | AI model processing error |
| `SERVICE_ERROR` | 500 | Internal service error |

### Dart Error Handling

```dart
try {
  final result = await cactusService.runInference(prompt);
  if (!result.success) {
    throw CactusException(result.error ?? 'Unknown error');
  }
  return result.text;
} on CactusException catch (e) {
  // Handle Cactus-specific errors
  logger.error('Cactus error: ${e.message}');
  // Fallback to cloud
  return await openRouterService.complete(prompt);
} catch (e) {
  // Handle general errors
  logger.error('Unexpected error: $e');
  rethrow;
}
```

---

## Authentication

### API Key Authentication (Cloud)

```dart
final dio = Dio();
dio.options.headers['Authorization'] = 'Bearer $apiKey';
```

### Secure Storage (Mobile)

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

final storage = FlutterSecureStorage();

// Store API key
await storage.write(key: 'openrouter_api_key', value: apiKey);

// Retrieve API key
final apiKey = await storage.read(key: 'openrouter_api_key');
```

---

## Rate Limits

### Cloud API Limits

| Endpoint | Rate Limit | Burst |
|----------|------------|-------|
| `/triage/analyze` | 60/min | 10 |
| `/knowledge/query` | 120/min | 20 |
| `/triage/sync` | 30/min | 5 |
| `/models/catalog` | 10/min | 3 |

### Headers

```http
X-RateLimit-Limit: 60
X-RateLimit-Remaining: 45
X-RateLimit-Reset: 1732867200
```

---

## SDK Examples

### Complete Triage Flow

```dart
import 'package:clinix_app/core/ai/cactus_service.dart';
import 'package:clinix_app/core/ai/hybrid_router.dart';

Future<TriageResult> performTriage(String audioPath) async {
  final cactus = CactusService();
  final router = HybridRouter();
  
  // 1. Transcribe audio
  final transcription = await cactus.transcribe(audioPath);
  if (!transcription.success) {
    throw Exception('Transcription failed: ${transcription.error}');
  }
  
  // 2. Query relevant medical knowledge
  final ragResults = await cactus.queryRAG(
    transcription.text,
    topK: 3,
  );
  
  // 3. Build context-aware prompt
  final context = ragResults.map((r) => r.content).join('\n');
  final prompt = '''
Based on the following medical guidelines:
$context

Patient symptoms: ${transcription.text}

Provide triage assessment with urgency level (1-5).
''';
  
  // 4. Route to appropriate AI
  final response = await router.route(AIRequest(
    prompt: prompt,
    type: AIRequestType.triage,
    preferLocal: true,
    systemPrompt: 'You are a medical triage assistant.',
  ));
  
  // 5. Parse and return result
  return TriageResult.parse(response.text);
}
```

---

*API Version: 1.0.0*  
*Last Updated: November 29, 2025*
