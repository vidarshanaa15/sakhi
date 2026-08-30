import 'package:flutter/material.dart';
import '../../widgets/app_shell.dart';
import '../auth/digilocker_auth_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isSubmitting = false;
  String? _authError;

  static final RegExp _emailRegex =
  RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';

    if (v.isEmpty) {
      return 'Enter your email';
    }

    if (!_emailRegex.hasMatch(v)) {
      return 'Enter a valid email address';
    }

    return null;
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';

    if (v.isEmpty) {
      return 'Enter your password';
    }

    if (v.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  Future<void> _handleLogin() async {
    setState(() => _authError = null);

    // Validate the form first.
    final isValid = _formKey.currentState?.validate() ?? false;

    if (!isValid) return;

    setState(() => _isSubmitting = true);

    // TODO: Replace with real authentication call.
    // DigiLocker/Aadhaar authentication flow comes separately.
    await Future.delayed(const Duration(milliseconds: 400));

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    // Additional safety check.
    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _isSubmitting = false;
        _authError = 'Email and password are required.';
      });
      return;
    }

    if (!mounted) return;

    setState(() => _isSubmitting = false);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (_) => const AppShell(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.shield,
                  size: 64,
                ),

                const SizedBox(height: 12),

                const Text(
                  'Sakhi',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 24),

                // Email
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  validator: _validateEmail,
                ),

                const SizedBox(height: 12),

                // Password
                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                  ),
                  validator: _validatePassword,
                ),

                // Authentication error
                if (_authError != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _authError!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 13,
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Normal Login Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed:
                    _isSubmitting ? null : _handleLogin,
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: _isSubmitting
                          ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                          : const Text('Log in'),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // OR divider
                const Row(
                  children: [
                    Expanded(
                      child: Divider(),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8),
                      child: Text('or'),
                    ),
                    Expanded(
                      child: Divider(),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // DigiLocker Button
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                          const DigiLockerAuthScreen(),
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons.verified_user_outlined,
                    ),
                    label: const Text(
                      'Verify with DigiLocker',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Real authentication — DigiLocker/Aadhaar offline XML
// verification — comes next.
//
// For now, this screen validates the email and password
// before allowing the user to proceed.