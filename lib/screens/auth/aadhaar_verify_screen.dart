import 'package:flutter/material.dart';
import '../../services/aadhaar_verification_service.dart';
import '../../models/aadhaar_verification_result.dart';
import '../../core/state/auth_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_spacing.dart';
import '../../widgets/app_shell.dart';

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
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const AppShell()), (route) => false);
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Aadhaar Verification')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Upload the ZIP file DigiLocker gave you and enter the share code (its password).',
              style: TextStyle(height: 1.4, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: AppSpacing.lg),

            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: AppSpacing.md),
                foregroundColor: AppTheme.primary,
                side: BorderSide(color: AppTheme.primary.withOpacity(0.35)),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                alignment: Alignment.centerLeft,
              ),
              onPressed: _isVerifying ? null : _pickZipFile,
              icon: const Icon(Icons.attach_file),
              label: Text(_selectedFileName ?? 'Select offline e-KYC ZIP file'),
            ),
            const SizedBox(height: AppSpacing.md),

            TextField(
              controller: _shareCodeController,
              enabled: !_isVerifying,
              decoration: const InputDecoration(labelText: 'Share code', hintText: 'e.g. A1B2'),
            ),
            const SizedBox(height: AppSpacing.lg),

            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: _isVerifying ? null : _verify,
                child: _isVerifying
                    ? const SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
                    : const Text('Verify identity'),
              ),
            ),

            if (_result != null) ...[
              const SizedBox(height: AppSpacing.lg),
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
    final color = ok ? AppTheme.safetyGreen : AppTheme.safetyRed;
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(ok ? Icons.check_circle : Icons.error_outline, color: color),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: ok
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Identity verified', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                const SizedBox(height: 4),
                Text('${result.name} · ${result.gender} · born ${result.yearOfBirth}'),
                const SizedBox(height: 2),
                Text(
                  'Reference: ${result.referenceId}',
                  style: TextStyle(fontSize: 12, color: AppTheme.textSecondary),
                ),
              ],
            )
                : Text(result.errorMessage ?? 'Verification failed', style: TextStyle(color: color)),
          ),
        ],
      ),
    );
  }
}