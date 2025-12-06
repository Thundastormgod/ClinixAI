import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    )..repeat(reverse: true);
    _animation = Tween<double>(begin: 1.0, end: 1.1).animate(_controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _callEmergency() async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: '911', // Use 112 or 999 depending on region, can be configurable
    );
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red.shade50,
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: const Text('EMERGENCY MODE'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              
              // Pulsing Emergency Button
              Center(
                child: ScaleTransition(
                  scale: _animation,
                  child: GestureDetector(
                    onTap: _callEmergency,
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.red,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.red.withOpacity(0.5),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone,
                            size: 64,
                            color: Colors.white,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'CALL 911',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              Text(
                'Use this only in case of immediate danger to life or health.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.red.shade900,
                  fontWeight: FontWeight.w600,
                ),
              ),

              const SizedBox(height: 32),

              // Quick Actions
              _EmergencyActionTile(
                icon: Icons.location_on,
                title: 'Share Live Location',
                onTap: () {
                  // TODO: Implement location sharing
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Sharing location to emergency contacts...')),
                  );
                },
              ),
              const SizedBox(height: 16),
              _EmergencyActionTile(
                icon: Icons.medical_services,
                title: 'Find Nearest Hospital',
                onTap: () {
                  // TODO: Implement hospital finder
                },
              ),
              const SizedBox(height: 16),
              _EmergencyActionTile(
                icon: Icons.contact_phone,
                title: 'Call Emergency Contact',
                onTap: () {
                  // TODO: Implement calling emergency contact
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmergencyActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _EmergencyActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Icon(icon, color: Colors.red, size: 28),
              const SizedBox(width: 16),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

