import 'package:flutter/material.dart';
import '../../core/state/auth_store.dart';
import '../../models/user_profile.dart';
import '../../services/evidence_service.dart';
import '../report/submit_report_screen.dart';
import '../evidence/evidence_screen.dart';

/// Landing screen after login: welcome + at-a-glance usage stats.
/// Stats are mocked until a backend/analytics endpoint exists —
/// swap _mockStats for a real fetch in initState when that's ready.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _mockStats = [
    _StatItem(icon: Icons.map_outlined, label: 'Trips planned', value: '3'),
    _StatItem(icon: Icons.shield_outlined, label: 'Avg. safety score', value: '8.1'),
    _StatItem(icon: Icons.groups_outlined, label: 'Communities joined', value: '2'),
    _StatItem(icon: Icons.watch_outlined, label: 'Pendant status', value: 'Not paired'),
  ];

  Future<void> _captureEvidence(BuildContext context) async {
    try {
      final evidence = await EvidenceService().capturePhoto();
      if (evidence == null) return; // user cancelled the camera
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Evidence captured and saved'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EvidenceScreen()),
            ),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not capture evidence: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = mockUserProfile;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sakhi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.report_problem_outlined),
            tooltip: 'Report a safety concern',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SubmitReportScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            tooltip: 'Capture evidence',
            onPressed: () => _captureEvidence(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Welcome back, ${user.name.split(' ').first}',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 4),
          ListenableBuilder(
            listenable: AuthStore.instance,
            builder: (context, _) => Text(
              AuthStore.instance.isVerified
                  ? 'Identity verified via DigiLocker'
                  : 'Identity not verified yet',
              style: TextStyle(
                color: AuthStore.instance.isVerified ? Colors.green : Colors.orange,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(height: 20),

          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.05,
            children: _mockStats.map((s) => _StatCard(item: s)).toList(),
          ),

          const SizedBox(height: 24),
          Card(
            color: Colors.deepPurple.withOpacity(0.06),
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome_outlined, color: Colors.deepPurple),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Try the itinerary chatbot — describe a trip and it\'ll '
                          'suggest hidden gems along with popular spots.',
                      style: TextStyle(fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatItem {
  final IconData icon;
  final String label;
  final String value;
  const _StatItem({required this.icon, required this.label, required this.value});
}

class _StatCard extends StatelessWidget {
  final _StatItem item;
  const _StatCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(item.icon, color: Colors.deepPurple),
            const SizedBox(height: 8),
            Text(
              item.value,
              style: Theme.of(context).textTheme.titleLarge,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              item.label,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}