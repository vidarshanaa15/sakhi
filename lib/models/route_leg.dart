import 'package:latlong2/latlong.dart';

class RouteLeg {
  final String startName;
  final String endName;

  final LatLng start;
  final LatLng end;

  final List<LatLng> points;

  final double distanceMeters;
  final double durationSeconds;

  // Safety information
  final double? safetyScore;
  final String? safetyLevel;
  final List<String> safetyReasons;

  const RouteLeg({
    required this.startName,
    required this.endName,
    required this.start,
    required this.end,
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
    this.safetyScore,
    this.safetyLevel,
    this.safetyReasons = const [],
  });

  double get distanceKm => distanceMeters / 1000;

  int get durationMinutes =>
      (durationSeconds / 60).round();

  bool get hasSafetyData =>
      safetyScore != null;
}