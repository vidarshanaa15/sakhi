import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../core/network/api_client.dart';
import '../core/state/evidence_store.dart';
import '../models/evidence.dart';
import 'location_service.dart';

class EvidenceService {
  final ImagePicker _picker = ImagePicker();
  final LocationService _locationService = LocationService();

  /// Opens the camera, saves a local copy, and records it in EvidenceStore.
  /// Returns the Evidence, or null if the user cancelled.
  Future<Evidence?> capturePhoto() async {
    final picked = await _picker.pickImage(source: ImageSource.camera);
    if (picked == null) return null;

    final position = await _locationService.getCurrentLocation();
    final dir = await getApplicationDocumentsDirectory();
    final id = DateTime.now().millisecondsSinceEpoch.toString();
    final savedPath = '${dir.path}/evidence_$id.jpg';
    await File(picked.path).copy(savedPath);

    final evidence = Evidence(
      id: id,
      filePath: savedPath,
      type: 'photo',
      lat: position?.latitude ?? 0,
      lng: position?.longitude ?? 0,
      timestamp: DateTime.now(),
    );

    await EvidenceStore.instance.add(evidence);
    return evidence;
  }

  // /// Uploads a single evidence item to FastAPI. Throws on failure.
  // Future<void> upload(Evidence evidence) async {
  //   await ApiClient.instance.uploadFile(
  //     '/evidence/upload',
  //     fieldName: 'file',
  //     filePath: evidence.filePath,
  //     fields: {
  //       'lat': evidence.lat.toString(),
  //       'lng': evidence.lng.toString(),
  //       'timestamp': evidence.timestamp.toIso8601String(),
  //       'type': evidence.type,
  //     },
  //   );
  //   await EvidenceStore.instance.markUploaded(evidence.id);
  // }
  static const bool useMockData = true;

  Future<void> upload(Evidence evidence) async {
    if (useMockData) {
      await Future.delayed(const Duration(milliseconds: 600)); // simulate upload
      await EvidenceStore.instance.markUploaded(evidence.id);
      return;
    }

    await ApiClient.instance.uploadFile(
      '/evidence/upload',
      fieldName: 'file',
      filePath: evidence.filePath,
      fields: {
        'lat': evidence.lat.toString(),
        'lng': evidence.lng.toString(),
        'timestamp': evidence.timestamp.toIso8601String(),
        'type': evidence.type,
      },
    );
    await EvidenceStore.instance.markUploaded(evidence.id);
  }
  /// Retries every not-yet-uploaded item. Best-effort — failures are silent
  /// per item so one bad upload doesn't block the rest.
  Future<void> uploadPending() async {
    for (final e in EvidenceStore.instance.items.where((e) => !e.uploaded)) {
      try {
        await upload(e);
      } catch (_) {}
    }
  }
}