import 'package:latlong2/latlong.dart';

import 'models/route_leg.dart';
import 'services/safety_service.dart';

Future<void> main() async {
  final safetyService = SafetyService();

  final leg = RouteLeg(
    startName: 'Start',
    endName: 'Destination',
    start: LatLng(12.9716, 80.2209),
    end: LatLng(13.0827, 80.2707),
    points: const [],
    distanceMeters: 18660,
    durationSeconds: 1440,
  );

  final safeRoute = await safetyService.evaluateRoute(
    leg,
    mockScore: 9.1,
  );

  final riskyRoute = await safetyService.evaluateRoute(
    leg,
    mockScore: 6.2,
  );

  print('Safe route:');
  print('Score: ${safeRoute.safetyScore}');
  print('Level: ${safeRoute.safetyLevel}');
  print('Reasons: ${safeRoute.safetyReasons}');

  print('');

  print('Riskier route:');
  print('Score: ${riskyRoute.safetyScore}');
  print('Level: ${riskyRoute.safetyLevel}');
  print('Reasons: ${riskyRoute.safetyReasons}');
}