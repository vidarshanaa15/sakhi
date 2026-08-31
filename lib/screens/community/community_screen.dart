import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../models/travel_circle.dart';

/// Body content only — AppShell supplies the shared AppBar (title + "+" action).
class CommunityScreen extends StatelessWidget {
  const CommunityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(AppSpacing.md),
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: 'Find traveler circles near you...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusPill)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusPill)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusPill)),
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        const _SectionLabel('YOUR SISTERHOOD CIRCLES'),
        const SizedBox(height: AppSpacing.sm),
        ...mockYourCircles.map((c) => _CircleCard(circle: c)),
        const SizedBox(height: AppSpacing.lg),
        const _SectionLabel('SUGGESTED FOR NEXT TRIP'),
        const SizedBox(height: AppSpacing.sm),
        ...mockSuggestedCircles.map((c) => _CircleCard(circle: c)),
        const SizedBox(height: AppSpacing.lg),
        _FormCircleCta(onTap: () {}), // TODO(backend): create-circle flow
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        color: AppTheme.primary.withOpacity(0.75),
      ),
    );
  }
}

class _CircleCard extends StatelessWidget {
  final TravelCircle circle;
  const _CircleCard({required this.circle});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        onTap: () {}, // TODO(backend): open circle detail / chat threads
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                child: Image.network(circle.imageUrl, width: 64, height: 64, fit: BoxFit.cover),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _Pill(
                          text: circle.location,
                          background: AppTheme.primaryLight.withOpacity(0.12),
                          textColor: AppTheme.primaryLight,
                        ),
                        const SizedBox(width: 6),
                        _Pill(
                          text: '${circle.memberCount} sakhis',
                          background: AppTheme.safetyGreen.withOpacity(0.12),
                          textColor: AppTheme.safetyGreen,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(circle.name, style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      circle.activityLabel,
                      style: TextStyle(color: AppTheme.safetyGreen, fontSize: 13, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppTheme.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pill extends StatelessWidget {
  final String text;
  final Color background;
  final Color textColor;
  const _Pill({required this.text, required this.background, required this.textColor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: background, borderRadius: BorderRadius.circular(AppSpacing.radiusPill)),
      child: Text(text, style: TextStyle(color: textColor, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }
}

class _FormCircleCta extends StatelessWidget {
  final VoidCallback onTap;
  const _FormCircleCta({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.primary,
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      child: InkWell(
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(color: AppTheme.accent, shape: BoxShape.circle),
                child: const Icon(Icons.add, color: Colors.white),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Form Your Own Circle',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Plan security coordinates with peers',
                      style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: 13),
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
}