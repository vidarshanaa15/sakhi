import 'package:flutter/material.dart';
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
      appBar: AppBar(title: const Text('Community Reports')),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color.fromRGBO(59, 26, 50, 1),
        foregroundColor: const Color.from(alpha: 1, red: 1, green: 1, blue: 1),
        onPressed: () async {
          await Navigator.push(context,
              MaterialPageRoute(builder: (_) => SubmitReportScreen()));
          _load();
        },
        icon: const Icon(Icons.add_alert),
        label: const Text('Report'),
      ),
      body: RefreshIndicator(
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator())
            : _error != null
                ? ListView(children: [
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text('Could not load reports: $_error'),
                    )
                  ])
                : _reports.isEmpty
                    ? ListView(children: const [
                        Padding(
                          padding: EdgeInsets.all(24),
                          child: Text('No nearby reports yet'),
                        )
                      ])
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _reports.length,
                        itemBuilder: (context, i) {
                          final r = _reports[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            child: ListTile(
                              title: Text(r.category),
                              subtitle: Text(r.description),
                              trailing: Text(
                                '${r.timestamp.toLocal()}'.split('.').first,
                                style: const TextStyle(fontSize: 11),
                              ),
                            ),
                          );
                        },
                      ),
      ),
    );
  }
}