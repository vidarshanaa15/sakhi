import 'package:flutter/material.dart';
import 'dart:io';
import '../../core/state/evidence_store.dart';
import '../../services/evidence_service.dart';

class EvidenceScreen extends StatefulWidget {
  const EvidenceScreen({super.key});

  @override
  State<EvidenceScreen> createState() => _EvidenceScreenState();
}

class _EvidenceScreenState extends State<EvidenceScreen> {
  final _service = EvidenceService();
  bool _busy = false;

  Future<void> _capture() async {
    setState(() => _busy = true);
    try {
      await _service.capturePhoto();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Capture failed: $e')));
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _uploadOne(String id) async {
    final evidence = EvidenceStore.instance.items.firstWhere((e) => e.id == id);
    setState(() => _busy = true);
    try {
      await _service.upload(evidence);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Upload failed: $e')));
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Evidence')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _capture,
        icon: const Icon(Icons.camera_alt),
        label: const Text('Capture'),
      ),
      body: AnimatedBuilder(
        animation: EvidenceStore.instance,
        builder: (context, _) {
          final items = EvidenceStore.instance.items;
          if (items.isEmpty) {
            return const Center(child: Text('No evidence captured yet'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final e = items[i];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: Image.file(File(e.filePath),
                        width: 56, height: 56, fit: BoxFit.cover),
                  ),
                  title: Text(e.timestamp.toLocal().toString()),
                  subtitle: Text(e.uploaded ? 'Uploaded' : 'Pending upload'),
                  trailing: e.uploaded
                      ? const Icon(Icons.check_circle, color: Colors.green)
                      : IconButton(
                          icon: const Icon(Icons.cloud_upload),
                          onPressed: () => _uploadOne(e.id),
                        ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}