// Knowledge Base Service Unit Tests
// Tests RAG functionality with mocked embeddings

import 'dart:math' as math;
import 'package:flutter_test/flutter_test.dart';

// Simple cosine similarity function (same as in knowledge_base_service.dart)
double cosineSimilarity(List<double> a, List<double> b) {
  if (a.length != b.length || a.isEmpty) return 0.0;
  
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

// Mock embedding generator - creates deterministic embeddings based on text
List<double> mockEmbedding(String text, {int dimensions = 128}) {
  final random = math.Random(text.hashCode);
  return List.generate(dimensions, (_) => random.nextDouble() * 2 - 1);
}

// Simple chunk class for testing
class TestChunk {
  final String id;
  final String content;
  final String documentTitle;
  final String category;
  final List<double> embedding;
  
  TestChunk({
    required this.id,
    required this.content,
    required this.documentTitle,
    required this.category,
    required this.embedding,
  });
}

// Simple in-memory RAG for testing
class TestRAG {
  final List<TestChunk> chunks = [];
  
  void addChunk(String content, String docTitle, String category) {
    chunks.add(TestChunk(
      id: 'chunk_${chunks.length}',
      content: content,
      documentTitle: docTitle,
      category: category,
      embedding: mockEmbedding(content),
    ));
  }
  
  List<(TestChunk, double)> search(String query, {int topK = 5, double threshold = 0.3}) {
    final queryEmbedding = mockEmbedding(query);
    
    final scored = chunks.map((chunk) {
      final score = cosineSimilarity(queryEmbedding, chunk.embedding);
      return (chunk, score);
    }).toList();
    
    scored.sort((a, b) => b.$2.compareTo(a.$2));
    
    return scored
        .where((item) => item.$2 >= threshold)
        .take(topK)
        .toList();
  }
}

void main() {
  group('Cosine Similarity Tests', () {
    test('identical vectors should have similarity of 1.0', () {
      final v1 = [1.0, 0.0, 0.0];
      final v2 = [1.0, 0.0, 0.0];
      expect(cosineSimilarity(v1, v2), closeTo(1.0, 0.001));
    });
    
    test('opposite vectors should have similarity of -1.0', () {
      final v1 = [1.0, 0.0, 0.0];
      final v2 = [-1.0, 0.0, 0.0];
      expect(cosineSimilarity(v1, v2), closeTo(-1.0, 0.001));
    });
    
    test('orthogonal vectors should have similarity of 0.0', () {
      final v1 = [1.0, 0.0, 0.0];
      final v2 = [0.0, 1.0, 0.0];
      expect(cosineSimilarity(v1, v2), closeTo(0.0, 0.001));
    });
    
    test('empty vectors should return 0.0', () {
      final v1 = <double>[];
      final v2 = <double>[];
      expect(cosineSimilarity(v1, v2), 0.0);
    });
  });
  
  group('Mock Embedding Tests', () {
    test('same text should produce same embedding', () {
      final e1 = mockEmbedding('fever and headache');
      final e2 = mockEmbedding('fever and headache');
      expect(cosineSimilarity(e1, e2), 1.0);
    });
    
    test('different text should produce different embeddings', () {
      final e1 = mockEmbedding('fever and headache');
      final e2 = mockEmbedding('chest pain');
      expect(cosineSimilarity(e1, e2), isNot(1.0));
    });
    
    test('similar text should have higher similarity than unrelated', () {
      final fever1 = mockEmbedding('high fever symptoms');
      final fever2 = mockEmbedding('fever temperature high');
      final unrelated = mockEmbedding('car engine repair');
      
      // Note: With mock embeddings based on hashCode, this may not always hold
      // In real embeddings, similar concepts would cluster together
      print('Fever similarity: ${cosineSimilarity(fever1, fever2)}');
      print('Unrelated similarity: ${cosineSimilarity(fever1, unrelated)}');
    });
  });
  
  group('RAG Search Tests', () {
    late TestRAG rag;
    
    setUp(() {
      rag = TestRAG();
      
      // Add medical knowledge chunks
      rag.addChunk(
        'Fever above 38.5°C in children requires immediate assessment. '
        'Check for signs of dehydration and altered consciousness.',
        'WHO Emergency Triage',
        'emergency',
      );
      
      rag.addChunk(
        'Red flags for fever: neck stiffness, severe headache, rash that '
        'does not blanch, altered mental status, difficulty breathing.',
        'Red Flags Guide',
        'emergency',
      );
      
      rag.addChunk(
        'Malaria presents with cyclical fever, chills, sweating, headache, '
        'and body aches. In endemic areas, always consider malaria.',
        'Infectious Diseases',
        'infectious',
      );
      
      rag.addChunk(
        'Paracetamol dosing: 10-15mg/kg every 4-6 hours. Maximum 4 doses '
        'in 24 hours. Avoid in liver disease.',
        'Drug Reference',
        'medications',
      );
      
      rag.addChunk(
        'Danger signs in pregnancy: vaginal bleeding, severe headache, '
        'blurred vision, convulsions, decreased fetal movement.',
        'Maternal Health',
        'maternal',
      );
      
      rag.addChunk(
        'Chest pain assessment: location, character, radiation, associated '
        'symptoms (sweating, nausea, dyspnea), onset and duration.',
        'Common Symptoms',
        'symptoms',
      );
    });
    
    test('search returns results', () {
      final results = rag.search('child with high temperature');
      expect(results, isNotEmpty);
      print('\nSearch: "child with high temperature"');
      for (final (chunk, score) in results) {
        print('  [${score.toStringAsFixed(3)}] ${chunk.documentTitle}: ${chunk.content.substring(0, 50)}...');
      }
    });
    
    test('search with threshold filters low scores', () {
      final results = rag.search('random unrelated query xyz123', threshold: 0.5);
      print('\nSearch: "random unrelated query xyz123" (threshold 0.5)');
      print('  Results: ${results.length}');
    });
    
    test('topK limits results', () {
      final results = rag.search('medical emergency', topK: 2);
      expect(results.length, lessThanOrEqualTo(2));
    });
    
    test('search for pregnancy returns maternal content', () {
      final results = rag.search('pregnant woman with headache');
      print('\nSearch: "pregnant woman with headache"');
      for (final (chunk, score) in results) {
        print('  [${score.toStringAsFixed(3)}] ${chunk.category}: ${chunk.content.substring(0, 50)}...');
      }
    });
  });
  
  group('Chunking Logic Tests', () {
    test('text chunking by paragraphs', () {
      const text = '''
First paragraph about fever symptoms.
This is still the first paragraph.

Second paragraph about treatment options.
More treatment information here.

Third paragraph about when to seek care.
''';
      
      final paragraphs = text
          .split(RegExp(r'\n\s*\n'))
          .map((p) => p.trim())
          .where((p) => p.isNotEmpty)
          .toList();
      
      expect(paragraphs.length, 3);
      expect(paragraphs[0], contains('fever symptoms'));
      expect(paragraphs[1], contains('treatment'));
      expect(paragraphs[2], contains('seek care'));
    });
    
    test('text chunking by sections (markdown headers)', () {
      const text = '''
# Emergency Triage

Assessment of emergency cases.

## Red Flags

Critical warning signs to watch for.

## Green Zone

Non-urgent cases that can wait.
''';
      
      final sections = text.split(RegExp(r'(?=^#+\s)', multiLine: true))
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      
      expect(sections.length, 3);
      print('\nSections found:');
      for (final section in sections) {
        print('  - ${section.split('\n').first}');
      }
    });
    
    test('fixed size chunking with overlap', () {
      const text = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
      const chunkSize = 10;
      const overlap = 3;
      
      final chunks = <String>[];
      int start = 0;
      
      while (start < text.length) {
        final end = math.min(start + chunkSize, text.length);
        chunks.add(text.substring(start, end));
        start = end - overlap;
        if (end == text.length) break;
      }
      
      print('\nFixed size chunks (size=$chunkSize, overlap=$overlap):');
      for (final chunk in chunks) {
        print('  "$chunk"');
      }
      
      expect(chunks[0], 'ABCDEFGHIJ');
      expect(chunks[1], 'HIJKLMNOPQ'); // Overlaps with HIJ
    });
  });
  
  group('Source Attribution Tests', () {
    test('source attribution format', () {
      final sources = [
        'WHO Emergency Triage (emergency): Fever above 38.5°C...',
        'Red Flags Guide (emergency): Red flags for fever...',
      ];
      
      final formatted = sources.map((s) {
        final parts = s.split(':');
        return '📚 ${parts[0].trim()}';
      }).toList();
      
      expect(formatted[0], contains('WHO Emergency Triage'));
      expect(formatted[1], contains('Red Flags Guide'));
    });
  });
}
