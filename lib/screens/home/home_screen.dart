import 'package:flutter/material.dart';
import '../../models/destination.dart';
import '../destination/destination_details_screen.dart';
import '../destination/widgets/safety_score_widget.dart';
import '../evidence/evidence_screen.dart';
import '../report/nearby_reports_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sakhi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            tooltip: 'Evidence',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EvidenceScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.report_outlined),
            tooltip: 'Community Reports',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NearbyReportsScreen()),
            ),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: mockDestinations.length,
        itemBuilder: (context, index) {
          final dest = mockDestinations[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => DestinationDetailsScreen(destination: dest)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Hero(
                    tag: 'dest-image-${dest.id}',
                    child: Image.network(dest.imageUrl, height: 160, width: double.infinity, fit: BoxFit.cover),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(dest.name, style: Theme.of(context).textTheme.titleMedium),
                            ),
                            SafetyScoreWidget(score: dest.safetyScore, compact: true),
                          ],
                        ),
                        if (dest.isHiddenGem)
                          const Padding(
                            padding: EdgeInsets.only(top: 4),
                            child: Text('🌱 Hidden gem', style: TextStyle(color: Colors.teal, fontSize: 12)),
                          ),
                        const SizedBox(height: 6),
                        Text(dest.description, maxLines: 2, overflow: TextOverflow.ellipsis),
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