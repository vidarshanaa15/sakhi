import 'package:flutter/material.dart';
import '../../core/state/itinerary_store.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../models/destination.dart';
import 'widgets/safety_score_widget.dart';
import '../travel/map_screen.dart';

class DestinationDetailsScreen extends StatelessWidget {
  final Destination destination;

  const DestinationDetailsScreen({
    super.key,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: CustomScrollView(
        slivers: [
          // -----------------------------------------------------------------
          // Destination image
          // -----------------------------------------------------------------
          SliverAppBar(
            expandedHeight: 280,
            pinned: true,
            automaticallyImplyLeading: false,
            backgroundColor: AppTheme.background,
            surfaceTintColor: Colors.transparent,
            elevation: 0,

            leading: Padding(
              padding: const EdgeInsets.all(AppSpacing.sm),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.38),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                  tooltip: 'Back',
                ),
              ),
            ),

            actions: [
              Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.38),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(
                      Icons.share_outlined,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      // Share functionality was not present in the
                      // original screen, so no behavior is added here.
                    },
                    tooltip: 'Share',
                  ),
                ),
              ),
            ],

            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'dest-image-${destination.id}',
                child: Image.network(
                  destination.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: AppTheme.primary.withOpacity(0.08),
                      child: const Center(
                        child: Icon(
                          Icons.image_not_supported_outlined,
                          size: 48,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),

          // -----------------------------------------------------------------
          // Destination information
          // -----------------------------------------------------------------
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.background,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppSpacing.radiusLg),
                  topRight: Radius.circular(AppSpacing.radiusLg),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // -------------------------------------------------------
                    // Destination name + safety score
                    // -------------------------------------------------------
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            destination.name,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.w600,
                              height: 1.1,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        SafetyScoreWidget(
                          score: destination.safetyScore,
                        ),
                      ],
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // -------------------------------------------------------
                    // Description
                    // -------------------------------------------------------
                    Text(
                      'ABOUT THIS DESTINATION',
                      style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    Text(
                      destination.description,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: AppTheme.textSecondary,
                        height: 1.55,
                      ),
                    ),

                    const SizedBox(height: AppSpacing.xl),

                    // -------------------------------------------------------
                    // Safety information card
                    // -------------------------------------------------------
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppTheme.surface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        border: Border.all(
                          color: Colors.black.withOpacity(0.06),
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(
                              color: AppTheme.safetyGreen.withOpacity(0.10),
                              borderRadius: BorderRadius.circular(
                                AppSpacing.radiusSm,
                              ),
                            ),
                            child: const Icon(
                              Icons.shield_outlined,
                              color: AppTheme.safetyGreen,
                              size: 23,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Safety score',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                    color: AppTheme.textPrimary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Based on Sakhi safety information',
                                  style: TextStyle(
                                    color: AppTheme.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SafetyScoreWidget(
                            score: destination.safetyScore,
                            compact: true,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: AppSpacing.lg),

                    // -------------------------------------------------------
                    // Add to itinerary
                    // -------------------------------------------------------
                    ListenableBuilder(
                      listenable: ItineraryStore.instance,
                      builder: (context, _) {
                        final added =
                        ItineraryStore.instance.isAdded(destination.id);

                        return SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            onPressed: () {
                              ItineraryStore.instance.toggle(destination);
                            },
                            icon: Icon(
                              added
                                  ? Icons.check_circle_outline_rounded
                                  : Icons.map_outlined,
                            ),
                            label: Text(
                              added
                                  ? 'Added to itinerary'
                                  : 'Add to itinerary',
                            ),
                            style: added
                                ? FilledButton.styleFrom(
                              backgroundColor:
                              AppTheme.safetyGreen,
                              foregroundColor: Colors.white,
                            )
                                : null,
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // -------------------------------------------------------
                    // Start journey
                    // -------------------------------------------------------
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => MapScreen(
                                destination: destination,
                              ),
                            ),
                          );
                        },
                        icon: const Icon(
                          Icons.navigation_outlined,
                        ),
                        label: const Text('Start Journey'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.primary,
                          side: BorderSide(
                            color: AppTheme.primary.withOpacity(0.35),
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: AppSpacing.md,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: AppSpacing.sm),

                    // Small reassurance underneath actions
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            size: 15,
                            color: AppTheme.safetyGreen,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            'Sakhi verified destination',
                            style: TextStyle(
                              color: AppTheme.textSecondary,
                              fontSize: 11.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}