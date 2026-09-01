import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../../core/state/itinerary_store.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../models/route_leg_group.dart';
import '../../services/itinerary_route_service.dart';
import '../../services/location_service.dart';

import '../../widgets/safety_pill.dart';

class ItineraryMapScreen extends StatefulWidget {
  const ItineraryMapScreen({super.key});

  @override
  State<ItineraryMapScreen> createState() => _ItineraryMapScreenState();
}

class _ItineraryMapScreenState extends State<ItineraryMapScreen> {
  final LocationService _locationService = LocationService();

  final ItineraryRouteService _routeService = ItineraryRouteService();

  final MapController _mapController = MapController();

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
          title: const Text('Sakhi Trip'),
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

    if (ItineraryStore.instance.items.isEmpty) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        appBar: AppBar(
          title: const Text('Sakhi Trip'),
          backgroundColor: AppTheme.background,
        ),
        body: const Center(
          child: Text(
            'Your itinerary is empty.',
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
        title: const Text('Sakhi Trip'),
        backgroundColor: AppTheme.background,
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
                      for (int i = 0;
                      i < group.alternatives.length;
                      i++)
                        if (i != group.selectedIndex)
                          Polyline(
                            points: group.alternatives[i].points,
                            strokeWidth: 3,
                            color: AppTheme.textSecondary
                                .withOpacity(0.35),
                          ),
                    for (final group in _legGroups)
                      Polyline(
                        points: group.selectedLeg.points,
                        strokeWidth: 5,
                        color: AppTheme.primary,
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
                            color: AppTheme.primary,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 4,
                              color: Colors.black.withOpacity(0.2),
                            ),
                          ],
                        ),
                        child: Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary,
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
            left: AppSpacing.md,
            right: AppSpacing.md,
            bottom: AppSpacing.lg,
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.surface,
                borderRadius: BorderRadius.circular(
                  AppSpacing.radiusLg,
                ),
                border: Border.all(
                  color: Colors.black.withOpacity(0.06),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_loadingRoutes)
                    const Column(
                      children: [
                        CircularProgressIndicator(
                          color: AppTheme.primary,
                        ),
                        SizedBox(height: AppSpacing.sm + 4),
                        Text(
                          'Building your trip route...',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    )
                  else if (_legGroups.isEmpty)
                    const Text(
                      'Could not create routes for this itinerary.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                      ),
                    )
                  else ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _TripStat(
                            icon: Icons.flag_outlined,
                            label: 'Stops',
                            value: '${_legGroups.length}',
                          ),
                          _TripStat(
                            icon: Icons.straighten_outlined,
                            label: 'Distance',
                            value:
                            '${(_totalDistance / 1000).toStringAsFixed(1)} km',
                          ),
                          _TripStat(
                            icon: Icons.schedule_outlined,
                            label: 'Travel time',
                            value: _formatDuration(_totalDuration),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm + 2),
                      Divider(
                        color: Colors.black.withOpacity(0.06),
                      ),
                      const SizedBox(height: AppSpacing.xs),
                      ConstrainedBox(
                        constraints: const BoxConstraints(
                          maxHeight: 280,
                        ),
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: _legGroups.length,
                          itemBuilder: (context, index) {
                            final group = _legGroups[index];
                            final leg = group.selectedLeg;
                            final expanded =
                                _expandedGroupIndex == index;

                            return _LegCard(
                              index: index,
                              leg: leg,
                              group: group,
                              expanded: expanded,
                              onTap: () => _toggleExpanded(index),
                              onSelectAlternative: (altIndex) =>
                                  _selectAlternative(
                                    index,
                                    altIndex,
                                  ),
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
            right: AppSpacing.md,
            bottom: 260,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: AppTheme.surface,
              foregroundColor: AppTheme.primary,
              elevation: 3,
              onPressed: _goToCurrentLocation,
              child: const Icon(
                Icons.my_location_rounded,
              ),
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
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: AppTheme.primary.withOpacity(0.07),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            size: 17,
            color: AppTheme.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.xs + 1),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 14,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10.5,
            color: AppTheme.textSecondary,
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
    final hasAlternatives = group.alternatives.length > 1;

    return Container(
      margin: const EdgeInsets.only(
        bottom: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(
          AppSpacing.radiusMd,
        ),
        border: Border.all(
          color: Colors.black.withOpacity(0.06),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(
          AppSpacing.radiusMd,
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: hasAlternatives ? onTap : null,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.sm + 2),
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
                        color: AppTheme.primary.withOpacity(0.08),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '${index + 1}',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm + 2),
                    Expanded(
                      child: Text(
                        '${leg.startName} → ${leg.endName}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                          fontSize: 13.5,
                        ),
                      ),
                    ),
                    if (hasAlternatives)
                      Icon(
                        expanded
                            ? Icons.expand_less_rounded
                            : Icons.expand_more_rounded,
                        color: AppTheme.textSecondary,
                      ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                // FIX: this used to be a single Row with a Spacer + SafetyPill,
                // which overflowed horizontally when the pill's label text
                // ("9.1/10 • Very Safe") was too long to fit alongside the
                // distance/duration on narrow screens. Wrap lets the pill
                // drop to its own line instead of overflowing.
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: AppSpacing.sm + 4,
                  runSpacing: AppSpacing.xs,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.straighten_outlined,
                          size: 13,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${leg.distanceKm.toStringAsFixed(1)} km',
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.schedule_outlined,
                          size: 13,
                          color: AppTheme.textSecondary,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          formatDuration(leg.durationMinutes),
                          style: const TextStyle(
                            fontSize: 11.5,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    if (leg.safetyScore != null)
                      SafetyPill(
                        score: leg.safetyScore,
                        label:
                        '${leg.safetyScore!.toStringAsFixed(1)}/10 • ${leg.safetyLevel}',
                      ),
                  ],
                ),
                if (expanded && hasAlternatives) ...[
                  const SizedBox(height: AppSpacing.sm + 2),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: group.alternatives
                        .asMap()
                        .entries
                        .map<Widget>((altEntry) {
                      final altIndex = altEntry.key;
                      final alt = altEntry.value;
                      final selected =
                          altIndex == group.selectedIndex;

                      return InkWell(
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusSm,
                        ),
                        onTap: () =>
                            onSelectAlternative(altIndex),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm + 2,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            color: selected
                                ? AppTheme.primary.withOpacity(0.08)
                                : AppTheme.surface,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusSm,
                            ),
                            border: Border.all(
                              color: selected
                                  ? AppTheme.primary
                                  : Colors.black.withOpacity(0.08),
                              width: selected ? 1.4 : 1,
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
                                    ? AppTheme.primary
                                    : AppTheme.textSecondary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                'Route ${altIndex + 1} • '
                                    '${alt.distanceKm.toStringAsFixed(1)} km',
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w600,
                                  color: selected
                                      ? AppTheme.primary
                                      : AppTheme.textPrimary,
                                ),
                              ),
                              if (alt.safetyScore != null) ...[
                                const SizedBox(width: 6),
                                SafetyPill(
                                  score: alt.safetyScore,
                                ),
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