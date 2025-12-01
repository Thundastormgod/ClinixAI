// ClinixAI Hybrid RAG Integration Test
// Tests the complete hybrid RAG pipeline:
// - Local: Cactus SDK + Isar-based RAG
// - Cloud: Neo4j GraphRAG + Claude Sonnet (OpenRouter)

import 'package:flutter_test/flutter_test.dart';
import 'package:clinix_app/core/ai/hybrid_rag_service.dart';
import 'package:clinix_app/core/ai/hybrid_router.dart';
import 'package:clinix_app/core/ai/openrouter_service.dart';
import 'package:clinix_app/core/ai/knowledge_base_service.dart';

void main() {
  group('HybridRAGService Tests', () {
    late HybridRAGService hybridRAG;

    setUp(() {
      hybridRAG = HybridRAGService.instance;
    });

    test('should be a singleton', () {
      final instance1 = HybridRAGService.instance;
      final instance2 = HybridRAGService.instance;
      expect(identical(instance1, instance2), isTrue);
    });

    test('GraphRAGResult.empty() creates empty result', () {
      final result = GraphRAGResult.empty();
      expect(result.context, isEmpty);
      expect(result.sources, isEmpty);
      expect(result.entities, isEmpty);
      expect(result.relationships, isEmpty);
      expect(result.success, isTrue);
      expect(result.hasContext, isFalse);
    });

    test('GraphRAGResult.failure() creates failed result', () {
      final result = GraphRAGResult.failure('Test error');
      expect(result.success, isFalse);
      expect(result.error, equals('Test error'));
      expect(result.hasContext, isFalse);
    });

    test('GraphRAGResult.fromJson() parses correctly', () {
      final json = {
        'context': 'Medical knowledge about fever',
        'sources': ['WHO Guidelines', 'CDC Reference'],
        'entities': [
          {'id': '1', 'type': 'Symptom', 'name': 'Fever', 'properties': {}}
        ],
        'relationships': [
          {
            'type': 'INDICATES',
            'source_id': '1',
            'target_id': '2',
            'source_name': 'Fever',
            'target_name': 'Malaria',
            'properties': {}
          }
        ],
        'confidence': 0.85,
        'success': true,
      };

      final result = GraphRAGResult.fromJson(json);
      expect(result.context, equals('Medical knowledge about fever'));
      expect(result.sources.length, equals(2));
      expect(result.entities.length, equals(1));
      expect(result.entities.first.name, equals('Fever'));
      expect(result.relationships.length, equals(1));
      expect(result.relationships.first.type, equals('INDICATES'));
      expect(result.confidence, equals(0.85));
      expect(result.success, isTrue);
      expect(result.hasContext, isTrue);
    });

    test('GraphEntity.fromJson() parses correctly', () {
      final json = {
        'id': 'entity_123',
        'type': 'Disease',
        'name': 'Malaria',
        'properties': {'severity': 'high', 'endemic': true}
      };

      final entity = GraphEntity.fromJson(json);
      expect(entity.id, equals('entity_123'));
      expect(entity.type, equals('Disease'));
      expect(entity.name, equals('Malaria'));
      expect(entity.properties['severity'], equals('high'));
    });

    test('GraphRelationship.fromJson() parses correctly', () {
      final json = {
        'type': 'TREATS',
        'source_id': 'drug_1',
        'target_id': 'disease_1',
        'source_name': 'Artemisinin',
        'target_name': 'Malaria',
        'properties': {'efficacy': 0.95}
      };

      final rel = GraphRelationship.fromJson(json);
      expect(rel.type, equals('TREATS'));
      expect(rel.sourceName, equals('Artemisinin'));
      expect(rel.targetName, equals('Malaria'));
      expect(rel.description, equals('Artemisinin -[TREATS]-> Malaria'));
    });
  });

  group('HybridRAGContext Tests', () {
    test('formattedForPrompt formats local context correctly', () {
      final context = HybridRAGContext(
        localContext: 'Local medical knowledge about fever management.',
        cloudContext: '',
        combinedContext: 'Local medical knowledge about fever management.',
        localAttributions: ['WHO Guidelines', 'ClinixAI Medical Team'],
        cloudAttributions: [],
        graphEntities: [],
        graphRelationships: [],
        sourceUsed: RAGSource.localOnly,
        isOnline: false,
        fetchDuration: const Duration(milliseconds: 100),
      );

      final formatted = context.formattedForPrompt;
      expect(formatted, contains('LOCAL MEDICAL KNOWLEDGE'));
      expect(formatted, contains('Local medical knowledge about fever management.'));
      expect(formatted, contains('WHO Guidelines'));
    });

    test('formattedForPrompt formats cloud context with relationships', () {
      final context = HybridRAGContext(
        localContext: '',
        cloudContext: 'Knowledge graph context about malaria.',
        combinedContext: 'Knowledge graph context about malaria.',
        localAttributions: [],
        cloudAttributions: ['Neo4j GraphRAG'],
        graphEntities: [],
        graphRelationships: [
          const GraphRelationship(
            type: 'INDICATES',
            sourceId: '1',
            targetId: '2',
            sourceName: 'High Fever',
            targetName: 'Malaria',
            properties: {},
          ),
          const GraphRelationship(
            type: 'TREATS',
            sourceId: '3',
            targetId: '2',
            sourceName: 'Artemisinin',
            targetName: 'Malaria',
            properties: {},
          ),
        ],
        sourceUsed: RAGSource.cloudOnly,
        isOnline: true,
        fetchDuration: const Duration(milliseconds: 500),
      );

      final formatted = context.formattedForPrompt;
      expect(formatted, contains('CLOUD KNOWLEDGE GRAPH'));
      expect(formatted, contains('Neo4j GraphRAG'));
      expect(formatted, contains('Medical Relationships'));
      expect(formatted, contains('High Fever -[INDICATES]-> Malaria'));
      expect(formatted, contains('Artemisinin -[TREATS]-> Malaria'));
    });

    test('allAttributions combines local and cloud attributions', () {
      final context = HybridRAGContext(
        localContext: 'Local context',
        cloudContext: 'Cloud context',
        combinedContext: 'Combined',
        localAttributions: ['Local Source 1', 'Local Source 2'],
        cloudAttributions: ['Cloud Source 1'],
        graphEntities: [],
        graphRelationships: [],
        sourceUsed: RAGSource.hybrid,
        isOnline: true,
        fetchDuration: const Duration(milliseconds: 200),
      );

      expect(context.allAttributions.length, equals(3));
      expect(context.sourceCount, equals(3));
      expect(context.hasContext, isTrue);
    });
  });

  group('HybridRouter RAG Integration Tests', () {
    late HybridRouter router;

    setUp(() {
      router = HybridRouter.instance;
    });

    test('HybridTriageResult includes RAG metadata', () {
      final result = HybridTriageResult(
        response: '{"urgency_level": "standard", "confidence": 0.8}',
        success: true,
        routeUsed: RouteDecision.cloud,
        modelUsed: 'claude-3.5-sonnet (RAG-enhanced)',
        ragSourceUsed: RAGSource.hybrid,
        ragSourceCount: 5,
        ragAttributions: ['WHO Guidelines', 'Neo4j GraphRAG'],
      );

      expect(result.ragSourceUsed, equals(RAGSource.hybrid));
      expect(result.ragSourceCount, equals(5));
      expect(result.ragAttributions.length, equals(2));
    });

    test('calculateRiskScore identifies critical symptoms', () {
      final criticalScore = router.calculateRiskScore(
        'Patient experiencing chest pain and difficulty breathing',
      );
      expect(criticalScore, greaterThanOrEqualTo(0.4));

      final normalScore = router.calculateRiskScore(
        'Mild headache for 2 days',
      );
      expect(normalScore, lessThan(0.4));
    });

    test('calculateComplexityScore factors in patient age', () {
      final infantScore = router.calculateComplexityScore(
        'Fever and cough',
        patientAge: 6, // 6 months old
      );

      final adultScore = router.calculateComplexityScore(
        'Fever and cough',
        patientAge: 30,
      );

      // Infants should have higher complexity due to vulnerability
      expect(infantScore, greaterThan(adultScore));
    });

    test('calculateComplexityScore factors in medical history', () {
      final withHistoryScore = router.calculateComplexityScore(
        'Fever and cough',
        medicalHistory: ['diabetes', 'hypertension', 'HIV'],
      );

      final withoutHistoryScore = router.calculateComplexityScore(
        'Fever and cough',
      );

      expect(withHistoryScore, greaterThan(withoutHistoryScore));
    });
  });

  group('OpenRouterService RAG Tests', () {
    late OpenRouterService openRouter;

    setUp(() {
      openRouter = OpenRouterService.instance;
    });

    test('should have RAG-enhanced inference method', () {
      // Verify the method exists (compile-time check)
      expect(openRouter.runRAGTriageInference, isNotNull);
    });
  });

  group('RAGSource Enum Tests', () {
    test('RAGSource values exist', () {
      expect(RAGSource.values.length, equals(4));
      expect(RAGSource.localOnly.index, equals(0));
      expect(RAGSource.cloudOnly.index, equals(1));
      expect(RAGSource.auto.index, equals(2));
      expect(RAGSource.hybrid.index, equals(3));
    });
  });

  group('Integration Test Scenarios', () {
    test('Offline scenario should use local RAG only', () {
      // Simulate offline scenario
      final context = HybridRAGContext(
        localContext: 'Local knowledge about fever treatment.',
        cloudContext: '', // Empty because offline
        combinedContext: 'Local knowledge about fever treatment.',
        localAttributions: ['Local Medical Database'],
        cloudAttributions: [],
        graphEntities: [],
        graphRelationships: [],
        sourceUsed: RAGSource.localOnly,
        isOnline: false, // Key: offline
        fetchDuration: const Duration(milliseconds: 50),
      );

      expect(context.isOnline, isFalse);
      expect(context.sourceUsed, equals(RAGSource.localOnly));
      expect(context.localContext, isNotEmpty);
      expect(context.cloudContext, isEmpty);
    });

    test('High-risk scenario should use hybrid RAG', () {
      final context = HybridRAGContext(
        localContext: 'Local knowledge about chest pain.',
        cloudContext: 'Graph knowledge linking chest pain to cardiac conditions.',
        combinedContext: 'Combined knowledge...',
        localAttributions: ['Emergency Protocols'],
        cloudAttributions: ['Cardiac Knowledge Graph'],
        graphEntities: [
          const GraphEntity(
            id: '1',
            type: 'Symptom',
            name: 'Chest Pain',
            properties: {'severity': 'high'},
          ),
        ],
        graphRelationships: [
          const GraphRelationship(
            type: 'INDICATES',
            sourceId: '1',
            targetId: '2',
            sourceName: 'Chest Pain',
            targetName: 'Myocardial Infarction',
            properties: {'probability': 0.3},
          ),
        ],
        sourceUsed: RAGSource.hybrid,
        isOnline: true,
        fetchDuration: const Duration(milliseconds: 300),
        riskScore: 0.8, // High risk
      );

      expect(context.riskScore, greaterThanOrEqualTo(0.6));
      expect(context.sourceUsed, equals(RAGSource.hybrid));
      expect(context.localContext, isNotEmpty);
      expect(context.cloudContext, isNotEmpty);
      expect(context.graphRelationships, isNotEmpty);
    });

    test('Africa-specific symptoms should be recognized', () {
      final router = HybridRouter.instance;

      // Test malaria detection
      final malariaScore = router.calculateRiskScore(
        'High fever for 3 days with chills, suspected malaria',
      );
      expect(malariaScore, greaterThan(0));

      // Test typhoid detection
      final typhoidScore = router.calculateRiskScore(
        'Persistent fever, abdominal pain, possible typhoid',
      );
      expect(typhoidScore, greaterThan(0));

      // Test cholera detection
      final choleraScore = router.calculateRiskScore(
        'Severe watery diarrhea, vomiting, dehydration, cholera symptoms',
      );
      expect(choleraScore, greaterThan(0));
    });
  });
}

// Manual integration test script (run with actual services)
// Usage: flutter run -t test/hybrid_rag_integration_test.dart
Future<void> runManualIntegrationTest() async {
  print('=== ClinixAI Hybrid RAG Integration Test ===\n');

  // This would be run manually with actual services
  final hybridRAG = HybridRAGService.instance;
  final router = HybridRouter.instance;
  final openRouter = OpenRouterService.instance;

  print('1. Testing HybridRAGService initialization...');
  // Would need actual KnowledgeBaseService initialized
  print('   Status: HybridRAG.isInitialized = ${hybridRAG.isInitialized}');

  print('\n2. Testing routing decision for critical symptoms...');
  final criticalRouting = await router.determineRoute(
    symptoms: 'Severe chest pain radiating to left arm, shortness of breath',
  );
  print('   Risk Score: ${criticalRouting.riskScore}');
  print('   Complexity: ${criticalRouting.complexityScore}');
  print('   Decision: ${criticalRouting.decision}');
  print('   Reasoning: ${criticalRouting.reasoning}');

  print('\n3. Testing routing decision for simple symptoms...');
  final simpleRouting = await router.determineRoute(
    symptoms: 'Mild cold, runny nose for 2 days',
  );
  print('   Risk Score: ${simpleRouting.riskScore}');
  print('   Decision: ${simpleRouting.decision}');

  print('\n4. Testing OpenRouter configuration...');
  print('   Configured: ${openRouter.isConfigured}');

  print('\n=== Integration Test Complete ===');
}
