import 'package:flutter/material.dart';
import '../../core/theme/app_spacing.dart';
import '../../core/theme/app_theme.dart';
import '../../services/safety_report_service.dart';

class SubmitReportScreen extends StatefulWidget {
  const SubmitReportScreen({super.key});

  @override
  State<SubmitReportScreen> createState() => _SubmitReportScreenState();
}

class _SubmitReportScreenState extends State<SubmitReportScreen> {
  final _service = SafetyReportService();
  final _descController = TextEditingController();
  String _category = 'Poor lighting';
  bool _busy = false;

  static const _categories = [
    'Poor lighting',
    'Harassment',
    'Unsafe area',
    'Suspicious activity',
    'Other',
  ];

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      await _service.submit(
        category: _category,
        description: _descController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Report submitted')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Submit failed: $e')),
        );
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  void dispose() {
    _descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Report a Safety Concern'),
        backgroundColor: AppTheme.background,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.md),
        children: [
          Text(
            'HELP KEEP YOUR COMMUNITY SAFE',
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          Text(
            'Share what you noticed',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          DropdownButtonFormField<String>(
            initialValue: _category,
            decoration: const InputDecoration(
              labelText: 'Category',
            ),
            items: _categories
                .map(
                  (c) => DropdownMenuItem(
                value: c,
                child: Text(c),
              ),
            )
                .toList(),
            onChanged: (v) => setState(() => _category = v!),
          ),

          const SizedBox(height: AppSpacing.md),

          TextField(
            controller: _descController,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Tell us what happened or what you noticed',
              alignLabelWithHint: true,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _busy ? null : _submit,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sm),
                child: Text(
                  _busy ? 'Submitting...' : 'Submit report',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}