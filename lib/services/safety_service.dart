import '../models/route_leg.dart';

class SafetyService {
  Future<RouteLeg> evaluateRoute(
    RouteLeg leg, {
    double? mockScore,
  }) async {
    // Temporary mock safety score.
    // This will later come from FastAPI.
    final score = mockScore ?? 7.5;

    final roundedScore =
        double.parse(score.toStringAsFixed(1));

    String level;

    if (roundedScore >= 8.0) {
      level = 'Very Safe';
    } else if (roundedScore >= 6.5) {
      level = 'Moderately Safe';
    } else {
      level = 'Use Caution';
    }

    final reasons = _generateReasons(roundedScore);

    return RouteLeg(
      startName: leg.startName,
      endName: leg.endName,
      start: leg.start,
      end: leg.end,
      points: leg.points,
      distanceMeters: leg.distanceMeters,
      durationSeconds: leg.durationSeconds,
      safetyScore: roundedScore,
      safetyLevel: level,
      safetyReasons: reasons,
    );
  }

  List<String> _generateReasons(double score) {
    if (score >= 8.0) {
      return const [
        'Good road connectivity',
        'High activity along the route',
        'Good access to nearby facilities',
      ];
    }

    if (score >= 6.5) {
      return const [
        'Moderate activity along the route',
        'Some areas may have lower visibility',
        'Nearby facilities available',
      ];
    }

    return const [
      'Some isolated areas detected',
      'Lower activity along parts of the route',
      'Use additional caution at night',
    ];
  }
}