import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/network_providers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final networkStatusAsync = ref.watch(networkStatusProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('ClinixAI'),
        actions: [
          // Network status indicator
          networkStatusAsync.when(
            data: (status) => IconButton(
              icon: Icon(
                status.canSync ? Icons.wifi : Icons.wifi_off,
                color: status.canSync ? Colors.green : Colors.orange,
              ),
              onPressed: () => _showNetworkStatus(context, status),
            ),
            loading: () => const SizedBox.shrink(),
            error: (error, stack) => IconButton(
              icon: const Icon(Icons.error, color: Colors.red),
              onPressed: () => _showNetworkError(context, error.toString()),
            ),
          ),

          // Profile menu
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  Navigator.of(context).pushNamed('/profile');
                  break;
                case 'settings':
                  Navigator.of(context).pushNamed('/settings');
                  break;
                case 'logout':
                  _showLogoutDialog(context, ref);
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'profile',
                child: ListTile(
                  leading: Icon(Icons.person),
                  title: Text('Profile'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text('Settings'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Logout'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              if (authState.user != null) ...[
                Text(
                  'Welcome back,',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                Text(
                  authState.user!.fullName.split(' ').first,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Quick actions
              Text(
                'Quick Actions',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'New Triage',
                      subtitle: 'Start symptom assessment',
                      icon: Icons.medical_services,
                      color: Theme.of(context).colorScheme.primary,
                      onTap: () => Navigator.of(context).pushNamed('/triage'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Emergency',
                      subtitle: 'Critical situation',
                      icon: Icons.emergency,
                      color: Theme.of(context).colorScheme.error,
                      onTap: () => Navigator.of(context).pushNamed('/emergency'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _QuickActionCard(
                      title: 'History',
                      subtitle: 'Previous assessments',
                      icon: Icons.history,
                      color: Theme.of(context).colorScheme.secondary,
                      onTap: () => Navigator.of(context).pushNamed('/history'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _QuickActionCard(
                      title: 'Sync Data',
                      subtitle: 'Upload offline sessions',
                      icon: Icons.sync,
                      color: Theme.of(context).colorScheme.tertiary,
                      onTap: () => _syncData(context, ref),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Recent activity
              Text(
                'Recent Activity',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              _RecentActivityCard(
                title: 'Chest pain assessment',
                subtitle: '2 hours ago • Standard urgency',
                icon: Icons.favorite,
                color: Colors.orange,
                onTap: () => Navigator.of(context).pushNamed('/triage/result/123'),
              ),
              const SizedBox(height: 8),
              _RecentActivityCard(
                title: 'Fever evaluation',
                subtitle: '1 day ago • Non-urgent',
                icon: Icons.thermostat,
                color: Colors.green,
                onTap: () => Navigator.of(context).pushNamed('/triage/result/124'),
              ),

              const SizedBox(height: 32),

              // Health tips
              Text(
                'Health Tips',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          'Stay Hydrated',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Drink at least 8 glasses of water daily to maintain good health and support your immune system.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showNetworkStatus(BuildContext context, NetworkStatus status) {
    final statusText = status.canSync
        ? 'Online - Full functionality available'
        : status.isOnline
            ? 'Limited connectivity - API unavailable'
            : 'Offline - Using local AI only';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(statusText),
        duration: const Duration(seconds: 3),
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

  void _showLogoutDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ref.read(authStateProvider.notifier).logout();
              Navigator.of(context).pushReplacementNamed('/login');
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }

  Future<void> _syncData(BuildContext context, WidgetRef ref) async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    scaffoldMessenger.showSnackBar(
      const SnackBar(content: Text('Syncing data...')),
    );

    try {
      final result = await ref.read(syncServiceProvider).syncPendingSessions();
      
      if (result.success) {
        scaffoldMessenger.hideCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Sync complete: ${result.synced} synced, ${result.failed} failed'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        scaffoldMessenger.hideCurrentSnackBar();
        scaffoldMessenger.showSnackBar(
          SnackBar(
            content: Text('Sync failed: ${result.error ?? "Unknown error"}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      scaffoldMessenger.hideCurrentSnackBar();
      scaffoldMessenger.showSnackBar(
        SnackBar(
          content: Text('Sync error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color.withOpacity(0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, color: color, size: 32),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _RecentActivityCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: Icon(icon, color: color),
        ),
        title: Text(title),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}
