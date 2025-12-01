// Copyright 2024 ClinixAI. All rights reserved.
// SPDX-License-Identifier: MIT
//
// ClinixAI Mobile Application
// Principal-level Flutter application for AI-powered medical triage
//
// Architecture:
// ┌─────────────────────────────────────────────────────────┐
// │                  CLINIXAI ARCHITECTURE                    │
// │                                                           │
// │  ┌─────────────────────────────────────────────────┐   │
// │  │  PRESENTATION LAYER                               │   │
// │  │  - VoiceTriageScreen (symptom input)              │   │
// │  │  - TriageTestScreen (test/debug)                  │   │
// │  └─────────────────────────────────────────────────┘   │
// │                       │                                  │
// │                       ▼                                  │
// │  ┌─────────────────────────────────────────────────┐   │
// │  │  DOMAIN LAYER                                     │   │
// │  │  - PerformTriageUseCase (orchestration)           │   │
// │  └─────────────────────────────────────────────────┘   │
// │                       │                                  │
// │                       ▼                                  │
// │  ┌─────────────────────────────────────────────────┐   │
// │  │  INFRASTRUCTURE LAYER                             │   │
// │  │  - HybridRouter (local/cloud routing)             │   │
// │  │  - CactusService (on-device LLM)                  │   │
// │  │  - OpenRouterService (cloud LLM)                  │   │
// │  │  - KnowledgeBaseService (RAG)                     │   │
// │  │  - LocalDatabase (Isar persistence)              │   │
// │  └─────────────────────────────────────────────────┘   │
// └─────────────────────────────────────────────────────────┘

import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'core/ai/cactus_service.dart';
import 'core/ai/hybrid_router.dart';
import 'core/ai/openrouter_service.dart';
import 'core/database/local_database.dart';
import 'features/triage/domain/usecases/perform_triage.dart';
import 'features/triage/presentation/voice_triage_screen.dart';

/// Returns true if running on a mobile platform that supports Cactus SDK.
bool get _isMobilePlatform {
  if (kIsWeb) return false;
  try {
    return Platform.isAndroid || Platform.isIOS;
  } catch (_) {
    return false;
  }
}

// =============================================================================
// APPLICATION ENTRY POINT
// =============================================================================

/// Global Cactus service instance.
///
/// Shared across the application for on-device LLM inference.
final cactusService = CactusService();

/// Application entry point.
///
/// Performs initialization in order:
/// 1. Flutter binding initialization
/// 2. Environment variables loading
/// 3. Core services initialization
/// 4. App launch with Riverpod state management
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables
  await _loadEnvironment();

  // Initialize core services
  await _initializeServices();

  runApp(
    const ProviderScope(
      child: ClinixApp(),
    ),
  );
}

// =============================================================================
// INITIALIZATION
// =============================================================================

/// Load environment variables from .env file.
///
/// Falls back to defaults if .env is not found.
/// This allows the app to run without configuration in development.
Future<void> _loadEnvironment() async {
  try {
    await dotenv.load(fileName: '.env');
    debugPrint('✅ Environment loaded');
  } catch (e) {
    debugPrint('⚠️ No .env file found, using defaults');
  }
}

/// Initialize all core services before app starts.
///
/// Initialization order matters:
/// 1. LocalDatabase - required by other services
/// 2. OpenRouterService - cloud AI configuration
/// 3. HybridRouter - requires both local and cloud services
/// 4. CactusService - on-device LLM (lazy model loading)
///
/// Environment variables used:
/// - OPENROUTER_API_KEY: Cloud AI API key
/// - AI_RISK_THRESHOLD: Routing risk threshold (0.0-1.0)
/// - AI_COMPLEXITY_THRESHOLD: Routing complexity threshold (0.0-1.0)
/// - AI_CONFIDENCE_ESCALATION_THRESHOLD: Escalation threshold (0.0-1.0)
/// - LOCAL_LLM_MODEL: Model name (lfm2-1.2b-rag, lfm2-vl-450m, qwen3-0.6)
Future<void> _initializeServices() async {
  // Initialize local database
  await LocalDatabase.instance.initialize();
  debugPrint('✅ Database initialized');

  // Configure OpenRouter with API key from environment
  final openRouterApiKey = dotenv.env['OPENROUTER_API_KEY'];
  if (openRouterApiKey != null && 
      openRouterApiKey.isNotEmpty && 
      !openRouterApiKey.startsWith('sk-or-v1-your')) {
    OpenRouterService.instance.configure(
      apiKey: openRouterApiKey,
    );
    debugPrint('✅ OpenRouter configured');
  } else {
    debugPrint('⚠️ OpenRouter API key not configured (cloud inference disabled)');
  }

  // Configure routing thresholds from environment
  final riskThreshold = double.tryParse(dotenv.env['AI_RISK_THRESHOLD'] ?? '');
  final complexityThreshold = double.tryParse(dotenv.env['AI_COMPLEXITY_THRESHOLD'] ?? '');
  final confidenceThreshold = double.tryParse(dotenv.env['AI_CONFIDENCE_ESCALATION_THRESHOLD'] ?? '');
  
  if (riskThreshold != null) {
    HybridRouter.instance.riskThreshold = riskThreshold;
  }
  if (complexityThreshold != null) {
    HybridRouter.instance.complexityThreshold = complexityThreshold;
  }
  if (confidenceThreshold != null) {
    HybridRouter.instance.confidenceEscalationThreshold = confidenceThreshold;
  }

  // Determine which local model to use from env
  final localModelName = dotenv.env['LOCAL_LLM_MODEL'] ?? 'lfm2-1.2b-rag';
  
  // Initialize Cactus service (mobile only - Cactus SDK uses ARM-optimized binaries)
  if (_isMobilePlatform) {
    await cactusService.initialize();
    debugPrint('✅ Cactus service initialized');
    
    // Set up download progress callback
    cactusService.onDownloadProgress = (progress, status, isError) {
      if (isError) {
        debugPrint('[Cactus Download] ERROR: $status');
      } else {
        final progressStr = progress != null ? '${(progress * 100).toInt()}%' : '';
        debugPrint('[Cactus Download] $status $progressStr');
      }
    };
    
    cactusService.onStatusChange = (status) {
      debugPrint('[Cactus] $status');
    };

    // Select model config based on environment
    CactusModelConfig localModel;
    if (localModelName.contains('vision') || localModelName.contains('vl')) {
      localModel = CactusModelConfig.lfm2Vision;
    } else if (localModelName.contains('qwen')) {
      localModel = CactusModelConfig.qwen3Small;
    } else {
      localModel = CactusModelConfig.lfm2Rag; // Default: LiquidAI LFM2 RAG
    }
    
    debugPrint('📱 Local LLM Model: ${localModel.modelName}');
  } else {
    debugPrint('⚠️ Desktop/Web platform - Cactus SDK not available (cloud-only mode)');
    debugPrint('📱 To test local LLM, use Android/iOS device or emulator');
  }

  // Initialize HybridRouter (handles both local and cloud AI)
  await HybridRouter.instance.initialize();
  debugPrint('✅ HybridRouter initialized');
  
  if (_isMobilePlatform) {
    debugPrint('   - Local LLM: ${cactusService.isLMLoaded ? "Ready" : "Not Ready (will download on first use)"}');
  } else {
    debugPrint('   - Local LLM: Not Available (desktop platform)');
  }
  debugPrint('   - Cloud API: ${OpenRouterService.instance.isConfigured ? "Configured" : "Not Configured"}');
  
  debugPrint('✅ ClinixAI Services Initialized');
}

// =============================================================================
// APPLICATION WIDGET
// =============================================================================

/// Root application widget.
///
/// Configures:
/// - Material 3 theming with medical green color scheme
/// - Dark mode support via system preference
/// - NothingSans font family for Nothing Phone integration
class ClinixApp extends StatelessWidget {
  const ClinixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClinixAI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A86B), // Medical green
          brightness: Brightness.light,
        ),
        // fontFamily: 'NothingSans', // Uncomment when font files are available
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00A86B),
          brightness: Brightness.dark,
        ),
        // fontFamily: 'NothingSans', // Uncomment when font files are available
      ),
      themeMode: ThemeMode.system,
      home: const TriageTestScreen(),
    );
  }
}

// =============================================================================
// TEST SCREEN (DEVELOPMENT)
// =============================================================================

/// Temporary test screen to validate core functionality.
///
/// This will be replaced with proper UI in production.
/// Provides:
/// - System status indicators (Database, LLM, Cloud, Router)
/// - Symptom text input
/// - Triage execution with result display
/// - Navigation to VoiceTriageScreen
class TriageTestScreen extends StatefulWidget {
  const TriageTestScreen({super.key});

  @override
  State<TriageTestScreen> createState() => _TriageTestScreenState();
}

class _TriageTestScreenState extends State<TriageTestScreen> {
  final _symptomsController = TextEditingController();
  String _result = 'Enter symptoms and tap "Run Triage"';
  bool _isLoading = false;

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  Future<void> _runTriage() async {
    if (_symptomsController.text.isEmpty) {
      setState(() {
        _result = '⚠️ Please enter symptoms first';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _result = '🔄 Running AI triage (hybrid inference)...';
    });

    try {
      final useCase = PerformTriageUseCase();
      final stopwatch = Stopwatch()..start();

      final outcome = await useCase.execute(
        TriageInput(
          symptoms: [
            SymptomInput(
              description: _symptomsController.text,
            ),
          ],
          deviceModel: 'Nothing Phone (2a)',
          appVersion: '1.0.0',
        ),
      );

      stopwatch.stop();
      
      final providerInfo = outcome.usedCloud 
          ? '☁️ Cloud (${ outcome.modelUsed})' 
          : '📱 Local (${outcome.modelUsed})';

      setState(() {
        _result = '''
📊 Triage Result
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

${outcome.summary}

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
⚡ Provider: $providerInfo
⏱️ Time: ${stopwatch.elapsedMilliseconds}ms
🏥 Urgency: ${outcome.result.urgencyLevel.name.toUpperCase()}
''';
      });
    } catch (e) {
      setState(() {
        _result = '❌ Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClinixAI - Core Test'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Status indicators
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'System Status',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 16,
                      runSpacing: 8,
                      children: [
                        _StatusIndicator(
                          label: 'Database',
                          isReady: LocalDatabase.instance.isReady,
                        ),
                        _StatusIndicator(
                          label: 'Local LLM',
                          isReady: cactusService.isLMLoaded,
                        ),
                        _StatusIndicator(
                          label: 'Cloud API',
                          isReady: OpenRouterService.instance.isConfigured,
                        ),
                        _StatusIndicator(
                          label: 'Router',
                          isReady: HybridRouter.instance.isInitialized,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Model: ${cactusService.currentModelName ?? "Not loaded"}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Symptom input
            TextField(
              controller: _symptomsController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Describe your symptoms',
                hintText: 'e.g., High fever for 3 days, severe headache, body aches',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),

            // Run button
            ElevatedButton.icon(
              onPressed: _isLoading ? null : _runTriage,
              icon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.medical_services),
              label: Text(_isLoading ? 'Analyzing...' : 'Run Triage'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 8),
            
            // Voice Triage button
            OutlinedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VoiceTriageScreen(),
                  ),
                );
              },
              icon: const Icon(Icons.mic),
              label: const Text('Voice Triage'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
            const SizedBox(height: 16),

            // Results
            Expanded(
              child: Card(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: SelectableText(
                    _result,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusIndicator extends StatelessWidget {
  final String label;
  final bool isReady;

  const _StatusIndicator({
    required this.label,
    required this.isReady,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          isReady ? Icons.check_circle : Icons.error,
          color: isReady ? Colors.green : Colors.red,
          size: 16,
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: isReady ? Colors.green : Colors.red,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
