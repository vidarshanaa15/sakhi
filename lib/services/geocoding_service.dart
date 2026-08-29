import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

class GeocodingService {
  static const String _baseUrl =
      'https://nominatim.openstreetmap.org';

  Future<LatLng?> getCoordinates(String placeName) async {
    final url = Uri.parse(
      '$_baseUrl/search'
      '?q=${Uri.encodeComponent(placeName)}'
      '&format=json'
      '&limit=1',
    );

    try {
      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'SakhiApp/1.0',
        },
      );

      if (response.statusCode != 200) {
        return null;
      }

      final List data = jsonDecode(response.body);

      if (data.isEmpty) {
        return null;
      }

      final result = data[0];

      final latitude =
          double.tryParse(result['lat'].toString());

      final longitude =
          double.tryParse(result['lon'].toString());

      if (latitude == null || longitude == null) {
        return null;
      }

      return LatLng(latitude, longitude);
    } catch (e) {
      return null;
    }
  }
}