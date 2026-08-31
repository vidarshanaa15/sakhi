import 'package:flutter/material.dart';
import 'dart:io';
import '../../core/state/evidence_store.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Capture failed: $e')),
        );
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  Future<void> _uploadOne(String id) async {
    final evidence =
    EvidenceStore.instance.items.firstWhere((e) => e.id == id);

    setState(() => _busy = true);
    try {
      await _service.upload(evidence);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e')),
        );
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Evidence'),
        backgroundColor: AppTheme.background,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _busy ? null : _capture,
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.camera_alt_outlined),
        label: const Text('Capture'),
      ),
      body: AnimatedBuilder(
        animation: EvidenceStore.instance,
        builder: (context, _) {
          final items = EvidenceStore.instance.items;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppTheme.primary.withOpacity(0.07),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      size: 32,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'No evidence captured yet',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(AppSpacing.md),
            itemCount: items.length,
            itemBuilder: (context, i) {
              final e = items[i];

              return Card(
                margin: const EdgeInsets.only(bottom: AppSpacing.sm + 4),
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm,
                    ),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(
                        AppSpacing.radiusSm,
                      ),
                      child: Image.file(
                        File(e.filePath),
                        width: 58,
                        height: 58,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      e.timestamp.toLocal().toString(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            e.uploaded
                                ? Icons.check_circle_outline
                                : Icons.cloud_upload_outlined,
                            size: 14,
                            color: e.uploaded
                                ? AppTheme.safetyGreen
                                : AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            e.uploaded ? 'Uploaded' : 'Pending upload',
                            style: TextStyle(
                              color: e.uploaded
                                  ? AppTheme.safetyGreen
                                  : AppTheme.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    trailing: e.uploaded
                        ? const Icon(
                      Icons.check_circle,
                      color: AppTheme.safetyGreen,
                    )
                        : IconButton(
                      icon: const Icon(
                        Icons.cloud_upload_outlined,
                        color: AppTheme.primary,
                      ),
                      onPressed: () => _uploadOne(e.id),
                    ),
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