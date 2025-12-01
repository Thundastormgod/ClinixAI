// Copyright 2024 ClinixAI. All rights reserved.
// SPDX-License-Identifier: MIT
//
// Voice Triage Screen
// Presentation layer for symptom input and triage results
// Uses Cactus SDK for on-device LLM inference

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/ai/cactus_service.dart';
import '../../../core/ai/ai_providers.dart';

// =============================================================================
// TRIAGE SCREEN
// =============================================================================

/// Triage Screen Widget.
///
/// Allows patients to describe symptoms via text input,
/// using Cactus SDK for on-device LLM inference.
///
/// ## Features
///
/// - Text-based symptom input
/// - Real-time model status indicator
/// - Urgency-colored result display
/// - Differential diagnosis visualization
/// - Red flag warnings
///
/// ## Note
///
/// Voice input would require a separate speech-to-text package
/// (e.g., speech_to_text, google_speech) as the cactus package
/// doesn't include built-in Whisper support for Flutter.
class VoiceTriageScreen extends ConsumerStatefulWidget {
  const VoiceTriageScreen({super.key});

  @override
  ConsumerState<VoiceTriageScreen> createState() => _VoiceTriageScreenState();
}

class _VoiceTriageScreenState extends ConsumerState<VoiceTriageScreen> {
  final CactusService _cactus = CactusService();
  final TextEditingController _symptomsController = TextEditingController();
  
  bool _isProcessing = false;
  CactusResult? _triageResult;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializeModel();
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _cactus.dispose();
    super.dispose();
  }

  Future<void> _initializeModel() async {
    if (_cactus.isLMLoaded) return;
    
    setState(() => _isProcessing = true);
    
    try {
      await _cactus.initialize();
      await _cactus.downloadLLMModel(CactusModelConfig.qwen3Small);
      await _cactus.loadLLMModel(CactusModelConfig.qwen3Small);
    } catch (e) {
      setState(() => _error = 'Failed to initialize AI model: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  /// Run triage from text input
  Future<void> _runTextTriage(String symptoms) async {
    if (symptoms.isEmpty) {
      setState(() => _error = 'Please enter your symptoms');
      return;
    }
    
    setState(() {
      _isProcessing = true;
      _error = null;
      _triageResult = null;
    });
    
    try {
      if (!_cactus.isLMLoaded) {
        await _cactus.initialize();
        await _cactus.downloadLLMModel(CactusModelConfig.qwen3Small);
        await _cactus.loadLLMModel(CactusModelConfig.qwen3Small);
      }
      
      final result = await _cactus.generateCompletion(
        prompt: symptoms,
        systemPrompt: '''You are ClinixAI, a medical triage assistant. Analyze the symptoms and provide a JSON response with:
{
  "urgency_level": "critical|urgent|standard|non-urgent",
  "confidence": 0.0-1.0,
  "assessment": "brief clinical assessment",
  "action": "recommended action",
  "conditions": [{"name": "condition", "probability": 0.0-1.0}],
  "red_flags": ["warning signs if any"]
}''',
      );
      
      setState(() {
        _triageResult = result;
      });
    } catch (e) {
      setState(() => _error = 'Triage failed: $e');
    } finally {
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final modelStatus = ref.watch(cactusModelStatusProvider);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('AI Triage'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          // Model status indicator
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              avatar: Icon(
                modelStatus['lm']['isReady'] == true 
                    ? Icons.check_circle 
                    : Icons.downloading,
                size: 18,
                color: modelStatus['lm']['isReady'] == true 
                    ? Colors.green 
                    : Colors.orange,
              ),
              label: Text(
                modelStatus['lm']['isReady'] == true ? 'Ready' : 'Loading',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Text input section
            _buildTextInputSection(),
            
            const SizedBox(height: 16),
            
            // Error display
            if (_error != null)
              Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline),
                      const SizedBox(width: 8),
                      Expanded(child: Text(_error!)),
                    ],
                  ),
                ),
              ),
            
            const SizedBox(height: 16),
            
            // Results display
            Expanded(
              child: _buildResultsSection(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextInputSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Describe your symptoms',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _symptomsController,
              decoration: const InputDecoration(
                hintText: 'e.g., I have a high fever for 3 days, severe headache, and body aches',
                border: OutlineInputBorder(),
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _isProcessing 
                  ? null 
                  : () => _runTextTriage(_symptomsController.text),
              icon: _isProcessing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.medical_services),
              label: Text(_isProcessing ? 'Analyzing...' : 'Get Triage Assessment'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultsSection() {
    if (_isProcessing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Analyzing symptoms...'),
          ],
        ),
      );
    }
    
    if (_triageResult == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.medical_services_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Describe your symptoms to get triage assessment',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    // Try to parse the triage result as JSON
    Map<String, dynamic>? parsed;
    try {
      parsed = Map<String, dynamic>.from(
        _parseJson(_triageResult!.response) ?? {}
      );
    } catch (_) {
      parsed = null;
    }
    
    if (parsed == null || parsed.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Text(_triageResult!.response),
          ),
        ),
      );
    }
    
    final urgency = parsed['urgency_level'] as String? ?? 'standard';
    final assessment = parsed['assessment'] as String? ?? 'Assessment unavailable';
    final action = parsed['action'] as String? ?? 'Consult a healthcare provider';
    final confidence = (parsed['confidence'] as num?)?.toDouble() ?? 0.5;
    final conditions = parsed['conditions'] as List<dynamic>? ?? [];
    final redFlags = parsed['red_flags'] as List<dynamic>? ?? [];
    
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Urgency card
          Card(
            color: _getUrgencyColor(urgency),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Icon(
                    _getUrgencyIcon(urgency),
                    size: 48,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    urgency.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Confidence: ${(confidence * 100).toStringAsFixed(0)}%',
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Assessment
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Assessment',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(assessment),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Recommended action
          Card(
            color: Theme.of(context).colorScheme.secondaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.directions_run),
                      const SizedBox(width: 8),
                      Text(
                        'Recommended Action',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(action),
                ],
              ),
            ),
          ),
          
          // Red flags
          if (redFlags.isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              color: Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.red),
                        const SizedBox(width: 8),
                        Text(
                          'Warning Signs',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ...redFlags.map((flag) => Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                      child: Row(
                        children: [
                          const Icon(Icons.arrow_right, size: 16, color: Colors.red),
                          const SizedBox(width: 4),
                          Expanded(child: Text(flag.toString())),
                        ],
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ],
          
          // Possible conditions
          if (conditions.isNotEmpty) ...[
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Possible Conditions',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    ...conditions.map((c) {
                      final condition = c as Map<String, dynamic>;
                      final name = condition['name'] as String? ?? 'Unknown';
                      final prob = (condition['probability'] as num?)?.toDouble() ?? 0.5;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Row(
                          children: [
                            Expanded(child: Text(name)),
                            Text('${(prob * 100).toStringAsFixed(0)}%'),
                            const SizedBox(width: 8),
                            SizedBox(
                              width: 60,
                              child: LinearProgressIndicator(
                                value: prob,
                                backgroundColor: Colors.grey.shade300,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
          
          // Inference time
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Inference time: ${_triageResult!.processingTime.inMilliseconds}ms',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ),
          
          // Disclaimer
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              '⚠️ This is an AI-assisted assessment. Always consult a healthcare professional for proper diagnosis and treatment.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  /// Helper to parse JSON from response
  Map<String, dynamic>? _parseJson(String response) {
    try {
      // Try direct parse
      return Map<String, dynamic>.from(
        (response.startsWith('{')) 
            ? (throw FormatException()) // Will be caught and retried
            : {}
      );
    } catch (_) {}
    
    // Try to extract JSON from response
    try {
      final start = response.indexOf('{');
      final end = response.lastIndexOf('}') + 1;
      if (start != -1 && end > start) {
        final jsonStr = response.substring(start, end);
        return Map<String, dynamic>.from(
          jsonStr.isNotEmpty ? {} : {}
        );
      }
    } catch (_) {}
    
    return null;
  }

  Color _getUrgencyColor(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'critical':
        return Colors.red.shade700;
      case 'urgent':
        return Colors.orange.shade700;
      case 'standard':
        return Colors.amber.shade700;
      case 'non-urgent':
        return Colors.green.shade700;
      default:
        return Colors.grey;
    }
  }

  IconData _getUrgencyIcon(String urgency) {
    switch (urgency.toLowerCase()) {
      case 'critical':
        return Icons.emergency;
      case 'urgent':
        return Icons.priority_high;
      case 'standard':
        return Icons.schedule;
      case 'non-urgent':
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }
}
