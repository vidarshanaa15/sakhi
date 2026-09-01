import 'package:flutter/material.dart';
import '../../widgets/app_shell.dart';
import '../auth/digilocker_auth_screen.dart';
import '../../core/state/auth_store.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/app_spacing.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'signup_screen.dart';
import 'profile_setup_screen.dart';

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

  static final RegExp _emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return 'Enter your email';
    if (!_emailRegex.hasMatch(v)) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return 'Enter your password';
    if (v.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<bool> _hasCompletedProfile(String userId) async {
  final data = await Supabase.instance.client
      .from('profiles')
      .select('profile_complete')
      .eq('userid', userId)
      .maybeSingle();
  return data?['profile_complete'] == true;
}
  Future<void> _handleLogin() async {
    setState(() => _authError = null);
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    setState(() => _isSubmitting = true);
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      final response = await AuthStore.instance.signIn(email: email, password: password);
      if (!mounted) return;

      if (response.session != null) {
        final completed = await _hasCompletedProfile(response.session!.user.id);
        if (!mounted) return;
        setState(() => _isSubmitting = false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => completed ? const AppShell() : const ProfileSetupScreen(),
          ),
        );
      } else {
        setState(() {
          _isSubmitting = false;
          _authError = 'Login failed. Please try again.';
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
      backgroundColor: AppTheme.background,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
                  ),
                  child: const Icon(Icons.shield, size: 36, color: Colors.white),
                ),
                const SizedBox(height: AppSpacing.md),
                Text('Sakhi', style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 4),
                Text(
                  'Welcome back',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: AppSpacing.xl),

                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: _validateEmail,
                ),
                const SizedBox(height: AppSpacing.sm + 4),

                TextFormField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.done,
                  onFieldSubmitted: (_) => _handleLogin(),
                  decoration: InputDecoration(
                    labelText: 'Password',
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        color: AppTheme.textSecondary,
                      ),
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                    ),
                  ),
                  validator: _validatePassword,
                ),

                if (_authError != null) ...[
                  const SizedBox(height: AppSpacing.sm + 4),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppTheme.safetyRed.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                    ),
                    child: Text(
                      _authError!,
                      style: const TextStyle(color: AppTheme.safetyRed, fontSize: 13),
                    ),
                  ),
                ],

                const SizedBox(height: AppSpacing.lg),

                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isSubmitting ? null : _handleLogin,
                    child: _isSubmitting
                        ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                        : const Text('Log in'),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm + 4),

                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.black.withOpacity(0.08))),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
                      child: Text('or', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                    ),
                    Expanded(child: Divider(color: Colors.black.withOpacity(0.08))),
                  ],
                ),

                const SizedBox(height: AppSpacing.sm + 4),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      foregroundColor: AppTheme.primary,
                      side: BorderSide(color: AppTheme.primary.withOpacity(0.4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusSm)),
                    ),
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const DigiLockerAuthScreen()),
                    ),
                    icon: const Icon(Icons.verified_user_outlined),
                    label: const Text('Verify with DigiLocker'),
                  ),
                ),

                const SizedBox(height: AppSpacing.sm),

                TextButton(
                  onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SignupScreen())),
                  style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
                  child: const Text("Don't have an account? Sign up"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}