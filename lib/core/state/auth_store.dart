import 'package:flutter/foundation.dart';
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
}