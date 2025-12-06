import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/triage_service.dart';
import '../../../core/network/network_providers.dart';

class TriageResultsScreen extends ConsumerWidget {
  final TriageResult triageResult;

  const TriageResultsScreen({
    super.key,
    required this.triageResult,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final networkStatus = ref.watch(networkStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Triage Results'),
        actions: [
          // Network status indicator
          networkStatus.when(
            data: (status) => IconButton(
              icon: Icon(
                status.canSync ? Icons.wifi : Icons.wifi_off,
                color: status.canSync ? Colors.green : Colors.orange,
              ),
              onPressed: () => _showNetworkInfo(context, status),
              tooltip: status.canSync ? 'Online' : 'Offline Mode',
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => IconButton(
              icon: const Icon(Icons.error, color: Colors.red),
              onPressed: () => _showNetworkError(context, error.toString()),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Urgency level card - most prominent
              _UrgencyLevelCard(urgencyLevel: triageResult.urgencyLevel),

              const SizedBox(height: 24),

              // Key metrics row
              Row(
                children: [
                  Expanded(
                    child: _MetricCard(
                      title: 'Confidence',
                      value: '${(triageResult.confidenceScore * 100).toStringAsFixed(0)}%',
                      icon: Icons.verified,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _MetricCard(
                      title: 'Response Time',
                      value: '${triageResult.inferenceTimeMs}ms',
                      icon: Icons.timer,
                      color: Colors.green,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Primary assessment
              _AssessmentCard(
                title: 'Clinical Assessment',
                content: triageResult.primaryAssessment,
                icon: Icons.medical_information,
              ),

              const SizedBox(height: 16),

              // Recommended action - highlighted
              _ActionCard(
                title: 'Recommended Action',
                content: triageResult.recommendedAction,
                urgencyLevel: triageResult.urgencyLevel,
              ),

              const SizedBox(height: 16),

              // Differential diagnoses
              if (triageResult.differentialDiagnoses.isNotEmpty)
                _DifferentialDiagnosesCard(
                  diagnoses: triageResult.differentialDiagnoses,
                ),

              const SizedBox(height: 16),

              // AI model information
              _ModelInfoCard(
                aiModel: triageResult.aiModel,
                escalatedToCloud: triageResult.escalatedToCloud,
                complexityScore: triageResult.complexityScore,
              ),

              const SizedBox(height: 16),

              // Workflow messages (debug info)
              if (triageResult.workflowMessages != null &&
                  triageResult.workflowMessages!.isNotEmpty)
                _WorkflowMessagesCard(
                  messages: triageResult.workflowMessages!,
                ),

              const SizedBox(height: 24),

              // Action buttons
              _ActionButtons(
                urgencyLevel: triageResult.urgencyLevel,
                sessionId: triageResult.sessionId,
              ),

              const SizedBox(height: 24),

              // Disclaimer
              _DisclaimerCard(),
            ],
          ),
        ),
      ),
    );
  }

  void _showNetworkInfo(BuildContext context, NetworkStatus status) {
    final message = status.canSync
        ? 'Connected to ClinixAI servers. Full functionality available.'
        : status.isOnline
            ? 'Limited connectivity. AI servers unavailable, using local analysis.'
            : 'Offline mode. Using local AI analysis only. Results will sync when online.';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showNetworkError(BuildContext context, String error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Network error: $error'),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}

class _UrgencyLevelCard extends StatelessWidget {
  final UrgencyLevel urgencyLevel;

  const _UrgencyLevelCard({required this.urgencyLevel});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _getUrgencyGradient(urgencyLevel),
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _getUrgencyColor(urgencyLevel).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            _getUrgencyIcon(urgencyLevel),
            size: 64,
            color: Colors.white,
          ),
          const SizedBox(height: 16),
          Text(
            urgencyLevel.displayName,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            urgencyLevel.description,
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Color _getUrgencyColor(UrgencyLevel level) {
    switch (level) {
      case UrgencyLevel.level1:
        return Colors.red.shade700;
      case UrgencyLevel.level2:
        return Colors.orange.shade700;
      case UrgencyLevel.level3:
        return Colors.amber.shade700;
      case UrgencyLevel.level4:
        return Colors.green.shade700;
      case UrgencyLevel.level5:
        return Colors.blue.shade700;
    }
  }

  List<Color> _getUrgencyGradient(UrgencyLevel level) {
    switch (level) {
      case UrgencyLevel.level1:
        return [Colors.red.shade800, Colors.red.shade600];
      case UrgencyLevel.level2:
        return [Colors.orange.shade800, Colors.orange.shade600];
      case UrgencyLevel.level3:
        return [Colors.amber.shade800, Colors.amber.shade600];
      case UrgencyLevel.level4:
        return [Colors.green.shade800, Colors.green.shade600];
      case UrgencyLevel.level5:
        return [Colors.blue.shade800, Colors.blue.shade600];
    }
  }

  IconData _getUrgencyIcon(UrgencyLevel level) {
    switch (level) {
      case UrgencyLevel.level1:
        return Icons.emergency;
      case UrgencyLevel.level2:
        return Icons.priority_high;
      case UrgencyLevel.level3:
        return Icons.schedule;
      case UrgencyLevel.level4:
        return Icons.check_circle;
      case UrgencyLevel.level5:
        return Icons.home;
    }
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AssessmentCard extends StatelessWidget {
  final String title;
  final String content;
  final IconData icon;

  const _AssessmentCard({
    required this.title,
    required this.content,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String content;
  final UrgencyLevel urgencyLevel;

  const _ActionCard({
    required this.title,
    required this.content,
    required this.urgencyLevel,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = urgencyLevel == UrgencyLevel.level1 || urgencyLevel == UrgencyLevel.level2;

    return Card(
      color: isCritical
          ? Theme.of(context).colorScheme.errorContainer
          : Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  isCritical ? Icons.warning : Icons.directions_run,
                  color: isCritical
                      ? Theme.of(context).colorScheme.error
                      : Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: isCritical
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              content,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                height: 1.5,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DifferentialDiagnosesCard extends StatelessWidget {
  final List<DifferentialDiagnosis> diagnoses;

  const _DifferentialDiagnosesCard({required this.diagnoses});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.list_alt,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Possible Conditions',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...diagnoses.map((diagnosis) => Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          diagnosis.condition,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (diagnosis.icdCode != null)
                          Text(
                            'ICD: ${diagnosis.icdCode}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${(diagnosis.probability * 100).toStringAsFixed(0)}%',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: 60,
                        child: LinearProgressIndicator(
                          value: diagnosis.probability,
                          backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _ModelInfoCard extends StatelessWidget {
  final String aiModel;
  final bool escalatedToCloud;
  final double? complexityScore;

  const _ModelInfoCard({
    required this.aiModel,
    required this.escalatedToCloud,
    this.complexityScore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  escalatedToCloud ? Icons.cloud : Icons.smartphone,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  'AI Analysis Details',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _InfoItem(
                    label: 'Model',
                    value: aiModel,
                  ),
                ),
                if (complexityScore != null) ...[
                  const SizedBox(width: 16),
                  Expanded(
                    child: _InfoItem(
                      label: 'Complexity',
                      value: '${(complexityScore! * 100).toStringAsFixed(0)}%',
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(
                  escalatedToCloud ? Icons.cloud_upload : Icons.phone_android,
                  size: 16,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 8),
                Text(
                  escalatedToCloud ? 'Cloud Analysis' : 'Local Analysis',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String value;

  const _InfoItem({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _WorkflowMessagesCard extends StatelessWidget {
  final List<String> messages;

  const _WorkflowMessagesCard({required this.messages});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.bug_report,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Text(
                  'Analysis Log',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...messages.map((message) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                message,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontFamily: 'monospace',
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final UrgencyLevel urgencyLevel;
  final String sessionId;

  const _ActionButtons({
    required this.urgencyLevel,
    required this.sessionId,
  });

  @override
  Widget build(BuildContext context) {
    final isCritical = urgencyLevel == UrgencyLevel.level1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Emergency call button for critical cases
        if (isCritical) ...[
          ElevatedButton.icon(
            onPressed: () => _callEmergency(context),
            icon: const Icon(Icons.emergency),
            label: const Text('Call Emergency Services'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
              padding: const EdgeInsets.all(16),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Find healthcare facility
        ElevatedButton.icon(
          onPressed: () => _findHealthcareFacility(context),
          icon: const Icon(Icons.location_on),
          label: const Text('Find Healthcare Facility'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        ),

        const SizedBox(height: 12),

        // Share results
        OutlinedButton.icon(
          onPressed: () => _shareResults(context),
          icon: const Icon(Icons.share),
          label: const Text('Share Results'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        ),

        const SizedBox(height: 12),

        // Save to history
        OutlinedButton.icon(
          onPressed: () => _saveToHistory(context),
          icon: const Icon(Icons.save),
          label: const Text('Save to History'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  void _callEmergency(BuildContext context) {
    // TODO: Implement emergency calling
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Emergency calling feature coming soon')),
    );
  }

  void _findHealthcareFacility(BuildContext context) {
    // TODO: Implement healthcare facility finder
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Healthcare facility finder coming soon')),
    );
  }

  void _shareResults(BuildContext context) {
    // TODO: Implement results sharing
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Results sharing feature coming soon')),
    );
  }

  void _saveToHistory(BuildContext context) {
    // TODO: Implement save to history
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Save to history feature coming soon')),
    );
  }
}

class _DisclaimerCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Important Notice',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'This is an AI-assisted assessment using advanced medical algorithms. While designed to provide helpful guidance, it is not a substitute for professional medical advice, diagnosis, or treatment. Always consult qualified healthcare professionals for proper evaluation and care.',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'ClinixAI v1.0.0 • Built for healthcare accessibility in Africa',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant.withOpacity(0.7),
              fontStyle: FontStyle.italic,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
