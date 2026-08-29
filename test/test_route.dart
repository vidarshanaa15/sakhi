import 'package:latlong2/latlong.dart';
import 'services/route_service.dart';

Future<void> main() async {
  final routeService = RouteService();

  // Example: Chennai coordinates
  final start = LatLng(12.9716, 80.2209);
  final destination = LatLng(13.0827, 80.2707);

  print('Requesting alternative routes...');

  final routes = await routeService.getAlternativeRoutes(
    start: start,
    destination: destination,
  );

  print('Number of routes: ${routes.length}');

  for (int i = 0; i < routes.length; i++) {
    final route = routes[i];

    print(
      'Route ${i + 1}: '
      '${route.distanceKm.toStringAsFixed(2)} km, '
      '${route.durationMinutes} min, '
      '${route.points.length} points',
    );
  }
}