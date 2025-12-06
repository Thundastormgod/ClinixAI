import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/triage_service.dart';
import '../../../core/network/network_providers.dart';
import 'triage_results_screen.dart';

class SymptomInputScreen extends ConsumerStatefulWidget {
  const SymptomInputScreen({super.key});

  @override
  ConsumerState<SymptomInputScreen> createState() => _SymptomInputScreenState();
}

class _SymptomInputScreenState extends ConsumerState<SymptomInputScreen> {
  final TextEditingController _symptomsController = TextEditingController();
  final List<Symptom> _symptoms = [];
  final List<VitalSign> _vitalSigns = [];

  bool _isAnalyzing = false;
  String? _errorMessage;

  // Patient information
  int? _patientAge;
  String? _patientGender;

  // Common symptoms for quick selection
  final List<String> _commonSymptoms = [
    'Fever', 'Headache', 'Cough', 'Sore throat', 'Body aches',
    'Fatigue', 'Nausea', 'Vomiting', 'Diarrhea', 'Chest pain',
    'Shortness of breath', 'Abdominal pain', 'Back pain', 'Joint pain',
    'Dizziness', 'Rash', 'Coughing blood', 'Blood in stool'
  ];

  final List<String> _bodyLocations = [
    'Head', 'Neck', 'Chest', 'Abdomen', 'Back', 'Arms', 'Legs',
    'Joints', 'Skin', 'Eyes', 'Ears', 'Nose', 'Mouth', 'Genitals'
  ];

  @override
  void dispose() {
    _symptomsController.dispose();
    super.dispose();
  }

  void _addSymptom(String description, {int severity = 5, String? bodyLocation, int? durationHours}) {
    if (description.trim().isEmpty) return;

    setState(() {
      _symptoms.add(Symptom(
        description: description.trim(),
        severity: severity,
        bodyLocation: bodyLocation,
        durationHours: durationHours,
      ));
      _symptomsController.clear();
    });
  }

  void _removeSymptom(int index) {
    setState(() {
      _symptoms.removeAt(index);
    });
  }

  void _addVitalSign(String type, dynamic value, {String? unit}) {
    setState(() {
      // Remove existing vital sign of same type
      _vitalSigns.removeWhere((v) => v.type == type);
      _vitalSigns.add(VitalSign(
        type: type,
        value: value,
        unit: unit,
      ));
    });
  }

  Future<void> _startAnalysis() async {
    if (_symptoms.isEmpty) {
      setState(() {
        _errorMessage = 'Please add at least one symptom';
      });
      return;
    }

    setState(() {
      _isAnalyzing = true;
      _errorMessage = null;
    });

    try {
      final triageService = ref.read(triageServiceProvider);

      // Create a session first (optional, but good practice)
      final deviceId = 'flutter-device-${DateTime.now().millisecondsSinceEpoch}';
      final session = await triageService.createSession(
        deviceId: deviceId,
        deviceModel: 'Flutter App',
        appVersion: '1.0.0',
      );

      // Run the analysis
      final result = await triageService.analyzeSymptoms(
        sessionId: session.sessionId,
        symptoms: _symptoms,
        vitalSigns: _vitalSigns.isNotEmpty ? _vitalSigns : null,
        patientAge: _patientAge,
        patientGender: _patientGender,
      );

      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => TriageResultsScreen(triageResult: result),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Analysis failed: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isAnalyzing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final networkStatus = ref.watch(networkStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Describe Symptoms'),
        actions: [
          // Voice Input Action
          IconButton(
            icon: const Icon(Icons.mic),
            tooltip: 'Switch to Voice Mode',
            onPressed: () {
              Navigator.of(context).pushNamed('/triage/voice');
            },
          ),
          // Network status indicator
          networkStatus.when(
            data: (status) => Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: Icon(
                status.canSync ? Icons.wifi : Icons.wifi_off,
                color: status.canSync ? Colors.green : Colors.orange,
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => const Icon(Icons.error, color: Colors.red),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            LinearProgressIndicator(
              value: _symptoms.isEmpty ? 0.0 : 0.5,
              backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Patient info section
                    _PatientInfoSection(
                      onAgeChanged: (age) => setState(() => _patientAge = age),
                      onGenderChanged: (gender) => setState(() => _patientGender = gender),
                      initialAge: _patientAge,
                      initialGender: _patientGender,
                    ),

                    const SizedBox(height: 24),

                    // Symptom input section
                    _SymptomInputSection(
                      controller: _symptomsController,
                      onAddSymptom: _addSymptom,
                      bodyLocations: _bodyLocations,
                    ),

                    const SizedBox(height: 16),

                    // Quick symptom selection
                    _QuickSymptomSelection(
                      commonSymptoms: _commonSymptoms,
                      onSymptomSelected: (symptom) => _addSymptom(symptom),
                    ),

                    const SizedBox(height: 24),

                    // Added symptoms list
                    if (_symptoms.isNotEmpty) ...[
                      Text(
                        'Added Symptoms',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _SymptomsList(
                        symptoms: _symptoms,
                        onRemove: _removeSymptom,
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Vital signs section
                    _VitalSignsSection(
                      onVitalSignAdded: _addVitalSign,
                      vitalSigns: _vitalSigns,
                    ),

                    const SizedBox(height: 24),

                    // Error message
                    if (_errorMessage != null) ...[
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.errorContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.error_outline,
                              color: Theme.of(context).colorScheme.error,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  ],
                ),
              ),
            ),

            // Bottom action bar
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).colorScheme.shadow.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${_symptoms.length} symptom${_symptoms.length == 1 ? '' : 's'} added',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: (_symptoms.isNotEmpty && !_isAnalyzing) ? _startAnalysis : null,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: _isAnalyzing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Analyze Symptoms'),
                      ),
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
}

class _PatientInfoSection extends StatefulWidget {
  final Function(int?) onAgeChanged;
  final Function(String?) onGenderChanged;
  final int? initialAge;
  final String? initialGender;

  const _PatientInfoSection({
    required this.onAgeChanged,
    required this.onGenderChanged,
    this.initialAge,
    this.initialGender,
  });

  @override
  State<_PatientInfoSection> createState() => _PatientInfoSectionState();
}

class _PatientInfoSectionState extends State<_PatientInfoSection> {
  late TextEditingController _ageController;

  @override
  void initState() {
    super.initState();
    _ageController = TextEditingController(text: widget.initialAge?.toString());
  }

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.person_outline,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Patient Information (Optional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ageController,
                    decoration: const InputDecoration(
                      labelText: 'Age',
                      hintText: 'e.g., 25',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      final age = int.tryParse(value);
                      widget.onAgeChanged(age);
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DropdownButtonFormField<String>(
                    decoration: const InputDecoration(
                      labelText: 'Gender',
                      border: OutlineInputBorder(),
                    ),
                    value: widget.initialGender,
                    hint: const Text('Select gender'),
                    items: ['Male', 'Female', 'Other', 'Prefer not to say']
                        .map((gender) => DropdownMenuItem(
                              value: gender,
                              child: Text(gender),
                            ))
                        .toList(),
                    onChanged: widget.onGenderChanged,
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

class _SymptomInputSection extends StatefulWidget {
  final TextEditingController controller;
  final Function(String, {int severity, String? bodyLocation, int? durationHours}) onAddSymptom;
  final List<String> bodyLocations;

  const _SymptomInputSection({
    required this.controller,
    required this.onAddSymptom,
    required this.bodyLocations,
  });

  @override
  State<_SymptomInputSection> createState() => _SymptomInputSectionState();
}

class _SymptomInputSectionState extends State<_SymptomInputSection> {
  int _severity = 5;
  String? _bodyLocation;
  int? _durationHours;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.description,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Describe Symptoms',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Symptom description
            TextField(
              controller: widget.controller,
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Describe what you\'re experiencing...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              ),
            ),

            const SizedBox(height: 16),

            // Severity slider
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Severity: $_severity/10',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Slider(
                  value: _severity.toDouble(),
                  min: 1,
                  max: 10,
                  divisions: 9,
                  label: _severity.toString(),
                  onChanged: (value) {
                    setState(() {
                      _severity = value.toInt();
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Body location
            DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Body Location (Optional)',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              value: _bodyLocation,
              hint: const Text('Where is the symptom?'),
              items: widget.bodyLocations
                  .map((location) => DropdownMenuItem(
                        value: location,
                        child: Text(location),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _bodyLocation = value;
                });
              },
            ),

            const SizedBox(height: 12),

            // Duration
            TextField(
              decoration: InputDecoration(
                labelText: 'Duration (hours, optional)',
                hintText: 'How long has this been going on?',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _durationHours = int.tryParse(value);
              },
            ),

            const SizedBox(height: 16),

            // Add symptom button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: widget.controller.text.trim().isNotEmpty
                    ? () {
                        widget.onAddSymptom(
                          widget.controller.text,
                          severity: _severity,
                          bodyLocation: _bodyLocation,
                          durationHours: _durationHours,
                        );
                        setState(() {
                          _severity = 5;
                          _bodyLocation = null;
                          _durationHours = null;
                        });
                      }
                    : null,
                icon: const Icon(Icons.add),
                label: const Text('Add Symptom'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickSymptomSelection extends StatelessWidget {
  final List<String> commonSymptoms;
  final Function(String) onSymptomSelected;

  const _QuickSymptomSelection({
    required this.commonSymptoms,
    required this.onSymptomSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.flash_on,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Quick Select',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: commonSymptoms.map((symptom) {
                return ActionChip(
                  label: Text(symptom),
                  onPressed: () => onSymptomSelected(symptom),
                  backgroundColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}

class _SymptomsList extends StatelessWidget {
  final List<Symptom> symptoms;
  final Function(int) onRemove;

  const _SymptomsList({
    required this.symptoms,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: symptoms.length,
        separatorBuilder: (context, index) => const Divider(),
        itemBuilder: (context, index) {
          final symptom = symptoms[index];
          return ListTile(
            title: Text(symptom.description),
            subtitle: Row(
              children: [
                Text('Severity: ${symptom.severity}/10'),
                if (symptom.bodyLocation != null) ...[
                  const SizedBox(width: 12),
                  Text('Location: ${symptom.bodyLocation}'),
                ],
                if (symptom.durationHours != null) ...[
                  const SizedBox(width: 12),
                  Text('Duration: ${symptom.durationHours}h'),
                ],
              ],
            ),
            trailing: IconButton(
              icon: Icon(
                Icons.delete,
                color: Theme.of(context).colorScheme.error,
              ),
              onPressed: () => onRemove(index),
            ),
          );
        },
      ),
    );
  }
}

class _VitalSignsSection extends StatefulWidget {
  final Function(String, dynamic, {String? unit}) onVitalSignAdded;
  final List<VitalSign> vitalSigns;

  const _VitalSignsSection({
    required this.onVitalSignAdded,
    required this.vitalSigns,
  });

  @override
  State<_VitalSignsSection> createState() => _VitalSignsSectionState();
}

class _VitalSignsSectionState extends State<_VitalSignsSection> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String> _vitalSignLabels = {
    'temperature': 'Temperature (°C)',
    'heartRate': 'Heart Rate (bpm)',
    'bloodPressure': 'Blood Pressure',
    'oxygenSaturation': 'Oxygen Saturation (%)',
  };

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  TextEditingController _getController(String type) {
    return _controllers[type] ??= TextEditingController();
  }

  void _addVitalSign(String type) {
    final controller = _getController(type);
    if (controller.text.isEmpty) return;

    String? unit;
    dynamic value;

    switch (type) {
      case 'temperature':
        value = double.tryParse(controller.text);
        unit = '°C';
        break;
      case 'heartRate':
        value = int.tryParse(controller.text);
        unit = 'bpm';
        break;
      case 'bloodPressure':
        value = controller.text; // e.g., "120/80"
        break;
      case 'oxygenSaturation':
        value = int.tryParse(controller.text);
        unit = '%';
        break;
    }

    if (value != null) {
      widget.onVitalSignAdded(type, value, unit: unit);
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.monitor_heart,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Text(
                  'Vital Signs (Optional)',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Vital sign inputs
            ..._vitalSignLabels.entries.map((entry) {
              final type = entry.key;
              final label = entry.value;
              final controller = _getController(type);

              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: controller,
                        decoration: InputDecoration(
                          labelText: label,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                        ),
                        keyboardType: type == 'bloodPressure'
                            ? TextInputType.text
                            : TextInputType.numberWithOptions(decimal: type == 'temperature'),
                        onSubmitted: (_) => _addVitalSign(type),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () => _addVitalSign(type),
                      style: IconButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                  ],
                ),
              );
            }),

            // Added vital signs
            if (widget.vitalSigns.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                'Recorded Vital Signs',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: widget.vitalSigns.map((vitalSign) {
                  final label = _vitalSignLabels[vitalSign.type] ?? vitalSign.type;
                  final valueText = vitalSign.unit != null
                      ? '${vitalSign.value} ${vitalSign.unit}'
                      : vitalSign.value.toString();

                  return Chip(
                    label: Text('$label: $valueText'),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () {
                      // Remove vital sign logic would go here
                    },
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
