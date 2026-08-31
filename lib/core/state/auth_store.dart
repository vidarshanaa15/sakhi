import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../backend/supabase/supabase_client.dart';
import '../../models/aadhaar_verification_result.dart';

/// Holds the user's DigiLocker/Aadhaar verification state app-wide, so
/// any screen (Profile, community trust badges, etc.) can read it
/// without prop-drilling. Same singleton pattern as ItineraryStore /
/// SettingsStore.
class AuthStore extends ChangeNotifier {
  AuthStore._internal();
  static final AuthStore instance = AuthStore._internal();

  bool _isVerified = false;
  AadhaarVerificationResult? _verificationResult;

  bool get isVerified => _isVerified;
  AadhaarVerificationResult? get verificationResult => _verificationResult;

  void markVerified(AadhaarVerificationResult result) {
    if (!result.verified) return;
    _isVerified = true;
    _verificationResult = result;
    notifyListeners();
  }

  /// Call on logout so a fresh login doesn't inherit stale verification.
  void reset() {
    _isVerified = false;
    _verificationResult = null;
    notifyListeners();
  }

  // ---- Supabase login logic ----
SupabaseClient get _client => SupabaseService.client;

Future<AuthResponse> signIn({
  required String email,
  required String password,
}) {
  return _client.auth.signInWithPassword(
    email: email,
    password: password,
  );
}

Future<AuthResponse> signUp({
  required String email,
  required String password,
}) {
  return _client.auth.signUp(
    email: email,
    password: password,
  );
}
}