import 'package:latlong2/latlong.dart';

import '../models/destination.dart';
import '../models/route_leg.dart';
import '../models/route_leg_group.dart';
import 'geocoding_service.dart';
import 'route_service.dart';
import 'safety_service.dart';

class ItineraryRouteService {
  final GeocodingService _geocodingService =
      GeocodingService();

  final RouteService _routeService =
      RouteService();

  final SafetyService _safetyService =
      SafetyService();

  /// Builds the full itinerary plan. Each hop (current location -> stop 1,
  /// stop 1 -> stop 2, etc.) is returned as its own [RouteLegGroup] so the
  /// UI can let the user pick a route alternative independently for every
  /// leg of the trip, not just one destination.
  Future<List<RouteLegGroup>> buildRoutePlan({
    required LatLng currentLocation,
    required List<Destination> destinations,
  }) async {
    final List<RouteLegGroup> legGroups = [];

    LatLng startLocation = currentLocation;
    String startName = 'Current Location';

    for (final destination in destinations) {
      final destinationLocation =
          await _geocodingService.getCoordinates(
        destination.name,
      );

      if (destinationLocation == null) {
        continue;
      }

      final routes =
          await _routeService.getAlternativeRoutes(
        start: startLocation,
        destination: destinationLocation,
      );

      if (routes.isEmpty) {
        continue;
      }

      final List<RouteLeg> evaluatedRoutes = [];

      for (int i = 0; i < routes.length; i++) {
        final route = routes[i];

        final leg = RouteLeg(
          startName: startName,
          endName: destination.name,
          start: startLocation,
          end: destinationLocation,
          points: route.points,
          distanceMeters: route.distanceMeters,
          durationSeconds: route.durationSeconds,
        );

        // Temporary mock scores.
        // These will come from FastAPI later.
        final mockScores = [7.4, 9.1, 6.8];

        final score = mockScores[
          i < mockScores.length
              ? i
              : mockScores.length - 1
        ];

        final evaluated =
            await _safetyService.evaluateRoute(
          leg,
          mockScore: score,
        );

        evaluatedRoutes.add(evaluated);
      }

      final group = RouteLegGroup(
        alternatives: evaluatedRoutes,
      );

      // Default each leg to its safest alternative. The user can
      // change this per-leg from the itinerary UI.
      group.selectedIndex = group.safestIndex;

      legGroups.add(group);

      // Next hop starts where this destination is, regardless of which
      // alternative ends up selected (all alternatives share the same
      // start/end points, just different paths between them).
      startLocation = destinationLocation;
      startName = destination.name;
    }

    return legGroups;
  }
}