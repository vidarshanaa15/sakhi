import 'package:flutter/material.dart';
import '../../core/state/itinerary_store.dart';
import '../destination/destination_details_screen.dart';
import '../destination/widgets/safety_score_widget.dart';
import '../../widgets/empty_state.dart';

class ItineraryScreen extends StatelessWidget {
  const ItineraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Itinerary')),
      body: ListenableBuilder(
        listenable: ItineraryStore.instance,
        builder: (context, _) {
          final items = ItineraryStore.instance.items;

          if (items.isEmpty) {
            return const EmptyState(
              icon: Icons.map_outlined,
              message: 'No destinations added yet.\nBrowse and tap "Add to itinerary" to build your trip.',
            );
          }

          return ReorderableListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            onReorder: (oldIndex, newIndex) {
              // Reordering is cosmetic for now — store keeps insertion order.
              // Hook this up if/when the store supports explicit ordering.
            },
            itemBuilder: (context, index) {
              final dest = items[index];
              return Card(
                key: ValueKey(dest.id),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(dest.imageUrl, width: 56, height: 56, fit: BoxFit.cover),
                  ),
                  title: Text(dest.name),
                  subtitle: Row(
                    children: [
                      Text('Day ${index + 1}', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(width: 8),
                      SafetyScoreWidget(score: dest.safetyScore, compact: true),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => ItineraryStore.instance.remove(dest.id),
                  ),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => DestinationDetailsScreen(destination: dest)),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}