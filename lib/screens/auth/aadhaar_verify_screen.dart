import 'package:flutter/material.dart';
import '../../services/aadhaar_verification_service.dart';
import '../../models/aadhaar_verification_result.dart';
import '../../core/state/auth_store.dart';
import '../../widgets/app_shell.dart';

/// Collects the DigiLocker offline e-KYC ZIP + share code and runs
/// verification against UIDAI's public certificate (via the backend —
/// AadhaarVerificationService is currently a mock, see that file).
class AadhaarVerifyScreen extends StatefulWidget {
  const AadhaarVerifyScreen({super.key});

  @override
  State<AadhaarVerifyScreen> createState() => _AadhaarVerifyScreenState();
}

class _AadhaarVerifyScreenState extends State<AadhaarVerifyScreen> {
  final _shareCodeController = TextEditingController();
  final _service = AadhaarVerificationService();

  String? _selectedFileName;
  bool _isVerifying = false;
  AadhaarVerificationResult? _result;

  @override
  void dispose() {
    _shareCodeController.dispose();
    super.dispose();
  }

  // TODO: swap for a real file picker (e.g. file_picker package) once
  // that dependency is added — `flutter pub add file_picker`.
  void _pickZipFile() {
    setState(() => _selectedFileName = 'aadhaar-offline-ekyc.zip');
  }

  Future<void> _verify() async {
    if (_selectedFileName == null) {
      _showSnack('Select your DigiLocker ZIP file first');
      return;
    }
    if (_shareCodeController.text.trim().isEmpty) {
      _showSnack('Enter the share code from DigiLocker');
      return;
    }

    setState(() {
      _isVerifying = true;
      _result = null;
    });

    final result = await _service.verifyOfflineXml(
      zipFileName: _selectedFileName!,
      shareCode: _shareCodeController.text.trim(),
    );

    if (!mounted) return;
    setState(() {
      _isVerifying = false;
      _result = result;
    });

    if (result.verified) {
      AuthStore.instance.markVerified(result);

      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const AppShell()),
            (route) => false,
      );
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Aadhaar Verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Upload the ZIP file DigiLocker gave you and enter the share code (its password).',
              style: TextStyle(height: 1.4),
            ),
            const SizedBox(height: 20),

            OutlinedButton.icon(
              onPressed: _isVerifying ? null : _pickZipFile,
              icon: const Icon(Icons.attach_file),
              label: Text(_selectedFileName ?? 'Select offline e-KYC ZIP file'),
            ),
            const SizedBox(height: 16),

            TextField(
              controller: _shareCodeController,
              enabled: !_isVerifying,
              decoration: const InputDecoration(
                labelText: 'Share code',
                hintText: 'e.g. A1B2',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isVerifying ? null : _verify,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: _isVerifying
                      ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Text('Verify identity'),
                ),
              ),
            ),

            if (_result != null) ...[
              const SizedBox(height: 24),
              _VerificationResultCard(result: _result!),
            ],
          ],
        ),
      ),
    );
  }
}

class _VerificationResultCard extends StatelessWidget {
  final AadhaarVerificationResult result;
  const _VerificationResultCard({required this.result});

  @override
  Widget build(BuildContext context) {
    final ok = result.verified;
    return Card(
      color: ok ? Colors.green.withOpacity(0.08) : Colors.red.withOpacity(0.08),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(ok ? Icons.check_circle : Icons.error_outline, color: ok ? Colors.green : Colors.red),
            const SizedBox(width: 12),
            Expanded(
              child: ok
                  ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Identity verified', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${result.name} · ${result.gender} · born ${result.yearOfBirth}'),
                  Text('Reference: ${result.referenceId}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              )
                  : Text(result.errorMessage ?? 'Verification failed'),
            ),
          ],
        ),
      ),
    );
  }
}