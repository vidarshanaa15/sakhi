import 'package:flutter/material.dart';
import '../../core/state/itinerary_store.dart';
import '../../models/destination.dart';
import 'widgets/safety_score_widget.dart';
import '../travel/map_screen.dart';

class DestinationDetailsScreen extends StatelessWidget {
  final Destination destination;
  const DestinationDetailsScreen({super.key, required this.destination});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 240,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'dest-image-${destination.id}',
                child: Image.network(destination.imageUrl, fit: BoxFit.cover),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(child: Text(destination.name, style: Theme.of(context).textTheme.headlineSmall)),
                      SafetyScoreWidget(score: destination.safetyScore),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(destination.description, style: Theme.of(context).textTheme.bodyLarge),
                  const SizedBox(height: 24),
                  ListenableBuilder(
                    listenable: ItineraryStore.instance,
                    builder: (context, _) {
                      final added = ItineraryStore.instance.isAdded(destination.id);
                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => ItineraryStore.instance.toggle(destination),
                          icon: Icon(added ? Icons.check_circle : Icons.map_outlined),
                          label: Text(added ? 'Added to itinerary' : 'Add to itinerary'),
                          style: added
                              ? FilledButton.styleFrom(backgroundColor: Colors.green)
                              : null,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
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
                        icon: const Icon(Icons.navigation),
                        label: const Text('Start Journey'),
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