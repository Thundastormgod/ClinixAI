import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

void main() {
  runApp(
    const ProviderScope(
      child: ClinixWebApp(),
    ),
  );
}

class ClinixWebApp extends StatelessWidget {
  const ClinixWebApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ClinixAI - Emergency Triage',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006D77), // Medical teal
          brightness: Brightness.light,
        ),
      ),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _backendStatus = 'Checking...';
  bool _isConnected = false;

  @override
  void initState() {
    super.initState();
    _checkBackendStatus();
  }

  Future<void> _checkBackendStatus() async {
    try {
      final dio = Dio();
      final response = await dio.get('http://localhost:3000/health');
      if (response.statusCode == 200) {
        setState(() {
          _backendStatus = 'Connected ✅';
          _isConnected = true;
        });
      }
    } catch (e) {
      setState(() {
        _backendStatus = 'Disconnected ❌';
        _isConnected = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ClinixAI'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Chip(
              label: Text(_backendStatus),
              backgroundColor: _isConnected ? Colors.green[100] : Colors.red[100],
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Card
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.local_hospital,
                          size: 48,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome to ClinixAI',
                                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                              ),
                              Text(
                                'AI-Powered Emergency Triage for Africa',
                                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.medical_services,
                    title: 'New Triage',
                    subtitle: 'Start symptom assessment',
                    color: Colors.blue,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TriageScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.warning_amber,
                    title: 'Emergency',
                    subtitle: 'Critical situation',
                    color: Colors.red,
                    onTap: () => _showEmergencyDialog(context),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _ActionCard(
                    icon: Icons.history,
                    title: 'History',
                    subtitle: 'Past assessments',
                    color: Colors.green,
                    onTap: () => _showComingSoon(context),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _ActionCard(
                    icon: Icons.settings,
                    title: 'Settings',
                    subtitle: 'App configuration',
                    color: Colors.purple,
                    onTap: () => _showComingSoon(context),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 32),

            // System Status
            Text(
              'System Status',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _StatusRow(
                      label: 'Backend API',
                      status: _isConnected ? 'Online' : 'Offline',
                      isOk: _isConnected,
                    ),
                    const Divider(),
                    _StatusRow(
                      label: 'Database',
                      status: _isConnected ? 'Connected' : 'Disconnected',
                      isOk: _isConnected,
                    ),
                    const Divider(),
                    const _StatusRow(
                      label: 'AI Service',
                      status: 'Web Mode (Cloud Only)',
                      isOk: true,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmergencyDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Emergency'),
          ],
        ),
        content: const Text(
          'If this is a life-threatening emergency, please call your local emergency services immediately.\n\n'
          'Emergency Numbers:\n'
          '• Nigeria: 112 / 199\n'
          '• Kenya: 999 / 112\n'
          '• South Africa: 10177\n'
          '• Ghana: 112 / 191',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TriageScreen()),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Start Urgent Triage', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showComingSoon(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Coming soon!')),
    );
  }
}

class _ActionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusRow extends StatelessWidget {
  final String label;
  final String status;
  final bool isOk;

  const _StatusRow({
    required this.label,
    required this.status,
    required this.isOk,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            isOk ? Icons.check_circle : Icons.error,
            color: isOk ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
          Text(
            status,
            style: TextStyle(
              color: isOk ? Colors.green : Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ==================== TRIAGE SCREEN ====================

class TriageScreen extends StatefulWidget {
  const TriageScreen({super.key});

  @override
  State<TriageScreen> createState() => _TriageScreenState();
}

class _TriageScreenState extends State<TriageScreen> {
  final _symptomsController = TextEditingController();
  final _ageController = TextEditingController();
  String? _selectedGender;
  bool _isLoading = false;
  Map<String, dynamic>? _result;
  String? _error;

  @override
  void dispose() {
    _symptomsController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _runTriage() async {
    if (_symptomsController.text.isEmpty) {
      setState(() => _error = 'Please describe your symptoms');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
      _result = null;
    });

    try {
      final dio = Dio();
      
      // Create session
      final sessionResponse = await dio.post(
        'http://localhost:3000/api/v1/triage/sessions',
        data: {
          'deviceId': 'web-client',
          'deviceModel': 'Browser',
          'appVersion': '1.0.0',
        },
      );

      final sessionId = sessionResponse.data['data']['sessionId'];

      // Record symptoms
      await dio.post(
        'http://localhost:3000/api/v1/triage/sessions/$sessionId/symptoms',
        data: {
          'symptoms': [
            {
              'description': _symptomsController.text,
              'severity': 5,
              'duration': 'unknown',
            }
          ],
        },
      );

      // Analyze
      final analyzeResponse = await dio.post(
        'http://localhost:3000/api/v1/triage/sessions/$sessionId/analyze',
        data: {
          'sessionId': sessionId,
          'symptoms': [
            {
              'name': _symptomsController.text,
              'severity': 5,
            }
          ],
          'patientAge': int.tryParse(_ageController.text) ?? 30,
          'patientGender': _selectedGender ?? 'unknown',
        },
      );

      setState(() {
        _result = analyzeResponse.data['data'] ?? analyzeResponse.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to connect to backend: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Symptom Assessment'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Patient Information',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ageController,
                            decoration: const InputDecoration(
                              labelText: 'Age',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedGender,
                            decoration: const InputDecoration(
                              labelText: 'Gender',
                              border: OutlineInputBorder(),
                            ),
                            items: const [
                              DropdownMenuItem(value: 'male', child: Text('Male')),
                              DropdownMenuItem(value: 'female', child: Text('Female')),
                              DropdownMenuItem(value: 'other', child: Text('Other')),
                            ],
                            onChanged: (value) => setState(() => _selectedGender = value),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Symptoms Input
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Describe Your Symptoms',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Please describe what you are experiencing in detail',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: _symptomsController,
                      maxLines: 5,
                      decoration: const InputDecoration(
                        hintText: 'e.g., I have had a headache for 2 days, with mild fever and fatigue...',
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _runTriage,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.medical_services),
                label: Text(_isLoading ? 'Analyzing...' : 'Run AI Triage'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ),

            // Error
            if (_error != null) ...[
              const SizedBox(height: 16),
              Card(
                color: Colors.red[50],
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      const Icon(Icons.error, color: Colors.red),
                      const SizedBox(width: 12),
                      Expanded(child: Text(_error!, style: const TextStyle(color: Colors.red))),
                    ],
                  ),
                ),
              ),
            ],

            // Results
            if (_result != null) ...[
              const SizedBox(height: 24),
              _TriageResultCard(result: _result!),
            ],
          ],
        ),
      ),
    );
  }
}

class _TriageResultCard extends StatelessWidget {
  final Map<String, dynamic> result;

  const _TriageResultCard({required this.result});

  Color _getUrgencyColor(String? urgency) {
    switch (urgency?.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'urgent':
        return Colors.orange;
      case 'standard':
        return Colors.blue;
      case 'non-urgent':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final urgency = result['urgencyLevel'] ?? result['urgency'] ?? 'unknown';
    final assessment = result['primaryAssessment'] ?? result['assessment'] ?? 'No assessment available';
    final action = result['recommendedAction'] ?? result['action'] ?? 'Please consult a healthcare provider';
    final confidence = result['confidenceScore'] ?? result['confidence'] ?? 0.0;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.assignment_turned_in, color: _getUrgencyColor(urgency)),
                const SizedBox(width: 8),
                Text(
                  'Triage Result',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Urgency Level
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _getUrgencyColor(urgency).withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _getUrgencyColor(urgency)),
              ),
              child: Text(
                'Urgency: ${urgency.toString().toUpperCase()}',
                style: TextStyle(
                  color: _getUrgencyColor(urgency),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Assessment
            Text(
              'Assessment',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(assessment.toString()),
            const SizedBox(height: 16),

            // Recommended Action
            Text(
              'Recommended Action',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.arrow_forward, color: Colors.blue),
                  const SizedBox(width: 12),
                  Expanded(child: Text(action.toString())),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Confidence
            Row(
              children: [
                const Text('AI Confidence: '),
                Expanded(
                  child: LinearProgressIndicator(
                    value: (confidence is num) ? confidence.toDouble() : 0.5,
                    backgroundColor: Colors.grey[200],
                  ),
                ),
                const SizedBox(width: 8),
                Text('${((confidence is num ? confidence.toDouble() : 0.5) * 100).toInt()}%'),
              ],
            ),

            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            
            Text(
              '⚠️ Disclaimer: This is an AI-assisted triage and not a medical diagnosis. '
              'Please consult a healthcare professional for proper medical advice.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
