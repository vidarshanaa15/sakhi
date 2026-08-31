import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../models/safety_report.dart';
import '../../services/location_service.dart';
import '../../services/safety_report_service.dart';
import 'submit_report_screen.dart';

class NearbyReportsScreen extends StatefulWidget {
  const NearbyReportsScreen({super.key});

  @override
  State<NearbyReportsScreen> createState() => _NearbyReportsScreenState();
}

class _NearbyReportsScreenState extends State<NearbyReportsScreen> {
  final _reportService = SafetyReportService();
  final _locationService = LocationService();
  List<SafetyReport> _reports = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final position = await _locationService.getCurrentLocation();
      if (position == null) throw Exception('Location unavailable');
      final reports = await _reportService.nearby(
        lat: position.latitude,
        lng: position.longitude,
      );
      setState(() => _reports = reports);
    } catch (e) {
      setState(() => _error = e.toString());
    }
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Community Reports'),
        backgroundColor: AppTheme.background,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const SubmitReportScreen(),
            ),
          );
          _load();
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add_alert_outlined),
        label: const Text('Report'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(
          child: CircularProgressIndicator(
            color: AppTheme.primary,
          ),
        )
            : _error != null
            ? ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Text(
                'Could not load reports: $_error',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                ),
              ),
            ),
          ],
        )
            : _reports.isEmpty
            ? ListView(
          children: [
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xxl),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.07),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      size: 32,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'No nearby reports yet',
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        )
            : ListView.builder(
          padding: const EdgeInsets.all(AppSpacing.md),
          itemCount: _reports.length,
          itemBuilder: (context, i) {
            final r = _reports[i];

            return Card(
              margin: const EdgeInsets.only(
                bottom: AppSpacing.sm + 4,
              ),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.sm,
                ),
                leading: Container(
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: AppTheme.accent.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(
                      AppSpacing.radiusSm,
                    ),
                  ),
                  child: const Icon(
                    Icons.report_outlined,
                    color: AppTheme.accent,
                  ),
                ),
                title: Text(
                  r.category,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    r.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12.5,
                    ),
                  ),
                ),
                trailing: Text(
                  '${r.timestamp.toLocal()}'.split('.').first,
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}