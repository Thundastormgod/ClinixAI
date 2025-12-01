// Copyright 2024 ClinixAI. All rights reserved.
// SPDX-License-Identifier: MIT
//
// RAG Document Collection
// Stores medical knowledge documents with embeddings for retrieval
// Supports semantic search via vector similarity

import 'dart:convert';
import 'package:isar/isar.dart';

part 'local_rag_document.g.dart';

/// RAG Document Types for categorization
enum RAGDocumentType {
  medicalGuideline,    // WHO, CDC guidelines
  drugReference,       // Drug interactions, dosages
  symptomReference,    // Symptom-condition mappings
  emergencyProtocol,   // Emergency response protocols
  patientHistory,      // Patient-specific history
  localContext,        // Regional health info
  custom,              // User-added documents
}

/// Isar collection for persisted RAG documents
/// 
/// Stores medical knowledge documents with metadata for:
/// - Efficient retrieval
/// - Source attribution
/// - Version control
/// - Category-based filtering
@collection
class LocalRAGDocument {
  Id id = Isar.autoIncrement;

  /// Unique identifier for the document
  @Index(unique: true, replace: true)
  late String documentId;

  /// Human-readable title
  late String title;

  /// Source of the document (e.g., "WHO Emergency Triage Guidelines 2024")
  late String source;

  /// Document type for categorization
  @Enumerated(EnumType.name)
  late RAGDocumentType documentType;

  /// Original full content (for reference)
  late String fullContent;

  /// Version string for updates
  String? version;

  /// Language code (e.g., "en", "sw" for Swahili)
  String language = 'en';

  /// When document was added
  @Index()
  late DateTime addedAt;

  /// When document was last updated
  late DateTime updatedAt;

  /// Whether this is a system document (bundled with app)
  bool isSystemDocument = true;

  /// File path if imported from local storage
  String? originalFilePath;

  /// Number of chunks this document was split into
  int chunkCount = 0;

  /// Total character count
  int characterCount = 0;

  /// SHA-256 hash of content for deduplication
  String? contentHash;

  /// Tags for additional categorization
  List<String> tags = [];

  /// Priority for retrieval (higher = more important)
  int priority = 0;

  // Factory constructors
  static LocalRAGDocument create({
    required String documentId,
    required String title,
    required String source,
    required RAGDocumentType documentType,
    required String fullContent,
    String? version,
    String language = 'en',
    bool isSystemDocument = true,
    String? originalFilePath,
    List<String> tags = const [],
    int priority = 0,
  }) {
    return LocalRAGDocument()
      ..documentId = documentId
      ..title = title
      ..source = source
      ..documentType = documentType
      ..fullContent = fullContent
      ..version = version
      ..language = language
      ..isSystemDocument = isSystemDocument
      ..originalFilePath = originalFilePath
      ..tags = tags
      ..priority = priority
      ..characterCount = fullContent.length
      ..addedAt = DateTime.now()
      ..updatedAt = DateTime.now();
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'documentId': documentId,
    'title': title,
    'source': source,
    'documentType': documentType.name,
    'version': version,
    'language': language,
    'addedAt': addedAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'isSystemDocument': isSystemDocument,
    'chunkCount': chunkCount,
    'characterCount': characterCount,
    'tags': tags,
    'priority': priority,
  };
}

/// Isar collection for document chunks with embeddings
/// 
/// Each document is split into semantic chunks for:
/// - Better retrieval accuracy
/// - Manageable context windows
/// - Source attribution per chunk
@collection
class LocalRAGChunk {
  Id id = Isar.autoIncrement;

  /// Reference to parent document
  @Index()
  late String documentId;

  /// Chunk index within the document
  late int chunkIndex;

  /// The actual text content of this chunk
  late String content;

  /// Start position in original document
  late int startPosition;

  /// End position in original document
  late int endPosition;

  /// Section/heading this chunk belongs to
  String? sectionTitle;

  /// Embedding vector as JSON string (List<double>)
  /// Stored as string since Isar doesn't support List<double> natively
  String? embeddingJson;

  /// Embedding model used (for compatibility checking)
  String? embeddingModel;

  /// When embedding was generated
  DateTime? embeddingGeneratedAt;

  /// Semantic similarity score (populated during search)
  @ignore
  double similarityScore = 0.0;

  // Computed properties
  List<double>? get embedding {
    if (embeddingJson == null) return null;
    final list = jsonDecode(embeddingJson!) as List;
    return list.map((e) => (e as num).toDouble()).toList();
  }

  set embedding(List<double>? value) {
    embeddingJson = value != null ? jsonEncode(value) : null;
  }

  int get contentLength => content.length;

  /// Create a chunk from document
  static LocalRAGChunk create({
    required String documentId,
    required int chunkIndex,
    required String content,
    required int startPosition,
    required int endPosition,
    String? sectionTitle,
    List<double>? embedding,
    String? embeddingModel,
  }) {
    final chunk = LocalRAGChunk()
      ..documentId = documentId
      ..chunkIndex = chunkIndex
      ..content = content
      ..startPosition = startPosition
      ..endPosition = endPosition
      ..sectionTitle = sectionTitle
      ..embeddingModel = embeddingModel;
    
    if (embedding != null) {
      chunk.embedding = embedding;
      chunk.embeddingGeneratedAt = DateTime.now();
    }
    
    return chunk;
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'documentId': documentId,
    'chunkIndex': chunkIndex,
    'content': content,
    'sectionTitle': sectionTitle,
    'contentLength': contentLength,
    'hasEmbedding': embeddingJson != null,
    'embeddingModel': embeddingModel,
  };
}

/// Search result with source attribution
class RAGSearchResult {
  final LocalRAGChunk chunk;
  final LocalRAGDocument? document;
  final double similarity;
  final String attribution;

  RAGSearchResult({
    required this.chunk,
    this.document,
    required this.similarity,
    required this.attribution,
  });

  /// Format attribution for display
  String get formattedAttribution {
    if (document != null) {
      return '${document!.source} - ${chunk.sectionTitle ?? "Section ${chunk.chunkIndex + 1}"}';
    }
    return attribution;
  }

  Map<String, dynamic> toJson() => {
    'content': chunk.content,
    'similarity': similarity,
    'source': document?.source,
    'title': document?.title,
    'section': chunk.sectionTitle,
    'documentType': document?.documentType.name,
  };
}
