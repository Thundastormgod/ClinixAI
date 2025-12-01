// Copyright 2024 ClinixAI. All rights reserved.
// SPDX-License-Identifier: MIT
//
// ClinixAI Knowledge Base Service
// Manages medical knowledge documents for RAG-enhanced triage
//
// Architecture:
// ┌─────────────────────────────────────────────────────────────────┐
// │                   KnowledgeBaseService                          │
// ├─────────────────────────────────────────────────────────────────┤
// │  DOCUMENT PIPELINE                                              │
// │  1. Ingest → 2. Chunk → 3. Embed → 4. Store → 5. Search       │
// ├─────────────────────────────────────────────────────────────────┤
// │  STORAGE                 │  SEARCH                              │
// │  ├─ Isar Database        │  ├─ Semantic (Embeddings)            │
// │  ├─ LocalRAGDocument     │  ├─ Keyword (Fallback)               │
// │  └─ LocalRAGChunk        │  └─ Cosine Similarity                │
// └─────────────────────────────────────────────────────────────────┘
//
// Design Patterns:
// - Singleton: Single instance for consistent state
// - Strategy: Multiple chunking strategies
// - Template Method: Document processing pipeline
// - Facade: Simple interface for complex operations

import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:isar/isar.dart';
import 'package:meta/meta.dart';

import '../database/collections/local_rag_document.dart';
import 'cactus_service.dart';

// ============================================================================
// CHUNKING CONFIGURATION
// ============================================================================

/// Chunking strategy for document processing.
///
/// Different strategies work better for different document types:
/// - [fixedSize]: Best for uniform documents
/// - [sentence]: Best for conversational content
/// - [paragraph]: Best for structured text
/// - [section]: Best for Markdown with headers
/// - [semantic]: Most accurate but requires LLM
enum ChunkingStrategy {
  /// Fixed size chunks (default 512 chars with 50 char overlap).
  fixedSize,

  /// Sentence-based chunking.
  sentence,

  /// Paragraph-based chunking (split on double newlines).
  paragraph,

  /// Section-based (split on markdown headers).
  section,

  /// Semantic chunking (uses LLM to identify break points).
  semantic,
}

/// Configuration for document chunking.
///
/// Controls how documents are split into searchable chunks.
/// Use predefined configurations for common use cases:
/// - [ChunkConfig.medical]: Optimized for medical documents
/// - [ChunkConfig.compact]: For constrained memory environments
@immutable
class ChunkConfig {
  /// The chunking strategy to use.
  final ChunkingStrategy strategy;

  /// Maximum size of each chunk in characters.
  final int maxChunkSize;

  /// Number of characters to overlap between chunks.
  final int overlapSize;

  /// Minimum chunk size (smaller chunks are discarded).
  final int minChunkSize;

  const ChunkConfig({
    this.strategy = ChunkingStrategy.paragraph,
    this.maxChunkSize = 512,
    this.overlapSize = 50,
    this.minChunkSize = 100,
  });

  /// Configuration optimized for medical documents.
  static const medical = ChunkConfig(
    strategy: ChunkingStrategy.section,
    maxChunkSize: 800,
    overlapSize: 100,
    minChunkSize: 150,
  );

  /// Compact configuration for constrained environments.
  static const compact = ChunkConfig(
    strategy: ChunkingStrategy.fixedSize,
    maxChunkSize: 256,
    overlapSize: 32,
    minChunkSize: 64,
  );
}

// ============================================================================
// KNOWLEDGE BASE SERVICE
// ============================================================================

/// Knowledge Base Service for ClinixAI.
///
/// Provides comprehensive document management and semantic search:
/// - **Document Ingestion**: Add documents with intelligent chunking
/// - **Embedding Generation**: Generate embeddings using local LLM
/// - **Semantic Search**: Find relevant context using cosine similarity
/// - **Pre-loaded Content**: Bundled WHO guidelines and medical references
///
/// ## Usage
/// ```dart
/// final kb = KnowledgeBaseService.instance;
/// await kb.initialize(isar: database, cactusService: cactus);
/// await kb.loadBundledKnowledgeBase();
///
/// final results = await kb.search('malaria symptoms', limit: 5);
/// ```
///
/// ## Document Types
/// The service supports various document types for categorization:
/// - Medical guidelines (WHO, CDC)
/// - Drug references
/// - Emergency protocols
/// - Patient history (per-patient context)
class KnowledgeBaseService {
  // ──────────────────────────────────────────────────────────────────
  // SINGLETON
  // ──────────────────────────────────────────────────────────────────

  static KnowledgeBaseService? _instance;

  /// Global singleton instance.
  static KnowledgeBaseService get instance =>
      _instance ??= KnowledgeBaseService._();

  KnowledgeBaseService._();

  // ──────────────────────────────────────────────────────────────────
  // DEPENDENCIES
  // ──────────────────────────────────────────────────────────────────

  Isar? _isar;
  CactusService? _cactusService;

  // ──────────────────────────────────────────────────────────────────
  // STATE
  // ──────────────────────────────────────────────────────────────────

  bool _isInitialized = false;
  bool _isLoading = false;
  int _documentCount = 0;
  int _chunkCount = 0;

  // ──────────────────────────────────────────────────────────────────
  // CALLBACKS
  // ──────────────────────────────────────────────────────────────────

  /// Callback for loading progress updates.
  void Function(String status, double? progress)? onLoadProgress;

  /// Callback for error notifications.
  void Function(String error)? onError;

  // ──────────────────────────────────────────────────────────────────
  // PUBLIC GETTERS
  // ──────────────────────────────────────────────────────────────────

  /// Whether the service has been initialized.
  bool get isInitialized => _isInitialized;

  /// Whether documents are currently being loaded.
  bool get isLoading => _isLoading;

  /// Total number of documents in the knowledge base.
  int get documentCount => _documentCount;

  /// Total number of chunks across all documents.
  int get chunkCount => _chunkCount;

  // ──────────────────────────────────────────────────────────────────
  // INITIALIZATION
  // ──────────────────────────────────────────────────────────────────

  /// Initializes the knowledge base service.
  Future<void> initialize({
    required Isar isar,
    required CactusService cactusService,
  }) async {
    if (_isInitialized) return;

    _isar = isar;
    _cactusService = cactusService;
    
    // Load stats
    _documentCount = await _isar!.localRAGDocuments.count();
    _chunkCount = await _isar!.localRAGChunks.count();
    
    _isInitialized = true;
    _notify('Knowledge base initialized: $_documentCount documents, $_chunkCount chunks');
  }

  /// Load bundled medical knowledge base on first run
  Future<void> loadBundledKnowledgeBase({bool forceReload = false}) async {
    _ensureInitialized();
    
    if (_isLoading) return;
    _isLoading = true;

    try {
      // Check if already loaded
      final existingCount = await _isar!.localRAGDocuments
          .filter()
          .isSystemDocumentEqualTo(true)
          .count();

      if (existingCount > 0 && !forceReload) {
        _notify('Knowledge base already loaded ($_documentCount documents)');
        _isLoading = false;
        return;
      }

      if (forceReload) {
        // Clear existing system documents
        await _isar!.writeTxn(() async {
          final systemDocs = await _isar!.localRAGDocuments
              .filter()
              .isSystemDocumentEqualTo(true)
              .findAll();
          
          for (final doc in systemDocs) {
            await _isar!.localRAGChunks
                .filter()
                .documentIdEqualTo(doc.documentId)
                .deleteAll();
          }
          
          await _isar!.localRAGDocuments
              .filter()
              .isSystemDocumentEqualTo(true)
              .deleteAll();
        });
      }

      // Load bundled documents from assets
      await _loadBundledDocuments();

      // Update stats
      _documentCount = await _isar!.localRAGDocuments.count();
      _chunkCount = await _isar!.localRAGChunks.count();

      _notify('Knowledge base loaded: $_documentCount documents, $_chunkCount chunks');
    } catch (e) {
      onError?.call('Failed to load knowledge base: $e');
      rethrow;
    } finally {
      _isLoading = false;
    }
  }

  /// Load bundled medical documents from assets
  Future<void> _loadBundledDocuments() async {
    // List of bundled medical documents
    final bundledDocs = [
      _BundledDoc(
        assetPath: 'assets/knowledge/who_emergency_triage.md',
        documentId: 'who_etat_v1',
        title: 'WHO Emergency Triage Assessment and Treatment',
        source: 'World Health Organization (WHO)',
        type: RAGDocumentType.emergencyProtocol,
        version: '2024',
        priority: 10,
        tags: ['emergency', 'triage', 'pediatric', 'who'],
      ),
      _BundledDoc(
        assetPath: 'assets/knowledge/common_symptoms.md',
        documentId: 'symptoms_v1',
        title: 'Common Symptom Assessment Guide',
        source: 'ClinixAI Medical Team',
        type: RAGDocumentType.symptomReference,
        version: '1.0',
        priority: 8,
        tags: ['symptoms', 'assessment', 'primary-care'],
      ),
      _BundledDoc(
        assetPath: 'assets/knowledge/drug_interactions.md',
        documentId: 'drugs_v1',
        title: 'Essential Drug Interactions Reference',
        source: 'WHO Essential Medicines List',
        type: RAGDocumentType.drugReference,
        version: '2024',
        priority: 9,
        tags: ['drugs', 'interactions', 'medications'],
      ),
      _BundledDoc(
        assetPath: 'assets/knowledge/red_flags.md',
        documentId: 'redflags_v1',
        title: 'Medical Red Flags - Warning Signs',
        source: 'ClinixAI Emergency Protocols',
        type: RAGDocumentType.emergencyProtocol,
        version: '1.0',
        priority: 10,
        tags: ['emergency', 'red-flags', 'critical'],
      ),
      _BundledDoc(
        assetPath: 'assets/knowledge/maternal_health.md',
        documentId: 'maternal_v1',
        title: 'Maternal and Child Health Guidelines',
        source: 'WHO/UNICEF Guidelines',
        type: RAGDocumentType.medicalGuideline,
        version: '2024',
        priority: 8,
        tags: ['maternal', 'pediatric', 'pregnancy', 'childbirth'],
      ),
      _BundledDoc(
        assetPath: 'assets/knowledge/infectious_diseases.md',
        documentId: 'infectious_v1',
        title: 'Common Infectious Diseases in Africa',
        source: 'Africa CDC Guidelines',
        type: RAGDocumentType.medicalGuideline,
        version: '2024',
        priority: 9,
        tags: ['malaria', 'typhoid', 'tb', 'hiv', 'cholera'],
      ),
    ];

    int processed = 0;
    for (final doc in bundledDocs) {
      try {
        onLoadProgress?.call('Loading ${doc.title}...', processed / bundledDocs.length);
        
        // Try to load from assets
        String content;
        try {
          content = await rootBundle.loadString(doc.assetPath);
        } catch (e) {
          // Asset not found - skip but don't fail
          debugPrint('[KnowledgeBase] Asset not found: ${doc.assetPath}');
          processed++;
          continue;
        }

        await addDocument(
          documentId: doc.documentId,
          title: doc.title,
          source: doc.source,
          documentType: doc.type,
          content: content,
          version: doc.version,
          isSystemDocument: true,
          tags: doc.tags,
          priority: doc.priority,
          generateEmbeddings: true,
        );

        processed++;
      } catch (e) {
        debugPrint('[KnowledgeBase] Failed to load ${doc.title}: $e');
        // Continue with other documents
      }
    }

    onLoadProgress?.call('Knowledge base ready', 1.0);
  }

  /// Add a document to the knowledge base
  Future<LocalRAGDocument> addDocument({
    required String documentId,
    required String title,
    required String source,
    required RAGDocumentType documentType,
    required String content,
    String? version,
    String language = 'en',
    bool isSystemDocument = false,
    String? filePath,
    List<String> tags = const [],
    int priority = 0,
    bool generateEmbeddings = true,
    ChunkConfig chunkConfig = const ChunkConfig(),
  }) async {
    _ensureInitialized();

    // Create document
    final doc = LocalRAGDocument.create(
      documentId: documentId,
      title: title,
      source: source,
      documentType: documentType,
      fullContent: content,
      version: version,
      language: language,
      isSystemDocument: isSystemDocument,
      originalFilePath: filePath,
      tags: tags,
      priority: priority,
    );

    // Generate content hash for deduplication
    doc.contentHash = md5.convert(utf8.encode(content)).toString();

    // Check for existing document with same ID
    final existing = await _isar!.localRAGDocuments
        .filter()
        .documentIdEqualTo(documentId)
        .findFirst();

    if (existing != null && existing.contentHash == doc.contentHash) {
      // Same content - skip
      return existing;
    }

    // Chunk the document
    final chunks = _chunkDocument(content, documentId, chunkConfig);
    doc.chunkCount = chunks.length;

    // Generate embeddings if enabled and LLM is loaded
    if (generateEmbeddings && _cactusService?.isLMLoaded == true) {
      _notify('Generating embeddings for ${chunks.length} chunks...');
      
      int embeddedCount = 0;
      for (final chunk in chunks) {
        try {
          final embedding = await _cactusService!.generateEmbedding(chunk.content);
          chunk.embedding = embedding;
          chunk.embeddingModel = _cactusService!.currentModelName ?? 'unknown';
          embeddedCount++;
          
          if (embeddedCount % 10 == 0) {
            onLoadProgress?.call(
              'Embedding chunk $embeddedCount/${chunks.length}',
              embeddedCount / chunks.length,
            );
          }
        } catch (e) {
          debugPrint('[KnowledgeBase] Failed to embed chunk: $e');
        }
      }
    }

    // Save to database
    await _isar!.writeTxn(() async {
      // Delete existing chunks if updating
      if (existing != null) {
        await _isar!.localRAGChunks
            .filter()
            .documentIdEqualTo(documentId)
            .deleteAll();
        await _isar!.localRAGDocuments.delete(existing.id);
      }

      // Save document
      await _isar!.localRAGDocuments.put(doc);
      
      // Save chunks
      await _isar!.localRAGChunks.putAll(chunks);
    });

    // Update stats
    _documentCount = await _isar!.localRAGDocuments.count();
    _chunkCount = await _isar!.localRAGChunks.count();

    _notify('Added document: $title (${chunks.length} chunks)');
    return doc;
  }

  /// Chunk a document using the specified strategy
  List<LocalRAGChunk> _chunkDocument(
    String content,
    String documentId,
    ChunkConfig config,
  ) {
    switch (config.strategy) {
      case ChunkingStrategy.fixedSize:
        return _chunkFixedSize(content, documentId, config);
      case ChunkingStrategy.sentence:
        return _chunkBySentence(content, documentId, config);
      case ChunkingStrategy.paragraph:
        return _chunkByParagraph(content, documentId, config);
      case ChunkingStrategy.section:
        return _chunkBySection(content, documentId, config);
      case ChunkingStrategy.semantic:
        // Fall back to paragraph for now
        return _chunkByParagraph(content, documentId, config);
    }
  }

  /// Fixed-size chunking with overlap
  List<LocalRAGChunk> _chunkFixedSize(
    String content,
    String documentId,
    ChunkConfig config,
  ) {
    final chunks = <LocalRAGChunk>[];
    int position = 0;
    int chunkIndex = 0;

    while (position < content.length) {
      int endPos = math.min(position + config.maxChunkSize, content.length);
      
      // Try to end at a word boundary
      if (endPos < content.length) {
        final lastSpace = content.lastIndexOf(' ', endPos);
        if (lastSpace > position + config.minChunkSize) {
          endPos = lastSpace;
        }
      }

      final chunkContent = content.substring(position, endPos).trim();
      
      if (chunkContent.length >= config.minChunkSize) {
        chunks.add(LocalRAGChunk.create(
          documentId: documentId,
          chunkIndex: chunkIndex++,
          content: chunkContent,
          startPosition: position,
          endPosition: endPos,
        ));
      }

      // Move position with overlap
      position = endPos - config.overlapSize;
      if (position <= chunks.last.startPosition) {
        position = endPos; // Prevent infinite loop
      }
    }

    return chunks;
  }

  /// Sentence-based chunking
  List<LocalRAGChunk> _chunkBySentence(
    String content,
    String documentId,
    ChunkConfig config,
  ) {
    final chunks = <LocalRAGChunk>[];
    
    // Split by sentence endings
    final sentencePattern = RegExp(r'(?<=[.!?])\s+');
    final sentences = content.split(sentencePattern);
    
    StringBuffer currentChunk = StringBuffer();
    int startPos = 0;
    int chunkIndex = 0;

    for (final sentence in sentences) {
      if (currentChunk.length + sentence.length > config.maxChunkSize &&
          currentChunk.length >= config.minChunkSize) {
        // Save current chunk
        chunks.add(LocalRAGChunk.create(
          documentId: documentId,
          chunkIndex: chunkIndex++,
          content: currentChunk.toString().trim(),
          startPosition: startPos,
          endPosition: startPos + currentChunk.length,
        ));
        
        startPos += currentChunk.length;
        currentChunk = StringBuffer();
      }
      
      currentChunk.write(sentence);
      currentChunk.write(' ');
    }

    // Add remaining content
    if (currentChunk.length >= config.minChunkSize) {
      chunks.add(LocalRAGChunk.create(
        documentId: documentId,
        chunkIndex: chunkIndex,
        content: currentChunk.toString().trim(),
        startPosition: startPos,
        endPosition: content.length,
      ));
    }

    return chunks;
  }

  /// Paragraph-based chunking
  List<LocalRAGChunk> _chunkByParagraph(
    String content,
    String documentId,
    ChunkConfig config,
  ) {
    final chunks = <LocalRAGChunk>[];
    
    // Split by double newlines (paragraphs)
    final paragraphs = content.split(RegExp(r'\n\s*\n'));
    
    StringBuffer currentChunk = StringBuffer();
    int startPos = 0;
    int chunkIndex = 0;

    for (final paragraph in paragraphs) {
      final trimmed = paragraph.trim();
      if (trimmed.isEmpty) continue;

      if (currentChunk.length + trimmed.length > config.maxChunkSize &&
          currentChunk.length >= config.minChunkSize) {
        // Save current chunk
        chunks.add(LocalRAGChunk.create(
          documentId: documentId,
          chunkIndex: chunkIndex++,
          content: currentChunk.toString().trim(),
          startPosition: startPos,
          endPosition: startPos + currentChunk.length,
        ));
        
        startPos += currentChunk.length;
        currentChunk = StringBuffer();
      }
      
      currentChunk.writeln(trimmed);
      currentChunk.writeln();
    }

    // Add remaining content
    if (currentChunk.length >= config.minChunkSize) {
      chunks.add(LocalRAGChunk.create(
        documentId: documentId,
        chunkIndex: chunkIndex,
        content: currentChunk.toString().trim(),
        startPosition: startPos,
        endPosition: content.length,
      ));
    }

    return chunks;
  }

  /// Section-based chunking (for Markdown with headers)
  List<LocalRAGChunk> _chunkBySection(
    String content,
    String documentId,
    ChunkConfig config,
  ) {
    final chunks = <LocalRAGChunk>[];
    
    // Match markdown headers
    final headerPattern = RegExp(r'^(#{1,4})\s+(.+)$', multiLine: true);
    final matches = headerPattern.allMatches(content).toList();
    
    if (matches.isEmpty) {
      // No headers - fall back to paragraph chunking
      return _chunkByParagraph(content, documentId, config);
    }

    int chunkIndex = 0;
    
    for (int i = 0; i < matches.length; i++) {
      final match = matches[i];
      // Header level available via match.group(1)!.length if needed
      final headerText = match.group(2)!;
      
      final startPos = match.start;
      final endPos = i < matches.length - 1 ? matches[i + 1].start : content.length;
      
      var sectionContent = content.substring(startPos, endPos).trim();
      
      // If section is too long, sub-chunk it
      if (sectionContent.length > config.maxChunkSize) {
        final subChunks = _chunkByParagraph(sectionContent, documentId, config);
        for (final subChunk in subChunks) {
          subChunk.sectionTitle = headerText;
          subChunk.chunkIndex = chunkIndex++;
          chunks.add(subChunk);
        }
      } else if (sectionContent.length >= config.minChunkSize) {
        chunks.add(LocalRAGChunk.create(
          documentId: documentId,
          chunkIndex: chunkIndex++,
          content: sectionContent,
          startPosition: startPos,
          endPosition: endPos,
          sectionTitle: headerText,
        ));
      }
    }

    // Handle content before first header
    if (matches.isNotEmpty && matches.first.start > 0) {
      final preamble = content.substring(0, matches.first.start).trim();
      if (preamble.length >= config.minChunkSize) {
        chunks.insert(0, LocalRAGChunk.create(
          documentId: documentId,
          chunkIndex: 0,
          content: preamble,
          startPosition: 0,
          endPosition: matches.first.start,
          sectionTitle: 'Introduction',
        ));
        // Re-index
        for (int i = 1; i < chunks.length; i++) {
          chunks[i].chunkIndex = i;
        }
      }
    }

    return chunks;
  }

  /// Search the knowledge base with semantic similarity
  Future<List<RAGSearchResult>> search(
    String query, {
    int limit = 5,
    double minSimilarity = 0.3,
    RAGDocumentType? documentType,
    List<String>? tags,
  }) async {
    _ensureInitialized();

    if (_cactusService?.isLMLoaded != true) {
      return _keywordSearch(query, limit: limit, documentType: documentType, tags: tags);
    }

    try {
      // Generate query embedding
      final queryEmbedding = await _cactusService!.generateEmbedding(query);

      // Get all chunks with embeddings
      List<LocalRAGChunk> chunks = await _isar!.localRAGChunks
          .filter()
          .embeddingJsonIsNotNull()
          .findAll();
      
      // Filter by document type if specified
      if (documentType != null) {
        final matchingDocs = await _isar!.localRAGDocuments
            .filter()
            .documentTypeEqualTo(documentType)
            .findAll();
        final docIds = matchingDocs.map((d) => d.documentId).toSet();
        chunks = chunks.where((c) => docIds.contains(c.documentId)).toList();
      }

      // Calculate similarity for each chunk
      final results = <RAGSearchResult>[];
      
      for (final chunk in chunks) {
        final chunkEmbedding = chunk.embedding;
        if (chunkEmbedding == null) continue;

        final similarity = _cosineSimilarity(queryEmbedding, chunkEmbedding);
        
        if (similarity >= minSimilarity) {
          final doc = await _isar!.localRAGDocuments
              .filter()
              .documentIdEqualTo(chunk.documentId)
              .findFirst();

          results.add(RAGSearchResult(
            chunk: chunk..similarityScore = similarity,
            document: doc,
            similarity: similarity,
            attribution: doc?.source ?? chunk.documentId,
          ));
        }
      }

      // Sort by similarity (descending) and priority
      results.sort((a, b) {
        final simCompare = b.similarity.compareTo(a.similarity);
        if (simCompare != 0) return simCompare;
        return (b.document?.priority ?? 0).compareTo(a.document?.priority ?? 0);
      });

      return results.take(limit).toList();
    } catch (e) {
      debugPrint('[KnowledgeBase] Semantic search failed: $e');
      return _keywordSearch(query, limit: limit, documentType: documentType, tags: tags);
    }
  }

  /// Fallback keyword search when embeddings unavailable
  Future<List<RAGSearchResult>> _keywordSearch(
    String query, {
    int limit = 5,
    RAGDocumentType? documentType,
    List<String>? tags,
  }) async {
    final keywords = query.toLowerCase().split(RegExp(r'\s+'));
    final results = <RAGSearchResult>[];

    List<LocalRAGDocument> docs;
    if (documentType != null) {
      docs = await _isar!.localRAGDocuments
          .filter()
          .documentTypeEqualTo(documentType)
          .findAll();
      // Sort in memory since filter() doesn't chain with sort
      docs.sort((a, b) => b.priority.compareTo(a.priority));
    } else {
      docs = await _isar!.localRAGDocuments
          .where()
          .sortByPriorityDesc()
          .findAll();
    }

    for (final doc in docs) {
      final chunks = await _isar!.localRAGChunks
          .filter()
          .documentIdEqualTo(doc.documentId)
          .findAll();

      for (final chunk in chunks) {
        final lowerContent = chunk.content.toLowerCase();
        int matchCount = keywords.where((k) => lowerContent.contains(k)).length;
        
        if (matchCount > 0) {
          final score = matchCount / keywords.length;
          results.add(RAGSearchResult(
            chunk: chunk..similarityScore = score,
            document: doc,
            similarity: score,
            attribution: doc.source,
          ));
        }
      }
    }

    results.sort((a, b) => b.similarity.compareTo(a.similarity));
    return results.take(limit).toList();
  }

  /// Calculate cosine similarity between two vectors
  double _cosineSimilarity(List<double> a, List<double> b) {
    if (a.length != b.length) return 0.0;

    double dotProduct = 0.0;
    double normA = 0.0;
    double normB = 0.0;

    for (int i = 0; i < a.length; i++) {
      dotProduct += a[i] * b[i];
      normA += a[i] * a[i];
      normB += b[i] * b[i];
    }

    if (normA == 0 || normB == 0) return 0.0;
    return dotProduct / (math.sqrt(normA) * math.sqrt(normB));
  }

  /// Generate RAG-augmented context for a query
  Future<RAGContext> getContextForQuery(
    String query, {
    int maxChunks = 5,
    int maxTokens = 2000,
  }) async {
    final results = await search(query, limit: maxChunks);
    
    final contextParts = <String>[];
    final attributions = <String>[];
    int estimatedTokens = 0;

    for (final result in results) {
      // Rough token estimate (1 token ≈ 4 chars)
      final chunkTokens = result.chunk.content.length ~/ 4;
      
      if (estimatedTokens + chunkTokens > maxTokens) break;

      contextParts.add(result.chunk.content);
      attributions.add(result.formattedAttribution);
      estimatedTokens += chunkTokens;
    }

    return RAGContext(
      context: contextParts.join('\n\n---\n\n'),
      attributions: attributions,
      chunkCount: contextParts.length,
      estimatedTokens: estimatedTokens,
    );
  }

  /// Get all documents
  Future<List<LocalRAGDocument>> getAllDocuments() async {
    _ensureInitialized();
    return await _isar!.localRAGDocuments.where().sortByPriorityDesc().findAll();
  }

  /// Get documents by type
  Future<List<LocalRAGDocument>> getDocumentsByType(RAGDocumentType type) async {
    _ensureInitialized();
    return await _isar!.localRAGDocuments
        .filter()
        .documentTypeEqualTo(type)
        .sortByPriorityDesc()
        .findAll();
  }

  /// Delete a document and its chunks
  Future<bool> deleteDocument(String documentId) async {
    _ensureInitialized();

    return await _isar!.writeTxn(() async {
      // Delete chunks
      await _isar!.localRAGChunks
          .filter()
          .documentIdEqualTo(documentId)
          .deleteAll();

      // Delete document
      final deletedDocs = await _isar!.localRAGDocuments
          .filter()
          .documentIdEqualTo(documentId)
          .deleteAll();

      _documentCount = await _isar!.localRAGDocuments.count();
      _chunkCount = await _isar!.localRAGChunks.count();

      return deletedDocs > 0;
    });
  }

  /// Regenerate embeddings for all chunks
  Future<void> regenerateAllEmbeddings() async {
    _ensureInitialized();

    if (_cactusService?.isLMLoaded != true) {
      throw StateError('LLM must be loaded to generate embeddings');
    }

    final chunks = await _isar!.localRAGChunks.where().findAll();
    int processed = 0;

    for (final chunk in chunks) {
      try {
        final embedding = await _cactusService!.generateEmbedding(chunk.content);
        chunk.embedding = embedding;
        chunk.embeddingModel = _cactusService!.currentModelName ?? 'unknown';
        chunk.embeddingGeneratedAt = DateTime.now();

        await _isar!.writeTxn(() async {
          await _isar!.localRAGChunks.put(chunk);
        });

        processed++;
        if (processed % 10 == 0) {
          onLoadProgress?.call(
            'Regenerating embeddings: $processed/${chunks.length}',
            processed / chunks.length,
          );
        }
      } catch (e) {
        debugPrint('[KnowledgeBase] Failed to regenerate embedding: $e');
      }
    }

    _notify('Regenerated embeddings for $processed chunks');
  }

  /// Get knowledge base statistics
  Future<KnowledgeBaseStats> getStats() async {
    _ensureInitialized();

    final docs = await _isar!.localRAGDocuments.where().findAll();
    final chunks = await _isar!.localRAGChunks.where().findAll();

    final byType = <RAGDocumentType, int>{};
    int totalChars = 0;
    int chunksWithEmbeddings = 0;

    for (final doc in docs) {
      byType[doc.documentType] = (byType[doc.documentType] ?? 0) + 1;
      totalChars += doc.characterCount;
    }

    for (final chunk in chunks) {
      if (chunk.embeddingJson != null) chunksWithEmbeddings++;
    }

    return KnowledgeBaseStats(
      documentCount: docs.length,
      chunkCount: chunks.length,
      totalCharacters: totalChars,
      chunksWithEmbeddings: chunksWithEmbeddings,
      documentsByType: byType,
      systemDocuments: docs.where((d) => d.isSystemDocument).length,
      customDocuments: docs.where((d) => !d.isSystemDocument).length,
    );
  }

  void _ensureInitialized() {
    if (!_isInitialized) {
      throw StateError('KnowledgeBaseService not initialized. Call initialize() first.');
    }
  }

  void _notify(String status) {
    debugPrint('[KnowledgeBase] $status');
    onLoadProgress?.call(status, null);
  }
}

/// Helper class for bundled documents
class _BundledDoc {
  final String assetPath;
  final String documentId;
  final String title;
  final String source;
  final RAGDocumentType type;
  final String version;
  final int priority;
  final List<String> tags;

  _BundledDoc({
    required this.assetPath,
    required this.documentId,
    required this.title,
    required this.source,
    required this.type,
    required this.version,
    required this.priority,
    required this.tags,
  });
}

// ============================================================================
// RESULT TYPES
// ============================================================================

/// RAG context with attributions.
///
/// Contains the assembled context from multiple chunks along with
/// source attributions for transparency and citation.
@immutable
class RAGContext {
  /// The combined context text from all matched chunks.
  final String context;

  /// List of source attributions for the context.
  final List<String> attributions;

  /// Number of chunks included in the context.
  final int chunkCount;

  /// Estimated token count for the context.
  final int estimatedTokens;

  const RAGContext({
    required this.context,
    required this.attributions,
    required this.chunkCount,
    required this.estimatedTokens,
  });

  /// Whether any context was found.
  bool get hasContext => context.isNotEmpty;

  /// Formats attributions for display in responses.
  String get formattedAttributions => attributions.isNotEmpty
      ? '\n\n📚 Sources:\n${attributions.map((a) => '• $a').join('\n')}'
      : '';
}

/// Knowledge base statistics.
///
/// Provides metrics about the knowledge base for monitoring and debugging.
@immutable
class KnowledgeBaseStats {
  /// Total number of documents.
  final int documentCount;

  /// Total number of chunks across all documents.
  final int chunkCount;

  /// Total character count across all documents.
  final int totalCharacters;

  /// Number of chunks that have embeddings.
  final int chunksWithEmbeddings;

  /// Document count by type.
  final Map<RAGDocumentType, int> documentsByType;

  /// Number of system (bundled) documents.
  final int systemDocuments;

  /// Number of user-added custom documents.
  final int customDocuments;

  const KnowledgeBaseStats({
    required this.documentCount,
    required this.chunkCount,
    required this.totalCharacters,
    required this.chunksWithEmbeddings,
    required this.documentsByType,
    required this.systemDocuments,
    required this.customDocuments,
  });

  /// Percentage of chunks with embeddings (0.0 - 1.0).
  double get embeddingCoverage =>
      chunkCount > 0 ? chunksWithEmbeddings / chunkCount : 0.0;

  /// Converts statistics to a JSON-serializable map.
  Map<String, dynamic> toJson() => {
        'documentCount': documentCount,
        'chunkCount': chunkCount,
        'totalCharacters': totalCharacters,
        'chunksWithEmbeddings': chunksWithEmbeddings,
        'embeddingCoverage': '${(embeddingCoverage * 100).toStringAsFixed(1)}%',
        'systemDocuments': systemDocuments,
        'customDocuments': customDocuments,
      };
}
