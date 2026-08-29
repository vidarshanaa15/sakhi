import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class RouteResult {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;

  RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  double get distanceKm => distanceMeters / 1000;

  int get durationMinutes =>
      (durationSeconds / 60).round();
}

class RouteService {
  static const String _baseUrl =
      'https://router.project-osrm.org';

  Future<RouteResult?> getRoute({
    required LatLng start,
    required LatLng destination,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/route/v1/driving/'
      '${start.longitude},${start.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return null;
      }

      final data = jsonDecode(response.body);

      if (data['code'] != 'Ok') {
        return null;
      }

      final route = data['routes'][0];

      final coordinates =
          route['geometry']['coordinates'] as List;

      final points = coordinates.map<LatLng>((coordinate) {
        return LatLng(
          (coordinate[1] as num).toDouble(),
          (coordinate[0] as num).toDouble(),
        );
      }).toList();

      return RouteResult(
        points: points,
        distanceMeters:
            (route['distance'] as num).toDouble(),
        durationSeconds:
            (route['duration'] as num).toDouble(),
      );
    } catch (e) {
      return null;
    }
  }

  // NEW: Get multiple alternative routes.
  Future<List<RouteResult>> getAlternativeRoutes({
    required LatLng start,
    required LatLng destination,
  }) async {
    final url = Uri.parse(
      '$_baseUrl/route/v1/driving/'
      '${start.longitude},${start.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson&alternatives=true',
    );

    try {
      final response = await http.get(url);

      if (response.statusCode != 200) {
        return [];
      }

      final data = jsonDecode(response.body);

      if (data['code'] != 'Ok') {
        return [];
      }

      final routes = data['routes'] as List;

      return routes.map<RouteResult>((route) {
        final coordinates =
            route['geometry']['coordinates'] as List;

        final points =
            coordinates.map<LatLng>((coordinate) {
          return LatLng(
            (coordinate[1] as num).toDouble(),
            (coordinate[0] as num).toDouble(),
          );
        }).toList();

        return RouteResult(
          points: points,
          distanceMeters:
              (route['distance'] as num).toDouble(),
          durationSeconds:
              (route['duration'] as num).toDouble(),
        );
      }).toList();
    } catch (e) {
      return [];
    }
  }
}