import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/state/itinerary_store.dart';
import '../../models/route_leg_group.dart';
import '../../services/itinerary_route_service.dart';
import '../../services/location_service.dart';

import '../../widgets/safety_pill.dart';

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

  List<RouteLegGroup> _legGroups = [];

  int? _expandedGroupIndex;

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

    final destinations = ItineraryStore.instance.items;

    final legGroups = await _routeService.buildRoutePlan(
      currentLocation: location,
      destinations: destinations,
    );

    if (!mounted) return;

    setState(() {
      _legGroups = legGroups;
      _loadingRoutes = false;
    });

    _fitAllRoutes();
  }

  void _fitAllRoutes() {
    final List<LatLng> allPoints = [];

    for (final group in _legGroups) {
      allPoints.addAll(group.selectedLeg.points);
    }

    if (allPoints.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(allPoints);

    _mapController.fitCamera(
      CameraFit.bounds(
        bounds: bounds,
        padding: const EdgeInsets.all(50),
      ),
    );
  }

  void _goToCurrentLocation() {
    if (_currentLocation == null) return;
    _mapController.move(_currentLocation!, 13);
  }

  void _selectAlternative(int groupIndex, int alternativeIndex) {
    setState(() {
      _legGroups[groupIndex].select(alternativeIndex);
    });
    _fitAllRoutes();
  }

  void _toggleExpanded(int groupIndex) {
    setState(() {
      _expandedGroupIndex =
          _expandedGroupIndex == groupIndex ? null : groupIndex;
    });
  }

  double get _totalDistance {
    return _legGroups.fold(
      0,
      (total, group) => total + group.selectedLeg.distanceMeters,
    );
  }

  int get _totalDuration {
    return _legGroups.fold(
      0,
      (total, group) => total + group.selectedLeg.durationMinutes,
    );
  }

  String _formatDuration(int minutes) {
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;

    if (hours == 0) return '$remainingMinutes min';
    if (remainingMinutes == 0) return '$hours hr';
    return '$hours hr $remainingMinutes min';
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_currentLocation == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Sakhi Trip')),
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
        appBar: AppBar(title: const Text('Sakhi Trip')),
        body: const Center(child: Text('Your itinerary is empty.')),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        title: const Text('Sakhi Trip'),
        elevation: 0,
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
                userAgentPackageName: 'com.example.sakhi_app',
              ),

              if (_legGroups.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    for (final group in _legGroups)
                      for (int i = 0; i < group.alternatives.length; i++)
                        if (i != group.selectedIndex)
                          Polyline(
                            points: group.alternatives[i].points,
                            strokeWidth: 3,
                            color: colorScheme.outline.withValues(alpha: 0.35),
                          ),
                    for (final group in _legGroups)
                      Polyline(
                        points: group.selectedLeg.points,
                        strokeWidth: 5,
                        color: colorScheme.primary,
                      ),
                  ],
                ),

              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation!,
                    width: 46,
                    height: 46,
                    child: Container(
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 3),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.2),
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
                  ..._legGroups.asMap().entries.map((entry) {
                    final index = entry.key;
                    final group = entry.value;

                    return Marker(
                      point: group.selectedLeg.end,
                      width: 40,
                      height: 40,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.primary,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              color: Colors.black.withValues(alpha: 0.2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${index + 1}',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          Positioned(
            left: 16,
            right: 16,
            bottom: 24,
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_loadingRoutes)
                    const Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 12),
                        Text('Building your trip route...'),
                      ],
                    )
                  else if (_legGroups.isEmpty)
                    const Text(
                      'Could not create routes for this itinerary.',
                      textAlign: TextAlign.center,
                    )
                  else ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _TripStat(
                          icon: Icons.flag_rounded,
                          label: 'Stops',
                          value: '${_legGroups.length}',
                        ),
                        _TripStat(
                          icon: Icons.straighten_rounded,
                          label: 'Distance',
                          value:
                              '${(_totalDistance / 1000).toStringAsFixed(1)} km',
                        ),
                        _TripStat(
                          icon: Icons.schedule_rounded,
                          label: 'Travel time',
                          value: _formatDuration(_totalDuration),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    Divider(color: colorScheme.outlineVariant.withValues(alpha: 0.5)),
                    const SizedBox(height: 6),
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 280),
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: _legGroups.length,
                        itemBuilder: (context, index) {
                          final group = _legGroups[index];
                          final leg = group.selectedLeg;
                          final expanded = _expandedGroupIndex == index;

                          return _LegCard(
                            index: index,
                            leg: leg,
                            group: group,
                            expanded: expanded,
                            onTap: () => _toggleExpanded(index),
                            onSelectAlternative: (altIndex) =>
                                _selectAlternative(index, altIndex),
                            formatDuration: _formatDuration,
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          Positioned(
            right: 16,
            bottom: 260,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: colorScheme.surface,
              foregroundColor: colorScheme.primary,
              onPressed: _goToCurrentLocation,
              child: const Icon(Icons.my_location_rounded),
            ),
          ),
        ],
      ),
    );
  }
}

class _TripStat extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _TripStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Column(
      children: [
        Icon(icon, size: 18, color: colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            color: colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _LegCard extends StatelessWidget {
  final int index;
  final dynamic leg;
  final RouteLegGroup group;
  final bool expanded;
  final VoidCallback onTap;
  final ValueChanged<int> onSelectAlternative;
  final String Function(int) formatDuration;

  const _LegCard({
    required this.index,
    required this.leg,
    required this.group,
    required this.expanded,
    required this.onTap,
    required this.onSelectAlternative,
    required this.formatDuration,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasAlternatives = group.alternatives.length > 1;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.5),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: hasAlternatives ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 30,
                      height: 30,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        '${leg.startName} → ${leg.endName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ),
                    if (hasAlternatives)
                      Icon(
                        expanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        color: colorScheme.onSurfaceVariant,
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.straighten_rounded,
                        size: 13, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 3),
                    Text(
                      '${leg.distanceKm.toStringAsFixed(1)} km',
                      style: TextStyle(
                        fontSize: 12.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.schedule_rounded,
                        size: 13, color: colorScheme.onSurfaceVariant),
                    const SizedBox(width: 3),
                    Text(
                      formatDuration(leg.durationMinutes),
                      style: TextStyle(
                        fontSize: 12.5,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Spacer(),
                    if (leg.safetyScore != null)
                      SafetyPill(
                        score: leg.safetyScore,
                        label:
                            '${leg.safetyScore!.toStringAsFixed(1)}/10 • ${leg.safetyLevel}',
                      ),
                  ],
                ),
                if (expanded && hasAlternatives) ...[
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: group.alternatives.asMap().entries.map<Widget>((altEntry) {
                      final altIndex = altEntry.key;
                      final alt = altEntry.value;
                      final selected = altIndex == group.selectedIndex;

                      return InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () => onSelectAlternative(altIndex),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? colorScheme.primary.withValues(alpha: 0.1)
                                : colorScheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selected
                                  ? colorScheme.primary
                                  : colorScheme.outlineVariant
                                      .withValues(alpha: 0.6),
                              width: selected ? 1.6 : 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                selected
                                    ? Icons.check_circle_rounded
                                    : Icons.circle_outlined,
                                size: 14,
                                color: selected
                                    ? colorScheme.primary
                                    : colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Route ${altIndex + 1} • '
                                '${alt.distanceKm.toStringAsFixed(1)} km',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? colorScheme.primary
                                      : colorScheme.onSurface,
                                ),
                              ),
                              if (alt.safetyScore != null) ...[
                                const SizedBox(width: 6),
                                SafetyPill(score: alt.safetyScore),
                              ],
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}