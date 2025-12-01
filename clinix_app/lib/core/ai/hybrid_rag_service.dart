// Copyright 2024 ClinixAI. All rights reserved.
// SPDX-License-Identifier: MIT
//
// ClinixAI Hybrid RAG Service
// Principal-level implementation of hybrid Retrieval-Augmented Generation
//
// Architecture:
// ┌─────────────────────────────────────────────────────────────────┐
// │                     HybridRAGService                            │
// ├─────────────────────────────────────────────────────────────────┤
// │  LOCAL STACK              │  CLOUD STACK                        │
// │  ├─ KnowledgeBaseService  │  ├─ Neo4j GraphRAG                  │
// │  ├─ Isar Database         │  ├─ OpenRouter API                  │
// │  └─ Cactus LLM (LFM2)     │  └─ Claude Sonnet                   │
// └─────────────────────────────────────────────────────────────────┘
//
// Design Patterns:
// - Singleton: Single instance for consistent state management
// - Strategy: Different RAG sources as interchangeable strategies
// - Circuit Breaker: Resilience against backend failures
// - Facade: Simple interface hiding complexity
// - Defensive Programming: Safe parsing with sensible defaults

import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:meta/meta.dart';

import 'knowledge_base_service.dart';
import 'openrouter_service.dart';
import '../database/collections/local_rag_document.dart';

// ============================================================================
// EXCEPTIONS
// ============================================================================

/// Base exception for all RAG-related errors.
@immutable
class RAGException implements Exception {
  /// Human-readable error message.
  final String message;

  /// Optional underlying error.
  final Object? cause;

  const RAGException(this.message, {this.cause});

  @override
  String toString() => 'RAGException: $message${cause != null ? ' (caused by: $cause)' : ''}';
}

/// Exception thrown when the service is not initialized.
@immutable
class RAGNotInitializedException extends RAGException {
  const RAGNotInitializedException()
      : super('HybridRAGService not initialized. Call initialize() first.');
}

/// Exception thrown when network operations fail.
@immutable
class RAGNetworkException extends RAGException {
  /// HTTP status code if available.
  final int? statusCode;

  const RAGNetworkException(String message, {Object? cause, this.statusCode})
      : super(message, cause: cause);
}

// ============================================================================
// CONFIGURATION
// ============================================================================

/// Configuration for the HybridRAGService.
///
/// Use [HybridRAGConfig.development] or [HybridRAGConfig.production] for
/// common configurations, or create a custom configuration as needed.
@immutable
class HybridRAGConfig {
  /// Base URL for the GraphRAG backend API.
  final String backendUrl;

  /// Timeout for HTTP requests to the backend.
  final Duration httpTimeout;

  /// Maximum number of local chunks to retrieve.
  final int maxLocalChunks;

  /// Maximum number of cloud results to retrieve.
  final int maxCloudResults;

  /// Minimum risk score to trigger hybrid mode in auto selection.
  final double hybridRiskThreshold;

  /// Whether to enable circuit breaker for backend failures.
  final bool enableCircuitBreaker;

  /// Number of failures before circuit breaker opens.
  final int circuitBreakerThreshold;

  /// Duration to keep circuit breaker open.
  final Duration circuitBreakerResetDuration;

  const HybridRAGConfig({
    required this.backendUrl,
    this.httpTimeout = const Duration(seconds: 30),
    this.maxLocalChunks = 5,
    this.maxCloudResults = 10,
    this.hybridRiskThreshold = 0.6,
    this.enableCircuitBreaker = true,
    this.circuitBreakerThreshold = 3,
    this.circuitBreakerResetDuration = const Duration(minutes: 1),
  });

  /// Development configuration with local backend.
  factory HybridRAGConfig.development() => const HybridRAGConfig(
        backendUrl: 'http://localhost:8000',
        httpTimeout: Duration(seconds: 60),
        enableCircuitBreaker: false,
      );

  /// Production configuration.
  factory HybridRAGConfig.production({required String backendUrl}) =>
      HybridRAGConfig(
        backendUrl: backendUrl,
        httpTimeout: const Duration(seconds: 30),
        enableCircuitBreaker: true,
      );

  /// Creates a copy with the specified fields replaced.
  HybridRAGConfig copyWith({
    String? backendUrl,
    Duration? httpTimeout,
    int? maxLocalChunks,
    int? maxCloudResults,
    double? hybridRiskThreshold,
    bool? enableCircuitBreaker,
    int? circuitBreakerThreshold,
    Duration? circuitBreakerResetDuration,
  }) =>
      HybridRAGConfig(
        backendUrl: backendUrl ?? this.backendUrl,
        httpTimeout: httpTimeout ?? this.httpTimeout,
        maxLocalChunks: maxLocalChunks ?? this.maxLocalChunks,
        maxCloudResults: maxCloudResults ?? this.maxCloudResults,
        hybridRiskThreshold: hybridRiskThreshold ?? this.hybridRiskThreshold,
        enableCircuitBreaker: enableCircuitBreaker ?? this.enableCircuitBreaker,
        circuitBreakerThreshold:
            circuitBreakerThreshold ?? this.circuitBreakerThreshold,
        circuitBreakerResetDuration:
            circuitBreakerResetDuration ?? this.circuitBreakerResetDuration,
      );
}

// ============================================================================
// CIRCUIT BREAKER
// ============================================================================

/// Simple circuit breaker implementation for resilient backend calls.
///
/// The circuit breaker prevents cascading failures by temporarily
/// blocking requests after a threshold of failures is reached.
class _CircuitBreaker {
  final int failureThreshold;
  final Duration resetDuration;

  int _failureCount = 0;
  DateTime? _lastFailureTime;
  bool _isOpen = false;

  _CircuitBreaker({
    required this.failureThreshold,
    required this.resetDuration,
  });

  /// Whether the circuit is currently open (blocking requests).
  bool get isOpen {
    if (!_isOpen) return false;

    // Check if enough time has passed to reset
    if (_lastFailureTime != null &&
        DateTime.now().difference(_lastFailureTime!) > resetDuration) {
      _reset();
      return false;
    }

    return true;
  }

  /// Records a successful call, resetting the failure count.
  void recordSuccess() {
    _failureCount = 0;
    _isOpen = false;
  }

  /// Records a failed call, potentially opening the circuit.
  void recordFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();

    if (_failureCount >= failureThreshold) {
      _isOpen = true;
      debugPrint('[CircuitBreaker] Circuit opened after $_failureCount failures');
    }
  }

  void _reset() {
    _failureCount = 0;
    _isOpen = false;
    debugPrint('[CircuitBreaker] Circuit reset after cooldown');
  }
}

// ============================================================================
// ENUMS
// ============================================================================

// ============================================================================
// ENUMS
// ============================================================================

/// Specifies the preferred RAG source for context retrieval.
///
/// The hybrid RAG system can fetch context from multiple sources.
/// This enum controls which sources are queried.
enum RAGSource {
  /// Use only the local RAG stack (Isar + Cactus).
  /// Ideal for offline operation or privacy-sensitive queries.
  localOnly,

  /// Use only the cloud RAG stack (Neo4j GraphRAG + Claude).
  /// Provides access to the full knowledge graph but requires connectivity.
  cloudOnly,

  /// Automatically select based on connectivity, risk score, and complexity.
  /// This is the recommended default for most use cases.
  auto,

  /// Query both local and cloud sources, merging results.
  /// Provides maximum coverage but has higher latency.
  hybrid;

  /// Whether this source requires network connectivity.
  bool get requiresNetwork => this == cloudOnly || this == hybrid;

  /// Whether this source can operate offline.
  bool get supportsOffline => this == localOnly || this == auto;
}

// ============================================================================
// VALUE OBJECTS
// ============================================================================

/// Result from Neo4j GraphRAG backend.
///
/// Represents either a successful result with context, entities, and relationships,
/// or a failure with an error message. Use factory constructors for creation.
@immutable
class GraphRAGResult {
  /// Retrieved context text for LLM augmentation.
  final String context;

  /// Source attributions for the retrieved context.
  final List<String> sources;

  /// Entities found relevant to the query.
  final List<GraphEntity> entities;

  /// Relationships between relevant entities.
  final List<GraphRelationship> relationships;

  /// Confidence score of the retrieval (0.0 - 1.0).
  final double confidence;

  /// Whether the query was successful.
  final bool success;

  /// Error message if the query failed.
  final String? error;

  const GraphRAGResult._({
    required this.context,
    required this.sources,
    required this.entities,
    required this.relationships,
    required this.confidence,
    required this.success,
    this.error,
  });

  /// Creates an empty successful result (no context found).
  factory GraphRAGResult.empty() => const GraphRAGResult._(
        context: '',
        sources: [],
        entities: [],
        relationships: [],
        confidence: 0.0,
        success: true,
      );

  /// Creates a failed result with the given error.
  factory GraphRAGResult.failure(String error) => GraphRAGResult._(
        context: '',
        sources: [],
        entities: [],
        relationships: [],
        confidence: 0.0,
        success: false,
        error: error,
      );

  /// Parses a [GraphRAGResult] from a JSON response.
  ///
  /// This method is defensive and handles malformed responses gracefully.
  factory GraphRAGResult.fromJson(Map<String, dynamic> json) {
    try {
      final success = json['success'] as bool? ?? true;

      if (!success) {
        return GraphRAGResult.failure(
          _parseString(json['error'], defaultValue: 'Unknown error'),
        );
      }

      return GraphRAGResult._(
        context: _parseString(json['context'], defaultValue: ''),
        sources: _parseStringList(json['sources']),
        entities: _parseList<GraphEntity>(
          json['entities'],
          (e) => GraphEntity.fromJson(e as Map<String, dynamic>),
        ),
        relationships: _parseList<GraphRelationship>(
          json['relationships'],
          (r) => GraphRelationship.fromJson(r as Map<String, dynamic>),
        ),
        confidence: _parseDouble(json['confidence'], defaultValue: 0.5),
        success: true,
      );
    } catch (e, st) {
      debugPrint('[GraphRAGResult] Parse error: $e\n$st');
      return GraphRAGResult.failure('Failed to parse response: $e');
    }
  }

  /// Whether any context was retrieved.
  bool get hasContext => context.isNotEmpty;

  /// Whether this result contains an error.
  bool get isFailure => !success;
}

/// Represents an entity from the Neo4j knowledge graph.
///
/// Entities are the nodes in the medical knowledge graph, representing
/// concepts like symptoms, diseases, drugs, and procedures.
@immutable
class GraphEntity {
  /// Unique identifier in the knowledge graph.
  final String id;

  /// Entity type/label (e.g., "Symptom", "Disease", "Drug").
  final String type;

  /// Human-readable name.
  final String name;

  /// Additional properties associated with this entity.
  final Map<String, dynamic> properties;

  const GraphEntity({
    required this.id,
    required this.type,
    required this.name,
    this.properties = const {},
  });

  /// Creates a [GraphEntity] from a JSON map.
  ///
  /// Handles missing or null fields gracefully with sensible defaults.
  factory GraphEntity.fromJson(Map<String, dynamic> json) {
    return GraphEntity(
      id: _parseString(json['id'], defaultValue: ''),
      type: _parseString(json['type'], defaultValue: 'Unknown'),
      name: _parseString(json['name'], defaultValue: ''),
      properties: _parseMap(json['properties']),
    );
  }

  /// Converts this entity to a JSON-serializable map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'name': name,
        'properties': properties,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GraphEntity &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => 'GraphEntity($type: $name)';
}

/// Represents a relationship between entities in the knowledge graph.
///
/// Relationships encode medical knowledge like "Symptom INDICATES Disease"
/// or "Drug TREATS Condition".
@immutable
class GraphRelationship {
  /// Relationship type (e.g., "INDICATES", "TREATS", "CONTRAINDICATED").
  final String type;

  /// ID of the source entity.
  final String sourceId;

  /// ID of the target entity.
  final String targetId;

  /// Name of the source entity (for display).
  final String sourceName;

  /// Name of the target entity (for display).
  final String targetName;

  /// Additional properties on this relationship.
  final Map<String, dynamic> properties;

  const GraphRelationship({
    required this.type,
    required this.sourceId,
    required this.targetId,
    required this.sourceName,
    required this.targetName,
    this.properties = const {},
  });

  /// Creates a [GraphRelationship] from a JSON map.
  factory GraphRelationship.fromJson(Map<String, dynamic> json) {
    return GraphRelationship(
      type: _parseString(json['type'], defaultValue: 'RELATED_TO'),
      sourceId: _parseString(json['source_id'], defaultValue: ''),
      targetId: _parseString(json['target_id'], defaultValue: ''),
      sourceName: _parseString(json['source_name'], defaultValue: ''),
      targetName: _parseString(json['target_name'], defaultValue: ''),
      properties: _parseMap(json['properties']),
    );
  }

  /// Human-readable description of this relationship.
  String get description => '$sourceName -[$type]-> $targetName';

  /// Converts this relationship to a JSON-serializable map.
  Map<String, dynamic> toJson() => {
        'type': type,
        'source_id': sourceId,
        'target_id': targetId,
        'source_name': sourceName,
        'target_name': targetName,
        'properties': properties,
      };

  @override
  String toString() => 'GraphRelationship($description)';
}

/// Combined RAG context from both local and cloud sources.
///
/// This class aggregates results from multiple RAG sources and provides
/// formatted output suitable for LLM prompts.
@immutable
class HybridRAGContext {
  /// Context retrieved from local RAG (Isar).
  final String localContext;

  /// Context retrieved from cloud GraphRAG (Neo4j).
  final String cloudContext;

  /// Pre-combined context string.
  final String combinedContext;

  /// Source attributions from local RAG.
  final List<String> localAttributions;

  /// Source attributions from cloud RAG.
  final List<String> cloudAttributions;

  /// Entities from the knowledge graph.
  final List<GraphEntity> graphEntities;

  /// Relationships from the knowledge graph.
  final List<GraphRelationship> graphRelationships;

  /// Which RAG source(s) were used.
  final RAGSource sourceUsed;

  /// Whether the device was online during retrieval.
  final bool isOnline;

  /// Time taken to fetch the context.
  final Duration fetchDuration;

  /// Risk score that influenced source selection (if applicable).
  final double? riskScore;

  const HybridRAGContext({
    required this.localContext,
    required this.cloudContext,
    required this.combinedContext,
    required this.localAttributions,
    required this.cloudAttributions,
    required this.graphEntities,
    required this.graphRelationships,
    required this.sourceUsed,
    required this.isOnline,
    required this.fetchDuration,
    this.riskScore,
  });

  /// Creates an empty context (no results found).
  factory HybridRAGContext.empty({
    required RAGSource sourceUsed,
    required bool isOnline,
    required Duration fetchDuration,
  }) =>
      HybridRAGContext(
        localContext: '',
        cloudContext: '',
        combinedContext: '',
        localAttributions: const [],
        cloudAttributions: const [],
        graphEntities: const [],
        graphRelationships: const [],
        sourceUsed: sourceUsed,
        isOnline: isOnline,
        fetchDuration: fetchDuration,
      );

  /// All source attributions combined (local + cloud).
  List<String> get allAttributions => [
        ...localAttributions,
        ...cloudAttributions,
      ];

  /// Whether any context was retrieved from any source.
  bool get hasContext => localContext.isNotEmpty || cloudContext.isNotEmpty;

  /// Total number of sources across all RAG backends.
  int get sourceCount => localAttributions.length + cloudAttributions.length;

  /// Maximum number of relationships to include in formatted prompt.
  static const int _kMaxRelationshipsInPrompt = 10;

  /// Formats the context for inclusion in an LLM prompt.
  ///
  /// The output includes clear section headers and source attributions
  /// to enable proper citation in the model's response.
  String get formattedForPrompt {
    if (!hasContext) return '';

    final buffer = StringBuffer();
    const divider = '═══════════════════════════════════════════════════════════════';

    if (localContext.isNotEmpty) {
      buffer.writeln(divider);
      buffer.writeln('📱 LOCAL MEDICAL KNOWLEDGE (Offline-Available):');
      buffer.writeln(divider);
      buffer.writeln(localContext);
      if (localAttributions.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('Sources: ${localAttributions.join(", ")}');
      }
      buffer.writeln();
    }

    if (cloudContext.isNotEmpty) {
      buffer.writeln(divider);
      buffer.writeln('☁️ CLOUD KNOWLEDGE GRAPH (Neo4j GraphRAG):');
      buffer.writeln(divider);
      buffer.writeln(cloudContext);

      // Add graph relationships if available (limited to prevent overflow)
      if (graphRelationships.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('📊 Medical Relationships:');
        for (final rel in graphRelationships.take(_kMaxRelationshipsInPrompt)) {
          buffer.writeln('  • ${rel.description}');
        }
      }

      if (cloudAttributions.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('Sources: ${cloudAttributions.join(", ")}');
      }
    }

    return buffer.toString();
  }
}

// ============================================================================
// SERVICE
// ============================================================================

/// Hybrid RAG Service for ClinixAI medical triage.
///
/// This service orchestrates retrieval-augmented generation from multiple
/// sources:
/// - **Local RAG**: KnowledgeBaseService backed by Isar for offline capability
/// - **Cloud RAG**: Neo4j GraphRAG for comprehensive medical knowledge
///
/// ## Usage
///
/// ```dart
/// final service = HybridRAGService.instance;
///
/// // Initialize with dependencies
/// await service.initialize(
///   localRAG: knowledgeBaseService,
///   config: HybridRAGConfig.production(backendUrl: 'https://api.clinixai.com'),
/// );
///
/// // Get RAG context for a query
/// final context = await service.getRAGContext(
///   query: 'patient with chest pain and shortness of breath',
///   source: RAGSource.auto,
///   riskScore: 0.8,
/// );
///
/// // Use context in LLM prompt
/// final prompt = '''
/// ${context.formattedForPrompt}
///
/// Based on the above medical knowledge, analyze the patient's symptoms.
/// ''';
/// ```
class HybridRAGService {
  // Singleton implementation
  static HybridRAGService? _instance;

  /// Returns the singleton instance of [HybridRAGService].
  static HybridRAGService get instance => _instance ??= HybridRAGService._();

  /// Replaces the singleton instance (for testing only).
  @visibleForTesting
  static void setInstance(HybridRAGService instance) {
    _instance = instance;
  }

  HybridRAGService._();

  // Dependencies
  KnowledgeBaseService? _localRAG;
  http.Client? _httpClient;
  _CircuitBreaker? _circuitBreaker;

  // Configuration
  HybridRAGConfig _config = HybridRAGConfig.development();

  // State
  bool _isInitialized = false;

  /// Whether the service has been initialized.
  bool get isInitialized => _isInitialized;

  /// The current backend URL.
  String get backendUrl => _config.backendUrl;

  /// The current configuration (read-only).
  HybridRAGConfig get config => _config;

  /// Initializes the service with required dependencies.
  ///
  /// This method must be called before any other operations.
  ///
  /// Parameters:
  /// - [localRAG]: The local knowledge base service for offline RAG.
  /// - [config]: Optional configuration (defaults to development config).
  /// - [backendUrl]: Optional backend URL (deprecated, use config instead).
  /// - [httpClient]: Optional HTTP client for testing/mocking.
  ///
  /// Throws [RAGException] if initialization fails.
  Future<void> initialize({
    required KnowledgeBaseService localRAG,
    HybridRAGConfig? config,
    String? backendUrl,
    http.Client? httpClient,
  }) async {
    if (_isInitialized) {
      debugPrint('[HybridRAG] Already initialized, skipping');
      return;
    }

    _localRAG = localRAG;

    // Support legacy backendUrl parameter
    if (config != null) {
      _config = config;
    } else if (backendUrl != null) {
      _config = HybridRAGConfig(backendUrl: backendUrl);
    }

    _httpClient = httpClient ?? http.Client();

    // Initialize circuit breaker if enabled
    if (_config.enableCircuitBreaker) {
      _circuitBreaker = _CircuitBreaker(
        failureThreshold: _config.circuitBreakerThreshold,
        resetDuration: _config.circuitBreakerResetDuration,
      );
    }

    _isInitialized = true;

    debugPrint('[HybridRAG] Initialized');
    debugPrint('  - Local RAG: ${_localRAG?.isInitialized == true ? "Ready" : "Not Ready"}');
    debugPrint('  - Backend URL: ${_config.backendUrl}');
    debugPrint('  - Circuit Breaker: ${_config.enableCircuitBreaker ? "Enabled" : "Disabled"}');
  }

  /// Configure the backend URL (e.g., for production).
  ///
  /// @deprecated Use [initialize] with [HybridRAGConfig] instead.
  void configureBackend(String url) {
    _config = _config.copyWith(backendUrl: url);
    debugPrint('[HybridRAG] Backend configured: ${_config.backendUrl}');
  }

  /// Check if device is online.
  Future<bool> _checkConnectivity() async {
    try {
      final result = await Connectivity().checkConnectivity();
      return result != ConnectivityResult.none;
    } catch (e) {
      debugPrint('[HybridRAG] Connectivity check failed: $e');
      return false;
    }
  }

  /// Retrieves RAG context for a medical query.
  ///
  /// This is the primary method for getting augmented context from the
  /// knowledge bases. It intelligently selects and queries the appropriate
  /// RAG sources based on the [source] parameter and current conditions.
  ///
  /// Parameters:
  /// - [query]: The medical query (symptoms, conditions, etc.)
  /// - [source]: Which RAG source(s) to query (default: auto)
  /// - [maxLocalChunks]: Override for maximum local chunks
  /// - [maxCloudResults]: Override for maximum cloud results
  /// - [riskScore]: Risk score to influence source selection in auto mode
  ///
  /// Returns a [HybridRAGContext] containing the retrieved context and metadata.
  ///
  /// Example:
  /// ```dart
  /// final context = await service.getRAGContext(
  ///   query: 'severe chest pain radiating to left arm',
  ///   source: RAGSource.hybrid,
  ///   riskScore: 0.9,
  /// );
  /// ```
  Future<HybridRAGContext> getRAGContext({
    required String query,
    RAGSource source = RAGSource.auto,
    int? maxLocalChunks,
    int? maxCloudResults,
    double? riskScore,
  }) async {
    _ensureInitialized();

    final stopwatch = Stopwatch()..start();
    final isOnline = await _checkConnectivity();

    // Determine actual source based on preference and connectivity
    final actualSource = _resolveRAGSource(
      requested: source,
      isOnline: isOnline,
      riskScore: riskScore,
    );

    String localContext = '';
    String cloudContext = '';
    List<String> localAttributions = [];
    List<String> cloudAttributions = [];
    List<GraphEntity> graphEntities = [];
    List<GraphRelationship> graphRelationships = [];

    // Fetch from local RAG if needed
    if (_shouldQueryLocal(actualSource)) {
      final localResult = await _fetchLocalRAGSafe(
        query,
        maxLocalChunks ?? _config.maxLocalChunks,
      );
      localContext = localResult.context;
      localAttributions = localResult.attributions;
    }

    // Fetch from cloud GraphRAG if needed
    if (_shouldQueryCloud(actualSource) && isOnline) {
      final cloudResult = await _fetchCloudGraphRAGSafe(
        query,
        maxCloudResults ?? _config.maxCloudResults,
      );

      if (cloudResult.success) {
        cloudContext = cloudResult.context;
        cloudAttributions = cloudResult.sources;
        graphEntities = cloudResult.entities;
        graphRelationships = cloudResult.relationships;
      }
    }

    // Combine contexts
    final combinedContext = _combineContexts(localContext, cloudContext);

    stopwatch.stop();

    return HybridRAGContext(
      localContext: localContext,
      cloudContext: cloudContext,
      combinedContext: combinedContext,
      localAttributions: localAttributions,
      cloudAttributions: cloudAttributions,
      graphEntities: graphEntities,
      graphRelationships: graphRelationships,
      sourceUsed: actualSource,
      isOnline: isOnline,
      fetchDuration: stopwatch.elapsed,
      riskScore: riskScore,
    );
  }

  /// Resolve the effective RAG source based on conditions.
  RAGSource _resolveRAGSource({
    required RAGSource requested,
    required bool isOnline,
    double? riskScore,
  }) {
    // Cloud-only requires connectivity
    if (requested == RAGSource.cloudOnly && !isOnline) {
      debugPrint('[HybridRAG] Cloud requested but offline, falling back to local');
      return RAGSource.localOnly;
    }

    // Auto mode selection
    if (requested == RAGSource.auto) {
      if (!isOnline) return RAGSource.localOnly;
      if (riskScore != null && riskScore >= _config.hybridRiskThreshold) {
        return RAGSource.hybrid;
      }
      return RAGSource.hybrid; // Default to hybrid when online
    }

    return requested;
  }

  bool _shouldQueryLocal(RAGSource source) =>
      source == RAGSource.localOnly ||
      source == RAGSource.hybrid ||
      source == RAGSource.auto;

  bool _shouldQueryCloud(RAGSource source) =>
      source == RAGSource.cloudOnly || source == RAGSource.hybrid;

  /// Fetch context from local Isar-based RAG (safe - catches errors).
  Future<RAGContext> _fetchLocalRAGSafe(String query, int maxChunks) async {
    if (_localRAG == null || !_localRAG!.isInitialized) {
      return RAGContext(
        context: '',
        attributions: [],
        chunkCount: 0,
        estimatedTokens: 0,
      );
    }

    try {
      return await _localRAG!.getContextForQuery(
        query,
        maxChunks: maxChunks,
      );
    } catch (e) {
      debugPrint('[HybridRAG] Local RAG error: $e');
      return RAGContext(
        context: '',
        attributions: [],
        chunkCount: 0,
        estimatedTokens: 0,
      );
    }
  }

  /// Fetch context from Neo4j GraphRAG backend (safe - catches errors).
  Future<GraphRAGResult> _fetchCloudGraphRAGSafe(
    String query,
    int maxResults,
  ) async {
    // Check circuit breaker
    if (_circuitBreaker?.isOpen == true) {
      debugPrint('[HybridRAG] Circuit breaker open, skipping cloud RAG');
      return GraphRAGResult.failure('Circuit breaker open');
    }

    try {
      final client = _httpClient ?? http.Client();
      final response = await client
          .post(
            Uri.parse('${_config.backendUrl}/graphrag/query'),
            headers: _defaultHeaders,
            body: jsonEncode({
              'query': query,
              'max_results': maxResults,
              'include_relationships': true,
              'include_entities': true,
            }),
          )
          .timeout(_config.httpTimeout);

      if (response.statusCode == 200) {
        _circuitBreaker?.recordSuccess();
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return GraphRAGResult.fromJson(data);
      } else {
        _circuitBreaker?.recordFailure();
        debugPrint('[HybridRAG] Cloud RAG error: ${response.statusCode}');
        return GraphRAGResult.failure('HTTP ${response.statusCode}');
      }
    } catch (e) {
      _circuitBreaker?.recordFailure();
      debugPrint('[HybridRAG] Cloud RAG exception: $e');
      return GraphRAGResult.failure(e.toString());
    }
  }

  Map<String, String> get _defaultHeaders => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

  /// Combine local and cloud contexts intelligently.
  String _combineContexts(String localContext, String cloudContext) {
    if (localContext.isEmpty && cloudContext.isEmpty) {
      return '';
    }

    if (localContext.isEmpty) return cloudContext;
    if (cloudContext.isEmpty) return localContext;

    // Combine with clear separation
    return '''
=== LOCAL MEDICAL KNOWLEDGE ===
$localContext

=== CLOUD KNOWLEDGE GRAPH ===
$cloudContext
''';
  }

  /// Searches for medical entities in the knowledge graph.
  ///
  /// Parameters:
  /// - [query]: Search query
  /// - [entityType]: Optional filter by entity type (e.g., "Disease", "Symptom")
  /// - [limit]: Maximum results to return
  ///
  /// Returns a list of matching entities, or empty list if offline/error.
  Future<List<GraphEntity>> searchEntities({
    required String query,
    String? entityType,
    int limit = 20,
  }) async {
    _ensureInitialized();

    if (!await _checkConnectivity()) {
      debugPrint('[HybridRAG] searchEntities: Offline, returning empty');
      return [];
    }

    if (_circuitBreaker?.isOpen == true) {
      debugPrint('[HybridRAG] searchEntities: Circuit open, returning empty');
      return [];
    }

    try {
      final client = _httpClient ?? http.Client();
      final response = await client
          .post(
            Uri.parse('${_config.backendUrl}/graphrag/search/entities'),
            headers: _defaultHeaders,
            body: jsonEncode({
              'query': query,
              'entity_type': entityType,
              'limit': limit,
            }),
          )
          .timeout(_config.httpTimeout);

      if (response.statusCode == 200) {
        _circuitBreaker?.recordSuccess();
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final entities = data['entities'] as List<dynamic>? ?? [];
        return entities
            .map((e) => GraphEntity.fromJson(e as Map<String, dynamic>))
            .toList();
      } else {
        _circuitBreaker?.recordFailure();
        debugPrint('[HybridRAG] Entity search failed: ${response.statusCode}');
      }
    } catch (e, st) {
      _circuitBreaker?.recordFailure();
      debugPrint('[HybridRAG] Entity search error: $e\n$st');
    }

    return [];
  }

  /// Retrieves red flags for given symptoms from the knowledge graph.
  ///
  /// Falls back to local knowledge base if cloud is unavailable.
  Future<List<String>> getRedFlagsForSymptoms(List<String> symptoms) async {
    _ensureInitialized();

    if (symptoms.isEmpty) return [];

    // Try cloud first
    if (await _checkConnectivity() && _circuitBreaker?.isOpen != true) {
      try {
        final client = _httpClient ?? http.Client();
        final response = await client
            .post(
              Uri.parse('${_config.backendUrl}/graphrag/red-flags'),
              headers: _defaultHeaders,
              body: jsonEncode({'symptoms': symptoms}),
            )
            .timeout(_config.httpTimeout);

        if (response.statusCode == 200) {
          _circuitBreaker?.recordSuccess();
          final data = jsonDecode(response.body) as Map<String, dynamic>;
          final redFlags = data['red_flags'] as List<dynamic>? ?? [];
          return redFlags.map((f) => f.toString()).toList();
        } else {
          _circuitBreaker?.recordFailure();
        }
      } catch (e) {
        _circuitBreaker?.recordFailure();
        debugPrint('[HybridRAG] Red flags query error: $e');
      }
    }

    // Fallback to local
    return _getLocalRedFlags(symptoms);
  }

  /// Get red flags from local knowledge base.
  Future<List<String>> _getLocalRedFlags(List<String> symptoms) async {
    if (_localRAG == null || !_localRAG!.isInitialized) {
      return [];
    }

    try {
      // Search for red flags in local knowledge base
      final results = await _localRAG!.search(
        'red flags warning signs ${symptoms.join(" ")}',
        limit: 5,
        documentType: RAGDocumentType.emergencyProtocol,
      );

      // Extract red flags from results using pattern matching
      final redFlags = <String>{};
      final patterns = [
        'red flag',
        'warning',
        'seek immediate',
        'emergency',
        'critical',
        'life-threatening',
      ];

      for (final result in results) {
        final lines = result.chunk.content.split('\n');
        for (final line in lines) {
          final lowerLine = line.toLowerCase();
          if (patterns.any((p) => lowerLine.contains(p))) {
            redFlags.add(line.trim());
          }
        }
      }

      return redFlags.take(10).toList();
    } catch (e) {
      debugPrint('[HybridRAG] Local red flags error: $e');
      return [];
    }
  }

  /// Retrieves possible conditions for given symptoms.
  Future<List<Map<String, dynamic>>> getPossibleConditions(
    List<String> symptoms,
  ) async {
    _ensureInitialized();

    if (symptoms.isEmpty || !await _checkConnectivity()) return [];

    if (_circuitBreaker?.isOpen == true) return [];

    try {
      final client = _httpClient ?? http.Client();
      final response = await client
          .post(
            Uri.parse('${_config.backendUrl}/graphrag/conditions'),
            headers: _defaultHeaders,
            body: jsonEncode({'symptoms': symptoms}),
          )
          .timeout(_config.httpTimeout);

      if (response.statusCode == 200) {
        _circuitBreaker?.recordSuccess();
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final conditions = data['conditions'] as List<dynamic>? ?? [];
        return conditions.cast<Map<String, dynamic>>();
      } else {
        _circuitBreaker?.recordFailure();
      }
    } catch (e) {
      _circuitBreaker?.recordFailure();
      debugPrint('[HybridRAG] Conditions query error: $e');
    }

    return [];
  }

  /// Retrieves drug interactions from the knowledge graph.
  Future<List<Map<String, dynamic>>> getDrugInteractions(
    List<String> drugs,
  ) async {
    _ensureInitialized();

    if (drugs.length < 2 || !await _checkConnectivity()) return [];

    if (_circuitBreaker?.isOpen == true) return [];

    try {
      final client = _httpClient ?? http.Client();
      final response = await client
          .post(
            Uri.parse('${_config.backendUrl}/graphrag/drug-interactions'),
            headers: _defaultHeaders,
            body: jsonEncode({'drugs': drugs}),
          )
          .timeout(_config.httpTimeout);

      if (response.statusCode == 200) {
        _circuitBreaker?.recordSuccess();
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final interactions = data['interactions'] as List<dynamic>? ?? [];
        return interactions.cast<Map<String, dynamic>>();
      } else {
        _circuitBreaker?.recordFailure();
      }
    } catch (e) {
      _circuitBreaker?.recordFailure();
      debugPrint('[HybridRAG] Drug interactions query error: $e');
    }

    return [];
  }

  /// Runs RAG-enhanced triage using Claude Sonnet via OpenRouter.
  ///
  /// This is a convenience method that:
  /// 1. Fetches RAG context from configured sources
  /// 2. Calls OpenRouter with the augmented prompt
  ///
  /// For more control, use [getRAGContext] and call OpenRouter directly.
  Future<OpenRouterResult> runRAGEnhancedTriage({
    required String symptoms,
    RAGSource ragSource = RAGSource.auto,
    int? patientAge,
    String? patientGender,
    List<String>? medicalHistory,
    Map<String, dynamic>? vitalSigns,
    double? riskScore,
    double? complexityScore,
    String? escalationReason,
  }) async {
    _ensureInitialized();

    // Fetch RAG context
    final ragContext = await getRAGContext(
      query: symptoms,
      source: ragSource,
      riskScore: riskScore,
    );

    // If no context found and we're offline, return error
    if (!ragContext.hasContext && !ragContext.isOnline) {
      return OpenRouterResult.failure(
        'No medical knowledge available offline for this query',
      );
    }

    // Use OpenRouter with Claude Sonnet for RAG-enhanced inference
    final openRouter = OpenRouterService.instance;

    if (!openRouter.isConfigured) {
      return OpenRouterResult.failure(
        'OpenRouter not configured. Please set API key.',
      );
    }

    return openRouter.runRAGTriageInference(
      symptoms: symptoms,
      ragContext: ragContext.formattedForPrompt,
      patientAge: patientAge,
      patientGender: patientGender,
      medicalHistory: medicalHistory,
      vitalSigns: vitalSigns,
      riskScore: riskScore,
      complexityScore: complexityScore,
      escalationReason: escalationReason,
      sourceAttributions: ragContext.allAttributions,
    );
  }

  /// Checks the health of the GraphRAG backend.
  Future<Map<String, dynamic>> checkBackendHealth() async {
    try {
      final client = _httpClient ?? http.Client();
      final response = await client
          .get(Uri.parse('${_config.backendUrl}/health'))
          .timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return {
          'status': 'healthy',
          'url': _config.backendUrl,
          'data': jsonDecode(response.body),
        };
      } else {
        return {
          'status': 'unhealthy',
          'url': _config.backendUrl,
          'statusCode': response.statusCode,
        };
      }
    } catch (e) {
      return {
        'status': 'unreachable',
        'url': _config.backendUrl,
        'error': e.toString(),
      };
    }
  }

  /// Gets statistics about the knowledge graph.
  Future<Map<String, dynamic>> getGraphStats() async {
    if (!await _checkConnectivity()) {
      return {'error': 'Offline'};
    }

    try {
      final client = _httpClient ?? http.Client();
      final response = await client
          .get(Uri.parse('${_config.backendUrl}/graphrag/stats'))
          .timeout(_config.httpTimeout);

      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[HybridRAG] Stats query error: $e');
    }

    return {'error': 'Failed to fetch stats'};
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw const RAGNotInitializedException();
    }
  }

  /// Disposes resources held by the service.
  void dispose() {
    _httpClient?.close();
    _httpClient = null;
    _localRAG = null;
    _circuitBreaker = null;
    _isInitialized = false;
    debugPrint('[HybridRAG] Disposed');
  }
}

// ============================================================================
// UTILITY FUNCTIONS
// ============================================================================

/// Safely parses a string from dynamic JSON value.
String _parseString(dynamic value, {required String defaultValue}) {
  if (value == null) return defaultValue;
  if (value is String) return value;
  return value.toString();
}

/// Safely parses a double from dynamic JSON value.
double _parseDouble(dynamic value, {required double defaultValue}) {
  if (value == null) return defaultValue;
  if (value is double) return value;
  if (value is int) return value.toDouble();
  if (value is String) return double.tryParse(value) ?? defaultValue;
  return defaultValue;
}

/// Safely parses a Map from dynamic JSON value.
Map<String, dynamic> _parseMap(dynamic value) {
  if (value == null) return {};
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return {};
}

/// Safely parses a List<String> from dynamic JSON value.
List<String> _parseStringList(dynamic value) {
  if (value == null) return [];
  if (value is List) {
    return value
        .map((e) => e?.toString() ?? '')
        .where((s) => s.isNotEmpty)
        .toList();
  }
  return [];
}

/// Safely parses a typed list from dynamic JSON value.
List<T> _parseList<T>(dynamic value, T Function(dynamic) parser) {
  if (value == null) return [];
  if (value is! List) return [];

  final results = <T>[];
  for (final item in value) {
    try {
      results.add(parser(item));
    } catch (e) {
      debugPrint('[HybridRAG] Parse list item error: $e');
    }
  }
  return results;
}
