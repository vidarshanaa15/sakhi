import 'package:latlong2/latlong.dart';

/// A single computed route between two points in the itinerary,
/// with optional safety-scoring metadata attached.
class RouteLeg {
  final String startName;
  final String endName;

  final LatLng start;
  final LatLng end;

  final List<LatLng> points;

  final double distanceMeters;
  final double durationSeconds;

  final double? safetyScore;
  final String? safetyLevel;
  final List<String>? safetyReasons;

  RouteLeg({
    required this.startName,
    required this.endName,
    required this.start,
    required this.end,
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    this.safetyScore,
    this.safetyLevel,
    this.safetyReasons,
  });

  double get distanceKm => distanceMeters / 1000;

  int get durationMinutes => (durationSeconds / 60).round();
}