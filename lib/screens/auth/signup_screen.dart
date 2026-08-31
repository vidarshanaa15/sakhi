import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../widgets/app_shell.dart';
import '../../core/state/auth_store.dart';
import 'profile_setup_screen.dart'; // add this import, remove app_shell.dart import if unused elsewhere

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isSubmitting = false;
  String? _authError;
  String? _infoMessage;

  static final RegExp _emailRegex =
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
      return 'Enter a password';
    }

    if (v.length < 6) {
      return 'Password must be at least 6 characters';
    }

    return null;
  }

  String? _validateConfirmPassword(String? value) {
    final v = value ?? '';

    if (v.isEmpty) {
      return 'Confirm your password';
    }

    if (v != _passwordController.text) {
      return 'Passwords do not match';
    }

    return null;
  }

  /// Creates the corresponding row in `profiles` for a newly signed-up user.
  /// Only `userid` and `email` are populated here — name, phone_number,
  /// emergency_contacts, home_location, gender, age, and interests are
  /// left null/default since this form doesn't collect them yet.
  Future<void> _createProfile(User user) async {
    try {
      await Supabase.instance.client.from('profiles').upsert({
        'userid': user.id,
        'email': user.email,
      });
    } on PostgrestException catch (e) {
      debugPrint('Failed to create profile: ${e.message}');
    } catch (e) {
      debugPrint('Failed to create profile: $e');
    }
  }

  Future<void> _handleSignup() async {
    setState(() {
      _authError = null;
      _infoMessage = null;
    });

    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isSubmitting = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final response = await AuthStore.instance.signUp(
        email: email,
        password: password,
      );

      if (!mounted) return;

      if (response.session != null && response.user != null) {
        await _createProfile(response.user!);
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const ProfileSetupScreen()), // was AppShell
        );
      } else if (response.user != null) {
        // Email confirmation required — no session yet, so we can't
        // safely insert into `profiles` here (RLS will reject it).
        // The profile row should be created once the user confirms
        // their email and logs in — e.g. in LoginScreen after a
        // successful sign-in — or via a DB trigger on auth.users.
        setState(() {
          _isSubmitting = false;
          _infoMessage =
              'Account created. Check your email to confirm before logging in.';
        });
      } else {
        setState(() {
          _isSubmitting = false;
          _authError = 'Signup failed. Please try again.';
        });
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _authError = e.message;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _authError = 'Something went wrong. Please check your connection.';
      });
    }
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
                  'Create your Sakhi account',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
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
                  textInputAction: TextInputAction.next,
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

                const SizedBox(height: 12),

                // Confirm Password
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: _obscureConfirmPassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleSignup(),
                  decoration: InputDecoration(
                    labelText: 'Confirm password',
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                    ),
                  ),
                  validator: _validateConfirmPassword,
                ),

                // Error message
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

                // Info message (e.g. confirm-your-email notice)
                if (_infoMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    _infoMessage!,
                    style: const TextStyle(
                      color: Colors.green,
                      fontSize: 13,
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Sign Up Button
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _handleSignup,
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
                          : const Text('Sign up'),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                // Back to login
                TextButton(
                  onPressed: _isSubmitting
                      ? null
                      : () => Navigator.pop(context),
                  child: const Text('Already have an account? Log in'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}