import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../models/destination.dart';
import '../destination/destination_details_screen.dart';
import '../destination/widgets/safety_score_widget.dart' as safety;
import '../evidence/evidence_screen.dart';
import '../report/nearby_reports_screen.dart';
import '../chatbot/chatbot_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Explore'),
        backgroundColor: AppTheme.background,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Ask Sakhi',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const ChatbotScreen(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            tooltip: 'Evidence',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const EvidenceScreen(),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.report_outlined),
            tooltip: 'Community Reports',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const NearbyReportsScreen(),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.xxl,
        ),
        itemCount: mockDestinations.length,
        itemBuilder: (context, index) {
          final dest = mockDestinations[index];

          return Card(
            margin: const EdgeInsets.only(bottom: AppSpacing.md),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DestinationDetailsScreen(
                    destination: dest,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'dest-image-${dest.id}',
                    child: Image.network(
                      dest.imageUrl,
                      height: 180,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Text(
                                dest.name,
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.sm),
                            safety.SafetyScoreWidget(
                              score: dest.safetyScore,
                              compact: true,
                            ),
                          ],
                        ),
                        if (dest.isHiddenGem)
                          Padding(
                            padding: const EdgeInsets.only(
                              top: AppSpacing.sm,
                            ),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                                vertical: AppSpacing.xs + 1,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.safetyGreen.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusPill,
                                ),
                              ),
                              child: const Text(
                                '🌱 Hidden gem',
                                style: TextStyle(
                                  color: AppTheme.safetyGreen,
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          dest.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 13,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}