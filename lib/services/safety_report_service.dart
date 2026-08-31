import 'dart:math';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/safety_report.dart';
import 'location_service.dart';

class SafetyReportService {
  final LocationService _locationService = LocationService();
  final _client = Supabase.instance.client;

  Future<void> submit({
    required String category,
    required String description,
  }) async {
    final position = await _locationService.getCurrentLocation();
    if (position == null) {
      throw Exception('Could not get current location');
    }

    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('You must be signed in to submit a report');
    }

    await _client.from('safety_reports').insert({
      'user_id': userId,
      'category': category,
      'description': description,
      'lat': position.latitude,
      'lng': position.longitude,
      'reported_at': DateTime.now().toUtc().toIso8601String(),
    });
  } // <-- this was missing, closes submit()

  Future<List<SafetyReport>> nearby({
    required double lat,
    required double lng,
    double radiusMeters = 2000,
  }) async {
    final latDelta = radiusMeters / 111320;
    final lngDelta = radiusMeters / (111320 * cos(lat * pi / 180));

    final res = await _client
        .from('safety_reports')
        .select()
        .gte('lat', lat - latDelta)
        .lte('lat', lat + latDelta)
        .gte('lng', lng - lngDelta)
        .lte('lng', lng + lngDelta)
        .order('reported_at', ascending: false);

    final all = (res as List)
        .map((r) => SafetyReport.fromJson(r as Map<String, dynamic>))
        .toList();

    return all.where((r) {
      final d = _haversineMeters(lat, lng, r.lat, r.lng);
      return d <= radiusMeters;
    }).toList();
  }

  double _haversineMeters(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371000.0;
    final dLat = (lat2 - lat1) * pi / 180;
    final dLon = (lon2 - lon1) * pi / 180;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180) *
            cos(lat2 * pi / 180) *
            sin(dLon / 2) *
            sin(dLon / 2);
    return R * 2 * atan2(sqrt(a), sqrt(1 - a));
  }
}