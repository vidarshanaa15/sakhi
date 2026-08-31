// 
import '../core/network/api_client.dart';
import '../models/safety_report.dart';
import 'location_service.dart';

class SafetyReportService {
  final LocationService _locationService = LocationService();

  /// Flip to false once a real FastAPI backend is available.
  static const bool useMockData = false;

  static final List<SafetyReport> _mockReports = [
    SafetyReport(
      id: '1',
      category: 'Poor lighting',
      description: 'Street lights not working near the bus stop after 8pm.',
      lat: 13.1231,
      lng: 80.2953,
      timestamp: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    SafetyReport(
      id: '2',
      category: 'Unsafe area',
      description: 'Isolated stretch, very few people around even in daytime.',
      lat: 13.1245,
      lng: 80.2970,
      timestamp: DateTime.now().subtract(const Duration(days: 1)),
    ),
    SafetyReport(
      id: '3',
      category: 'Suspicious activity',
      description: 'Group loitering near the parking lot, made me uncomfortable.',
      lat: 13.1210,
      lng: 80.2940,
      timestamp: DateTime.now().subtract(const Duration(days: 2, hours: 5)),
    ),
  ];

  Future<void> submit({
    required String category,
    required String description,
  }) async {
    final position = await _locationService.getCurrentLocation();
    if (position == null) {
      throw Exception('Could not get current location');
    }

    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 400)); // simulate network
      _mockReports.insert(
        0,
        SafetyReport(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          category: category,
          description: description,
          lat: position.latitude,
          lng: position.longitude,
          timestamp: DateTime.now(),
        ),
      );
      return;
    }

    await ApiClient.instance.post('/reports', body: {
      'category': category,
      'description': description,
      'lat': position.latitude,
      'lng': position.longitude,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<List<SafetyReport>> nearby({
    required double lat,
    required double lng,
    double radiusMeters = 2000,
  }) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 400));
      return List.from(_mockReports);
    }

    final res = await ApiClient.instance.get('/reports/nearby', query: {
      'lat': lat,
      'lng': lng,
      'radius': radiusMeters,
    });
    return (res as List).map((r) => SafetyReport.fromJson(r)).toList();
  }
}