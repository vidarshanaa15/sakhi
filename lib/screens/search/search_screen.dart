import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../models/destination.dart';
import '../destination/destination_details_screen.dart';
import '../destination/widgets/safety_score_widget.dart' as safety;
import '../../widgets/empty_state.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  String _query = '';
  double _minSafety = 0;
  bool _hiddenGemsOnly = false;

  List<Destination> get _filtered {
    return mockDestinations.where((d) {
      final matchesQuery =
      d.name.toLowerCase().contains(_query.toLowerCase());
      final matchesSafety = d.safetyScore >= _minSafety;
      final matchesGem = !_hiddenGemsOnly || d.isHiddenGem;
      return matchesQuery && matchesSafety && matchesGem;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Search'),
        backgroundColor: AppTheme.background,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              0,
            ),
            child: TextField(
              decoration: const InputDecoration(
                hintText: 'Search destinations...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'MINIMUM SAFETY SCORE',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Text(
                      _minSafety.toStringAsFixed(1),
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Expanded(
                      child: Slider(
                        value: _minSafety,
                        min: 0,
                        max: 10,
                        divisions: 20,
                        label: _minSafety.toStringAsFixed(1),
                        activeColor: AppTheme.primary,
                        onChanged: (value) =>
                            setState(() => _minSafety = value),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
            ),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Hidden gems only'),
                  selected: _hiddenGemsOnly,
                  onSelected: (value) =>
                      setState(() => _hiddenGemsOnly = value),
                  selectedColor: AppTheme.accent.withOpacity(0.12),
                  checkmarkColor: AppTheme.accent,
                  side: BorderSide(
                    color: _hiddenGemsOnly
                        ? AppTheme.accent.withOpacity(0.3)
                        : Colors.black.withOpacity(0.08),
                  ),
                  labelStyle: TextStyle(
                    color: _hiddenGemsOnly
                        ? AppTheme.accent
                        : AppTheme.textSecondary,
                    fontWeight: _hiddenGemsOnly
                        ? FontWeight.w600
                        : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.sm),

          Divider(
            height: 1,
            color: Colors.black.withOpacity(0.06),
          ),

          const SizedBox(height: AppSpacing.sm),

          Expanded(
            child: results.isEmpty
                ? const EmptyState(
              icon: Icons.search_off,
              message: 'No destinations match your filters',
            )
                : ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
              ),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final dest = results[index];

                return Card(
                  margin: const EdgeInsets.only(
                    bottom: AppSpacing.sm + 4,
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(
                      AppSpacing.sm + 2,
                    ),
                    leading: Hero(
                      tag: 'dest-image-${dest.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        child: Image.network(
                          dest.imageUrl,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    title: Text(
                      dest.name,
                      style: const TextStyle(
                        color: AppTheme.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        dest.description,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    trailing: safety.SafetyScoreWidget(
                      score: dest.safetyScore,
                      compact: true,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DestinationDetailsScreen(
                          destination: dest,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}