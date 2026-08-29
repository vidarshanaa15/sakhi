import 'route_leg.dart';

/// Holds every alternative route computed for a single hop in the
/// itinerary (e.g. "Current Location -> Stop 1", or "Stop 1 -> Stop 2"),
/// plus which one the user currently has selected.
class RouteLegGroup {
  final List<RouteLeg> alternatives;

  /// Index into [alternatives] that the user has chosen for this leg.
  int selectedIndex;

  RouteLegGroup({
    required this.alternatives,
    this.selectedIndex = 0,
  }) : assert(alternatives.isNotEmpty);

  RouteLeg get selectedLeg => alternatives[selectedIndex];

  String get startName => selectedLeg.startName;
  String get endName => selectedLeg.endName;

  void select(int index) {
    if (index < 0 || index >= alternatives.length) return;
    selectedIndex = index;
  }

  /// Convenience: index of the alternative with the highest safety score.
  int get safestIndex {
    int best = 0;
    double bestScore = -1;
    for (int i = 0; i < alternatives.length; i++) {
      final score = alternatives[i].safetyScore ?? 0;
      if (score > bestScore) {
        bestScore = score;
        best = i;
      }
    }
    return best;
  }
}