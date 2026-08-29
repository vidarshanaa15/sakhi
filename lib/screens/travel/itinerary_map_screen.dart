import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/state/itinerary_store.dart';
import '../../models/route_leg.dart';
import '../../services/itinerary_route_service.dart';
import '../../services/location_service.dart';

class ItineraryMapScreen extends StatefulWidget {
  const ItineraryMapScreen({super.key});

  @override
  State<ItineraryMapScreen> createState() =>
      _ItineraryMapScreenState();
}

class _ItineraryMapScreenState
    extends State<ItineraryMapScreen> {
  final LocationService _locationService =
      LocationService();

  final ItineraryRouteService _routeService =
      ItineraryRouteService();

  final MapController _mapController =
      MapController();

  LatLng? _currentLocation;

  List<RouteLeg> _legs = [];

  bool _loading = true;
  bool _loadingRoutes = false;

  @override
  void initState() {
    super.initState();
    _loadTrip();
  }

  Future<void> _loadTrip() async {
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
      _loadingRoutes = true;
    });

    final destinations =
        ItineraryStore.instance.items;

    final legs =
        await _routeService.buildRoutePlan(
      currentLocation: location,
      destinations: destinations,
    );

    if (!mounted) return;

    setState(() {
      _legs = legs;
      _loadingRoutes = false;
    });

    _fitAllRoutes();
  }

  void _fitAllRoutes() {
    final List<LatLng> allPoints = [];

    for (final leg in _legs) {
      allPoints.addAll(leg.points);
    }

    if (allPoints.isEmpty) return;

    final bounds =
        LatLngBounds.fromPoints(allPoints);

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
      13,
    );
  }

  double get _totalDistance {
    return _legs.fold(
      0,
      (total, leg) =>
          total + leg.distanceMeters,
    );
  }

  int get _totalDuration {
    return _legs.fold(
      0,
      (total, leg) =>
          total + leg.durationMinutes,
    );
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours == 0) {
      return '$remainingMinutes min';
    }

    if (remainingMinutes == 0) {
      return '$hours hr';
    }

    return '$hours hr $remainingMinutes min';
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
          title: const Text('Sakhi Trip'),
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

    if (ItineraryStore.instance.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Sakhi Trip'),
        ),
        body: const Center(
          child: Text(
            'Your itinerary is empty.',
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sakhi Trip'),
      ),
      body: Stack(
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentLocation!,
              initialZoom: 10,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName:
                    'com.example.sakhi_app',
              ),

              // Draw every itinerary leg.
              if (_legs.isNotEmpty)
                PolylineLayer(
                  polylines: _legs.map((leg) {
                    return Polyline(
                      points: leg.points,
                      strokeWidth: 5,
                    );
                  }).toList(),
                ),

              MarkerLayer(
                markers: [
                  // Current location.
                  Marker(
                    point: _currentLocation!,
                    width: 50,
                    height: 50,
                    child: const Icon(
                      Icons.my_location,
                      size: 38,
                      color: Colors.blue,
                    ),
                  ),

                  // Destination markers.
                  ..._legs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final leg = entry.value;

                    return Marker(
                      point: leg.end,
                      width: 60,
                      height: 60,
                      child: Column(
                        children: [
                          Container(
                            padding:
                                const EdgeInsets.all(5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  blurRadius: 4,
                                  color: Colors.black
                                      .withValues(alpha: 0.2),
                                ),
                              ],
                            ),
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                          ),
                          const Icon(
                            Icons.location_pin,
                            size: 30,
                            color: Colors.red,
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // Trip information.
          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (_loadingRoutes)
                      const Column(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(height: 12),
                          Text(
                            'Building your trip route...',
                          ),
                        ],
                      )
                    else if (_legs.isEmpty)
                      const Text(
                        'Could not create routes for this itinerary.',
                        textAlign: TextAlign.center,
                      )
                    else ...[
                      Row(
                        mainAxisAlignment:
                            MainAxisAlignment.spaceAround,
                        children: [
                          _TripStat(
                            label: 'Stops',
                            value:
                                '${_legs.length}',
                          ),
                          _TripStat(
                            label: 'Distance',
                            value:
                                '${(_totalDistance / 1000).toStringAsFixed(1)} km',
                          ),
                          _TripStat(
                            label: 'Travel time',
                            value:
                                _formatDuration(
                              _totalDuration,
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      const Divider(),

                      const SizedBox(height: 8),

                      // Show individual legs.
                      SizedBox(
                        height: 170,
                        child: ListView.builder(
                          itemCount: _legs.length,
                          itemBuilder:
                              (context, index) {
                            final leg =
                                _legs[index];

                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                radius: 14,
                                child: Text(
                                  '${index + 1}',
                                ),
                              ),
                              title: Text(
                                '${leg.startName} → ${leg.endName}',
                                maxLines: 1,
                                overflow:
                                    TextOverflow.ellipsis,
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    '${leg.distanceKm.toStringAsFixed(1)} km • '
                                    '${_formatDuration(leg.durationMinutes)}',
                                  ),

                                  if (leg.safetyScore != null) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.shield_outlined,
                                          size: 16,
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Safety ${leg.safetyScore!.toStringAsFixed(1)}/10'
                                          ' • ${leg.safetyLevel}',
                                          style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          Positioned(
            right: 16,
            bottom: 220,
            child: FloatingActionButton(
              mini: true,
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

class _TripStat extends StatelessWidget {
  final String label;
  final String value;

  const _TripStat({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(label),
      ],
    );
  }
}