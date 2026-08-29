import 'package:flutter/material.dart';
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
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Report submitted')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Submit failed: $e')));
      }
    }
    if (mounted) setState(() => _busy = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Report a Safety Concern')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: const InputDecoration(
                labelText: 'Category',
                border: OutlineInputBorder(),
              ),
              items: _categories
                  .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                  .toList(),
              onChanged: (v) => setState(() => _category = v!),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _descController,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _busy ? null : _submit,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(_busy ? 'Submitting...' : 'Submit report'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}