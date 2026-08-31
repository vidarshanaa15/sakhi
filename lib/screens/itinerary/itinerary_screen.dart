import 'package:flutter/material.dart';
import '../../core/state/itinerary_store.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../destination/destination_details_screen.dart';
import '../destination/widgets/safety_score_widget.dart' as safety;
import '../../widgets/empty_state.dart';
import '../travel/itinerary_map_screen.dart';

class ItineraryScreen extends StatelessWidget {
  const ItineraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('My Itinerary'),
        backgroundColor: AppTheme.background,
      ),
      body: ListenableBuilder(
        listenable: ItineraryStore.instance,
        builder: (context, _) {
          final items = ItineraryStore.instance.items;

          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.map_outlined,
              message:
              'No destinations added yet.\nBrowse and tap "Add to itinerary" to build your trip.',
            );
          }

          return Column(
            children: [
              Expanded(
                child: ReorderableListView.builder(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.sm,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  buildDefaultDragHandles: false,
                  itemCount: items.length,
                  onReorder: (oldIndex, newIndex) {
                    ItineraryStore.instance.reorder(oldIndex, newIndex);
                  },
                  itemBuilder: (context, index) {
                    final dest = items[index];

                    return _ItineraryCard(
                      key: ValueKey(dest.id),
                      index: index,
                      name: dest.name,
                      imageUrl: dest.imageUrl,
                      safetyScore: dest.safetyScore,
                      onDelete: () =>
                          ItineraryStore.instance.remove(dest.id),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              DestinationDetailsScreen(destination: dest),
                        ),
                      ),
                    );
                  },
                ),
              ),
              _NextStepButton(
                stopCount: items.length,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ItineraryMapScreen(),
                    ),
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class _ItineraryCard extends StatelessWidget {
  final int index;
  final String name;
  final String imageUrl;
  final double safetyScore;
  final VoidCallback onDelete;
  final VoidCallback onTap;

  const _ItineraryCard({
    super.key,
    required this.index,
    required this.name,
    required this.imageUrl,
    required this.safetyScore,
    required this.onDelete,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: Row(
            children: [
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusSm,
                    ),
                    child: Image.network(
                      imageUrl,
                      width: 68,
                      height: 68,
                      fit: BoxFit.cover,
                    ),
                  ),
                  Positioned(
                    left: 4,
                    top: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Day ${index + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.sm + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style:
                      Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    safety.SafetyScoreWidget(
                      score: safetyScore,
                      compact: true,
                    ),
                  ],
                ),
              ),
              ReorderableDragStartListener(
                index: index,
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusSm,
                    ),
                  ),
                  child: const Icon(
                    Icons.drag_indicator_rounded,
                    size: 20,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: 5),
              InkWell(
                borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                onTap: () => _confirmDelete(context),
                child: Container(
                  padding: const EdgeInsets.all(7),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusSm,
                    ),
                  ),
                  child: const Icon(
                    Icons.delete_outline_rounded,
                    size: 20,
                    color: AppTheme.accent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove stop?'),
        content: Text('$name will be removed from your itinerary.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.accent,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

class _NextStepButton extends StatelessWidget {
  final int stopCount;
  final VoidCallback onTap;

  const _NextStepButton({
    required this.stopCount,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.md,
          AppSpacing.sm,
          AppSpacing.md,
          AppSpacing.md,
        ),
        child: Material(
          borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
          clipBehavior: Clip.antiAlias,
          elevation: 4,
          shadowColor: AppTheme.primary.withOpacity(0.25),
          child: InkWell(
            onTap: onTap,
            child: Ink(
              decoration: BoxDecoration(
                color: AppTheme.primary,
                borderRadius: BorderRadius.circular(
                  AppSpacing.radiusMd,
                ),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(9),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.map_rounded,
                      color: Colors.white,
                      size: 21,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm + 4),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'View my trip on the map',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Next: pick a safe route for each of your $stopCount stops',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.72),
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.white,
                    size: 21,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}