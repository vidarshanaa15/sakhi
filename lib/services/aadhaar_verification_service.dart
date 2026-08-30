import '../models/aadhaar_verification_result.dart';

/// Stub for the offline Aadhaar e-KYC verification flow.
///
/// Real flow (to be implemented server-side, NOT on-device):
///   1. User completes DigiLocker consent (see DigiLockerAuthScreen).
///   2. DigiLocker returns a password-protected ZIP containing the
///      offline e-KYC XML, plus a share code (the ZIP's password).
///   3. Backend fetches UIDAI's current public signing certificate
///      from the UIDAI portal.
///   4. Backend unzips the XML using the share code, then verifies the
///      XML's embedded digital signature against UIDAI's certificate
///      (e.g. via xmlsec / a signed-XML verification library).
///   5. On success, backend extracts demographic fields (name, gender,
///      year of birth) — never the Aadhaar number, which offline XML
///      does not include — and returns a verified profile to the app.
///
/// This class fakes steps 3–5 with a delay and mock data so the UI flow
/// can be built and tested before the backend endpoint exists. Swap the
/// body of [verifyOfflineXml] for a real API call (e.g. api_client.dart)
/// once that endpoint is live.
class AadhaarVerificationService {
  Future<AadhaarVerificationResult> verifyOfflineXml({
    required String zipFileName,
    required String shareCode,
  }) async {
    await Future.delayed(const Duration(seconds: 2));

    if (shareCode.trim().length < 4) {
      return AadhaarVerificationResult.failure(
        'Share code looks too short — check the code DigiLocker gave you.',
      );
    }

    // Mocked "verified" response. Replace with real backend call.
    return const AadhaarVerificationResult(
      verified: true,
      name: 'Sandhya G.',
      gender: 'F',
      yearOfBirth: '2003',
      referenceId: 'XXXXXXXX1234',
    );
  }
}