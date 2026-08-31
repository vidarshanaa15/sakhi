import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_spacing.dart';
import 'aadhaar_verify_screen.dart';

class DigiLockerAuthScreen extends StatefulWidget {
  const DigiLockerAuthScreen({super.key});

  @override
  State<DigiLockerAuthScreen> createState() => _DigiLockerAuthScreenState();
}

class _DigiLockerAuthScreenState extends State<DigiLockerAuthScreen> {
  bool _consentGiven = false;
  bool _isRedirecting = false;

  Future<void> _continueWithDigiLocker() async {
    if (!_consentGiven) return;
    setState(() => _isRedirecting = true);
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() => _isRedirecting = false);
    Navigator.push(context, MaterialPageRoute(builder: (_) => const AadhaarVerifyScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(title: const Text('Verify with DigiLocker')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.sm, AppSpacing.lg, AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                ),
                child: const Icon(Icons.verified_user_outlined, size: 32, color: AppTheme.primary),
              ),
              const SizedBox(height: AppSpacing.md),
              Text('Confirm your identity', style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Sakhi verifies solo travelers through DigiLocker so emergency '
                    'contacts, law enforcement, and community members can trust '
                    'who they\'re connecting with. Your Aadhaar number is never '
                    'stored — only your name, gender, and year of birth are used '
                    'to confirm your identity.',
                style: TextStyle(height: 1.5, color: AppTheme.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'WHAT HAPPENS NEXT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.0,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm + 4),
                      const _StepLine(number: '1', text: 'Log in to DigiLocker and grant consent'),
                      const _StepLine(number: '2', text: 'DigiLocker gives you a password-protected file and share code'),
                      const _StepLine(number: '3', text: "You'll enter that share code on the next screen"),
                      const _StepLine(number: '4', text: "We verify it against UIDAI's signature — no Aadhaar number stored"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              CheckboxListTile(
                value: _consentGiven,
                onChanged: (value) => setState(() => _consentGiven = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                activeColor: AppTheme.primary,
                title: Text(
                  'I consent to sharing my DigiLocker-verified Aadhaar demographic details with Sakhi',
                  style: TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: (_consentGiven && !_isRedirecting) ? _continueWithDigiLocker : null,
                  icon: _isRedirecting
                      ? const SizedBox(
                    height: 16,
                    width: 16,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : const Icon(Icons.lock_outline),
                  label: Text(_isRedirecting ? 'Redirecting to DigiLocker…' : 'Continue with DigiLocker'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StepLine extends StatelessWidget {
  final String number;
  final String text;
  const _StepLine({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: AppTheme.primary,
            child: Text(number, style: const TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, height: 1.3))),
        ],
      ),
    );
  }
}