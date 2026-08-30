import 'package:flutter/material.dart';
import 'aadhaar_verify_screen.dart';

/// Placeholder for the DigiLocker OAuth-style consent redirect.
///
/// In production this screen would launch a WebView / custom-tab to
/// DigiLocker's authorization URL, the user logs in and grants consent
/// there, and DigiLocker redirects back to the app with an auth code
/// (exchanged server-side for the offline e-KYC ZIP + share code).
///
/// For now it just simulates that round trip with a consent checkbox
/// and a delay, then hands off to AadhaarVerifyScreen.
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

    // TODO: replace with real DigiLocker OAuth redirect + code exchange.
    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _isRedirecting = false);

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AadhaarVerifyScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verify with DigiLocker')),
      // SingleChildScrollView + no Spacer() below is the fix — a Column
      // with a Spacer requires bounded/infinite vertical space, which
      // conflicts with scrolling and caused the overflow.
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.verified_user_outlined, size: 56, color: Colors.deepPurple),
              const SizedBox(height: 16),
              Text(
                'Confirm your identity',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              const Text(
                'Sakhi verifies solo travelers through DigiLocker so emergency '
                    'contacts, law enforcement, and community members can trust '
                    'who they\'re connecting with. Your Aadhaar number is never '
                    'stored — only your name, gender, and year of birth are used '
                    'to confirm your identity.',
                style: TextStyle(height: 1.4),
              ),
              const SizedBox(height: 24),
              Card(
                color: Colors.deepPurple.withOpacity(0.05),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('What happens next', style: Theme.of(context).textTheme.titleSmall),
                      const SizedBox(height: 8),
                      const _StepLine(number: '1', text: 'Log in to DigiLocker and grant consent'),
                      const _StepLine(number: '2', text: 'DigiLocker gives you a password-protected file and share code'),
                      const _StepLine(number: '3', text: "You'll enter that share code on the next screen"),
                      const _StepLine(number: '4', text: "We verify it against UIDAI's signature — no Aadhaar number stored"),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              CheckboxListTile(
                value: _consentGiven,
                onChanged: (value) => setState(() => _consentGiven = value ?? false),
                controlAffinity: ListTileControlAffinity.leading,
                contentPadding: EdgeInsets.zero,
                title: const Text(
                  'I consent to sharing my DigiLocker-verified Aadhaar demographic details with Sakhi',
                  style: TextStyle(fontSize: 13),
                ),
              ),
              const SizedBox(height: 8),
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
                  label: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(_isRedirecting ? 'Redirecting to DigiLocker…' : 'Continue with DigiLocker'),
                  ),
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
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 10,
            backgroundColor: Colors.deepPurple,
            child: Text(number, style: const TextStyle(fontSize: 11, color: Colors.white)),
          ),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }
}