import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/location_service.dart';
import '../../services/route_service.dart';

import '../../models/destination.dart';
import '../../services/geocoding_service.dart';

import '../../models/route_leg.dart';
import '../../services/safety_service.dart';

class MapScreen extends StatefulWidget {
  final Destination destination;

  const MapScreen({
    super.key,
    required this.destination,
  });

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final LocationService _locationService =
      LocationService();

  final RouteService _routeService =
      RouteService();

  final GeocodingService _geocodingService =
    GeocodingService();

  final SafetyService _safetyService =
    SafetyService();

  final MapController _mapController =
      MapController();

  LatLng? _currentLocation;

  List<RouteLeg> _routes = [];
  int? _selectedRouteIndex;

  bool _loading = true;
  bool _loadingRoute = false;

  @override
  void initState() {
    super.initState();
    _loadCurrentLocation();
  }

  Future<void> _loadCurrentLocation() async {
    final Position? position =
        await _locationService.getCurrentLocation();

    if (!mounted) return;

    if (position == null) {
      setState(() {
        _loading = false;
      });
      return;
    }

    final location = LatLng(
      position.latitude,
      position.longitude,
    );

    setState(() {
      _currentLocation = location;
      _loading = false;
    });

    _mapController.move(
      location,
      15,
    );
  }

  Future<void> _createRoute() async {
  if (_currentLocation == null) return;

  setState(() {
    _loadingRoute = true;
    _routes = [];
    _selectedRouteIndex = null;
  });

  final destination =
      await _geocodingService.getCoordinates(
    widget.destination.name,
  );

  if (!mounted) return;

  if (destination == null) {
    setState(() {
      _loadingRoute = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not find this destination.',
        ),
      ),
    );

    return;
  }

  final routes =
      await _routeService.getAlternativeRoutes(
    start: _currentLocation!,
    destination: destination,
  );

  if (!mounted) return;

  if (routes.isEmpty) {
    setState(() {
      _loadingRoute = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Could not find a route to this destination.',
        ),
      ),
    );

    return;
  }

  final List<RouteLeg> evaluatedRoutes = [];

  for (int i = 0; i < routes.length; i++) {
    final route = routes[i];

    final leg = RouteLeg(
      startName: 'Current Location',
      endName: widget.destination.name,
      start: _currentLocation!,
      end: destination,
      points: route.points,
      distanceMeters: route.distanceMeters,
      durationSeconds: route.durationSeconds,
    );

    // Temporary safety scores.
    // These will eventually come from FastAPI.
    final mockScores = [7.4, 9.1, 6.8];

    final score = mockScores[
      i < mockScores.length ? i : mockScores.length - 1
    ];

    final evaluated =
        await _safetyService.evaluateRoute(
      leg,
      mockScore: score,
    );

    evaluatedRoutes.add(evaluated);
  }

  setState(() {
    _routes = evaluatedRoutes;
    _selectedRouteIndex = 0;
    _loadingRoute = false;
  });

  _fitRoute(_routes[0].points);
}
  void _fitRoute(List<LatLng> points) {
    if (points.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(points);

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  void _goToCurrentLocation() {
    if (_currentLocation == null) return;

    _mapController.move(
      _currentLocation!,
      15,
    );
  }

  Widget _buildRouteSelectionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Choose your route',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            ..._routes.asMap().entries.map((entry) {
              final index = entry.key;
              final route = entry.value;

              final isSelected =
                  index == _selectedRouteIndex;

              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedRouteIndex = index;
                  });

                  _fitRoute(route.points);
                },
                child: Container(
                  margin: const EdgeInsets.only(
                    bottom: 8,
                  ),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: isSelected
                          ? Colors.green
                          : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    borderRadius:
                        BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected
                            ? Icons.radio_button_checked
                            : Icons.radio_button_off,
                        color: isSelected
                            ? Colors.green
                            : Colors.grey,
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            Text(
                              _routeLabel(index, route),
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              '${route.distanceKm.toStringAsFixed(1)} km • '
                              '${route.durationMinutes} min',
                            ),

                            const SizedBox(height: 4),

                            Text(
                              'Safety: '
                              '${route.safetyScore?.toStringAsFixed(1)}/10',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight.w600,
                                color: route.safetyScore! >= 8
                                    ? Colors.green
                                    : route.safetyScore! >= 6.5
                                        ? Colors.orange
                                        : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  String _routeLabel(
    int index,
    RouteLeg route,
  ) {
    if (route.safetyScore == null) {
      return 'Route ${index + 1}';
    }

    final safestScore = _routes
        .map((r) => r.safetyScore ?? 0)
        .reduce((a, b) => a > b ? a : b);

    final fastestDuration = _routes
        .map((r) => r.durationSeconds)
        .reduce((a, b) => a < b ? a : b);

    if (route.safetyScore == safestScore) {
      return '⭐ Safest Route';
    }

    if (route.durationSeconds == fastestDuration) {
      return '⚡ Fastest Route';
    }

    return 'Route ${index + 1}';
  }


  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_currentLocation == null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.destination.name),
        ),
        body: const Center(
          child: Text(
            'Unable to access your location.\n'
            'Please enable location permissions.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sakhi Map'),
      ),

      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,

            options: MapOptions(
              initialCenter: _currentLocation!,
              initialZoom: 15,
            ),

            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'com.example.sakhi_app',
              ),

              if (_routes.isNotEmpty)
              PolylineLayer(
                polylines: _routes.asMap().entries.map((entry) {
                  final index = entry.key;
                  final route = entry.value;

                  final isSelected =
                      index == _selectedRouteIndex;

                  return Polyline(
                    points: route.points,
                    strokeWidth: isSelected ? 6 : 4,
                    color: isSelected
                        ? Colors.green
                        : Colors.grey,
                  );
                }).toList(),
              ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation!,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.location_pin,
                      size: 45,
                      color: Colors.red,
                    ),
                  ),
                ],
              ),
            ],
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 90,
            child: Column(
              children: [
                if (_routes.isNotEmpty)
                  _buildRouteSelectionCard(),
                const SizedBox(height: 8),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed:
                        _loadingRoute
                            ? null
                            : _createRoute,
                    icon: _loadingRoute
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.route),
                    label: Text(
                      _loadingRoute
                          ? 'Finding Route...'
                          : 'Find Route',
                    ),
                  ),
                ),
              ],
            ),
          ),

          Positioned(
            right: 16,
            bottom: 24,
            child: FloatingActionButton(
              onPressed: _goToCurrentLocation,
              child: const Icon(
                Icons.my_location,
              ),
            ),
          ),
        ],
      ),
    );
  }
}