import 'package:flutter/material.dart';
import '../../core/state/auth_store.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../models/user_profile.dart';
import '../../services/evidence_service.dart';
import '../report/nearby_reports_screen.dart';
import '../report/submit_report_screen.dart';
import '../evidence/evidence_screen.dart';
import '../chatbot/chatbot_screen.dart';

/// Landing screen after login: welcome + at-a-glance usage stats.
///
/// Stats are mocked until a backend/analytics endpoint exists —
/// swap _mockStats for a real fetch in initState when that's ready.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const _mockStats = [
    _StatItem(
      icon: Icons.map_outlined,
      label: 'Trips planned',
      value: '3',
    ),
    _StatItem(
      icon: Icons.shield_outlined,
      label: 'Avg. safety score',
      value: '8.1',
    ),
    _StatItem(
      icon: Icons.groups_outlined,
      label: 'Communities joined',
      value: '2',
    ),
    _StatItem(
      icon: Icons.watch_outlined,
      label: 'Pendant status',
      value: 'Not paired',
    ),
  ];

  Future<void> _captureEvidence(BuildContext context) async {
    try {
      final evidence = await EvidenceService().capturePhoto();

      if (evidence == null) return;

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Evidence captured and saved'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EvidenceScreen(),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not capture evidence: $e'),
        ),
      );
    }
  }

  void _openChatbot(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ChatbotScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = mockUserProfile;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: AppTheme.background,
        title: const Text('Sakhi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.report_problem_outlined),
            tooltip: 'Report a safety concern',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NearbyReportsScreen(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            tooltip: 'Capture evidence',
            onPressed: () => _captureEvidence(context),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        children: [
          // ---------------------------------------------------------------
          // Welcome section
          // ---------------------------------------------------------------
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome back,',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.name.split(' ').first,
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium
                          ?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primary.withOpacity(0.12),
                  ),
                ),
                child: const Icon(
                  Icons.person_outline_rounded,
                  color: AppTheme.primary,
                  size: 25,
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.md),

          // ---------------------------------------------------------------
          // Verification status
          // ---------------------------------------------------------------
          ListenableBuilder(
            listenable: AuthStore.instance,
            builder: (context, _) {
              final verified = AuthStore.instance.isVerified;

              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: AppSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: verified
                      ? AppTheme.safetyGreen.withOpacity(0.08)
                      : AppTheme.accent.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(
                    AppSpacing.radiusPill,
                  ),
                  border: Border.all(
                    color: verified
                        ? AppTheme.safetyGreen.withOpacity(0.16)
                        : AppTheme.accent.withOpacity(0.16),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      verified
                          ? Icons.verified_user_rounded
                          : Icons.gpp_maybe_outlined,
                      size: 17,
                      color: verified
                          ? AppTheme.safetyGreen
                          : AppTheme.accent,
                    ),
                    const SizedBox(width: 7),
                    Text(
                      verified
                          ? 'Identity verified via DigiLocker'
                          : 'Identity not verified yet',
                      style: TextStyle(
                        color: verified
                            ? AppTheme.safetyGreen
                            : AppTheme.accent,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          // ---------------------------------------------------------------
          // Travel footprint
          // ---------------------------------------------------------------
          Text(
            'YOUR TRAVEL FOOTPRINT',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: AppSpacing.sm + 2),

          // ---------------------------------------------------------------
          // Statistics
          // ---------------------------------------------------------------
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _mockStats.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: AppSpacing.sm + 4,
              mainAxisSpacing: AppSpacing.sm + 4,

              // Slightly shorter than the previous version.
              childAspectRatio: 1.35,
            ),
            itemBuilder: (context, index) {
              return _StatCard(
                item: _mockStats[index],
              );
            },
          ),

          const SizedBox(height: AppSpacing.xl),

          // ---------------------------------------------------------------
          // Quick actions
          // ---------------------------------------------------------------
          Text(
            'QUICK ACTIONS',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),

          const SizedBox(height: AppSpacing.sm + 2),

          // Plan with Sakhi AI
          Container(
            decoration: BoxDecoration(
              color: AppTheme.primary,
              borderRadius: BorderRadius.circular(
                AppSpacing.radiusMd,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  AppSpacing.radiusMd,
                ),
                onTap: () => _openChatbot(context),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.accent,
                          borderRadius: BorderRadius.circular(
                            AppSpacing.radiusSm,
                          ),
                        ),
                        child: const Icon(
                          Icons.auto_awesome_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Plan with Sakhi AI',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Get curated, women-verified routes & hidden gems',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.72),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // Capture evidence
          Container(
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(
                AppSpacing.radiusMd,
              ),
              border: Border.all(
                color: Colors.black.withOpacity(0.06),
              ),
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(
                AppSpacing.radiusMd,
              ),
              onTap: () => _captureEvidence(context),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.accent.withOpacity(0.10),
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                      ),
                      child: const Icon(
                        Icons.camera_alt_outlined,
                        color: AppTheme.accent,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Capture Evidence',
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Quickly save a photo to your safety evidence log',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      color: AppTheme.textSecondary,
                      size: 24,
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.md),

          // ---------------------------------------------------------------
          // Safety reminder
          // ---------------------------------------------------------------
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppTheme.background,
              borderRadius: BorderRadius.circular(
                AppSpacing.radiusMd,
              ),
              border: Border.all(
                color: AppTheme.safetyGreen.withOpacity(0.15),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.safetyGreen.withOpacity(0.10),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.shield_outlined,
                    color: AppTheme.safetyGreen,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm + 4),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Your safety comes first',
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: 13.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Sakhi uses verified community information to help you travel with confidence.',
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });
}

class _StatCard extends StatelessWidget {
  final _StatItem item;

  const _StatCard({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.07),
                  borderRadius: BorderRadius.circular(
                    AppSpacing.radiusSm,
                  ),
                ),
                child: Icon(
                  item.icon,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.value,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(
                      color: AppTheme.primary,
                      fontWeight: FontWeight.w700,
                      height: 1.0,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    item.label,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: AppTheme.textSecondary,
                      height: 1.15,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}