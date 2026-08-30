/// Result of verifying a DigiLocker offline e-KYC XML (inside the
/// password-protected ZIP) against UIDAI's public signing certificate.
///
/// NOTE: offline XML never exposes the Aadhaar number itself — only
/// demographic fields (name, gender, year/date of birth, address) plus
/// a "referenceId" the last digits of which are the requester code.
/// Do not add an `aadhaarNumber` field here; it isn't in the data.
class AadhaarVerificationResult {
  final bool verified;
  final String? name;
  final String? gender;
  final String? yearOfBirth;
  final String? referenceId;
  final String? errorMessage;

  const AadhaarVerificationResult({
    required this.verified,
    this.name,
    this.gender,
    this.yearOfBirth,
    this.referenceId,
    this.errorMessage,
  });

  factory AadhaarVerificationResult.failure(String message) =>
      AadhaarVerificationResult(verified: false, errorMessage: message);
}