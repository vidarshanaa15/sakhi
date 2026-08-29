import 'package:flutter/material.dart';
import '../../models/destination.dart';
import '../destination/destination_details_screen.dart';
import '../destination/widgets/safety_score_widget.dart';
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
      final matchesQuery = d.name.toLowerCase().contains(_query.toLowerCase());
      final matchesSafety = d.safetyScore >= _minSafety;
      final matchesGem = !_hiddenGemsOnly || d.isHiddenGem;
      return matchesQuery && matchesSafety && matchesGem;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final results = _filtered;

    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              decoration: InputDecoration(
                hintText: 'Search destinations...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: (value) => setState(() => _query = value),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Min safety score: ${_minSafety.toStringAsFixed(1)}',
                          style: Theme.of(context).textTheme.bodySmall),
                      Slider(
                        value: _minSafety,
                        min: 0,
                        max: 10,
                        divisions: 20,
                        label: _minSafety.toStringAsFixed(1),
                        onChanged: (value) => setState(() => _minSafety = value),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('Hidden gems only'),
                  selected: _hiddenGemsOnly,
                  onSelected: (value) => setState(() => _hiddenGemsOnly = value),
                ),
              ],
            ),
          ),
          const Divider(height: 24),
          Expanded(
            child: results.isEmpty
                ? const EmptyState(icon: Icons.search_off, message: 'No destinations match your filters')
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: results.length,
              itemBuilder: (context, index) {
                final dest = results[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(12),
                    leading: Hero(
                      tag: 'dest-image-${dest.id}',
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(dest.imageUrl, width: 56, height: 56, fit: BoxFit.cover),
                      ),
                    ),
                    title: Text(dest.name),
                    subtitle: Text(
                      dest.description,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: SafetyScoreWidget(score: dest.safetyScore, compact: true),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DestinationDetailsScreen(destination: dest),
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