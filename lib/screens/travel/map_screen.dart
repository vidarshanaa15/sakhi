import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../services/location_service.dart';
import '../../services/route_service.dart';

import '../../models/destination.dart';
import '../../services/geocoding_service.dart';

import '../../models/route_leg.dart';
import '../../services/safety_service.dart';

import '../../widgets/safety_pill.dart';

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
  final LocationService _locationService = LocationService();

  final RouteService _routeService = RouteService();

  final GeocodingService _geocodingService = GeocodingService();

  final SafetyService _safetyService = SafetyService();

  final MapController _mapController = MapController();

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

    _mapController.move(location, 15);
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
          content: Text('Could not find this destination.'),
        ),
      );

      return;
    }

    final routes = await _routeService.getAlternativeRoutes(
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
          content: Text('Could not find a route to this destination.'),
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
      i < mockScores.length ? i : mockScores.length - 1];

      final evaluated = await _safetyService.evaluateRoute(
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
    _mapController.move(_currentLocation!, 15);
  }

  String _routeLabel(int index, RouteLeg route) {
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
      return 'Safest route';
    }

    if (route.durationSeconds == fastestDuration) {
      return 'Fastest route';
    }

    return 'Route ${index + 1}';
  }

  IconData _routeIcon(int index, RouteLeg route) {
    final label = _routeLabel(index, route);
    if (label == 'Safest route') return Icons.shield_rounded;
    if (label == 'Fastest route') return Icons.bolt_rounded;
    return Icons.alt_route_rounded;
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTheme.background,
        body: Center(
          child: CircularProgressIndicator(
            color: AppTheme.primary,
          ),
        ),
      );
    }

    if (_currentLocation == null) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: Text(widget.destination.name),
          backgroundColor: AppTheme.background,
        ),
        body: const Center(
          child: Text(
            'Unable to access your location.\n'
                'Please enable location permissions.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(widget.destination.name),
        backgroundColor: AppTheme.background,
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
                userAgentPackageName: 'com.example.sakhi_app',
              ),

              if (_routes.isNotEmpty)
                PolylineLayer(
                  polylines: _routes.asMap().entries.map((entry) {
                    final index = entry.key;
                    final route = entry.value;
                    final isSelected = index == _selectedRouteIndex;

                    return Polyline(
                      points: route.points,
                      strokeWidth: isSelected ? 6 : 4,
                      color: isSelected
                          ? AppTheme.primary
                          : AppTheme.textSecondary.withOpacity(0.4),
                    );
                  }).toList(),
                ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation!,
                    width: 46,
                    height: 46,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 3,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.navigation_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          Positioned(
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: 90,
            child: Column(
              children: [
                if (_routes.isNotEmpty)
                  _RouteOptionsCard(
                    routes: _routes,
                    selectedIndex: _selectedRouteIndex,
                    labelFor: _routeLabel,
                    iconFor: _routeIcon,
                    onSelect: (index) {
                      setState(() {
                        _selectedRouteIndex = index;
                      });
                      _fitRoute(_routes[index].points);
                    },
                  ),
                const SizedBox(height: AppSpacing.sm + 2),
                _RouteActionButton(
                  loading: _loadingRoute,
                  hasRoutes: _routes.isNotEmpty,
                  onTap: _createRoute,
                ),
              ],
            ),
          ),

          Positioned(
            right: AppSpacing.md,
            bottom: AppSpacing.md,
            child: FloatingActionButton(
              backgroundColor: AppTheme.surface,
              foregroundColor: AppTheme.primary,
              elevation: 3,
              onPressed: _goToCurrentLocation,
              child: const Icon(Icons.my_location_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _RouteActionButton extends StatelessWidget {
  final bool loading;
  final bool hasRoutes;
  final VoidCallback onTap;

  const _RouteActionButton({
    required this.loading,
    required this.hasRoutes,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      clipBehavior: Clip.antiAlias,
      elevation: 5,
      shadowColor: AppTheme.primary.withOpacity(0.25),
      child: InkWell(
        onTap: loading ? null : onTap,
        child: Ink(
          decoration: BoxDecoration(
            color: AppTheme.primary,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.md,
            vertical: AppSpacing.md,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(9),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: loading
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
                    : const Icon(
                  Icons.route_rounded,
                  color: Colors.white,
                  size: 21,
                ),
              ),
              const SizedBox(width: AppSpacing.sm + 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      loading
                          ? 'Finding route...'
                          : (hasRoutes
                          ? 'Refresh route'
                          : 'Find route'),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    if (!hasRoutes && !loading) ...[
                      const SizedBox(height: 2),
                      Text(
                        'See alternate paths & safety scores',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.72),
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!loading)
                const Icon(
                  Icons.arrow_forward_rounded,
                  color: Colors.white,
                  size: 21,
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RouteOptionsCard extends StatelessWidget {
  final List<RouteLeg> routes;
  final int? selectedIndex;
  final String Function(int, RouteLeg) labelFor;
  final IconData Function(int, RouteLeg) iconFor;
  final ValueChanged<int> onSelect;

  const _RouteOptionsCard({
    required this.routes,
    required this.selectedIndex,
    required this.labelFor,
    required this.iconFor,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(
          color: Colors.black.withOpacity(0.06),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Choose your route',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          ...routes.asMap().entries.map((entry) {
            final index = entry.key;
            final route = entry.value;
            final isSelected = index == selectedIndex;

            return Padding(
              padding: const EdgeInsets.only(
                bottom: AppSpacing.sm,
              ),
              child: InkWell(
                borderRadius: BorderRadius.circular(
                  AppSpacing.radiusMd,
                ),
                onTap: () => onSelect(index),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm + 2),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primary.withOpacity(0.07)
                        : AppTheme.background,
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusMd,
                    ),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primary
                          : Colors.black.withOpacity(0.07),
                      width: isSelected ? 1.4 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppTheme.primary
                              : AppTheme.primary.withOpacity(0.07),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          iconFor(index, route),
                          size: 16,
                          color: isSelected
                              ? Colors.white
                              : AppTheme.primary,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm + 4),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: [
                            Text(
                              labelFor(index, route),
                              style: const TextStyle(
                                color: AppTheme.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.straighten_outlined,
                                  size: 13,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${route.distanceKm.toStringAsFixed(1)} km',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.sm),
                                const Icon(
                                  Icons.schedule_outlined,
                                  size: 13,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  '${route.durationMinutes} min',
                                  style: const TextStyle(
                                    fontSize: 11.5,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      SafetyPill(score: route.safetyScore),
                    ],
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}