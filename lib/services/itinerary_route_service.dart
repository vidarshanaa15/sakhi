import 'package:latlong2/latlong.dart';

import '../models/destination.dart';
import '../models/route_leg.dart';
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

  Future<List<RouteLeg>> buildRoutePlan({
    required LatLng currentLocation,
    required List<Destination> destinations,
  }) async {
    final List<RouteLeg> legs = [];

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

      // For now, choose the safest route among
      // the available alternatives.
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

      // Keep all available route alternatives.
      // The UI will allow the user to choose one.
      legs.addAll(evaluatedRoutes);

      startLocation = destinationLocation;
      startName = destination.name;
    }

    return legs;
  }
}