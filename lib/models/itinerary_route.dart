import 'package:latlong2/latlong.dart';
import 'package:sakhi_app/models/destination.dart';

class ItineraryLeg {
  final Destination from;
  final Destination to;

  final List<LatLng> points;

  final double distanceMeters;
  final double durationSeconds;

  // Later from FastAPI
  final double? safetyScore;
  final List<String> safetyReasons;

  const ItineraryLeg({
    required this.from,
    required this.to,
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    this.safetyScore,
    this.safetyReasons = const [],
  });
}