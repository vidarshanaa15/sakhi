import 'package:another_telephony/telephony.dart';
import '../core/network/api_client.dart';
import '../core/state/sos_store.dart';
import 'location_service.dart';

class SosService {
  final LocationService _locationService = LocationService();
  final Telephony _telephony = Telephony.instance;

  Future<void> trigger() async {
    final position = await _locationService.getCurrentLocation();
    if (position == null) {
      throw Exception('Could not get current location for SOS');
    }

    final granted = await _telephony.requestPhoneAndSmsPermissions ?? false;
    if (!granted) {
      throw Exception('SMS permission not granted');
    }

    SosStore.instance.startSos();

    final mapsLink =
        'https://maps.google.com/?q=${position.latitude},${position.longitude}';
    final message = "I need help. My current location: $mapsLink";

    for (final contact in SosStore.instance.contacts) {
      final cleanPhone = contact.phone.replaceAll(' ', '');
      await _telephony.sendSms(to: cleanPhone, message: message);
    }

    try {
      await ApiClient.instance.post('/sos/trigger', body: {
        'lat': position.latitude,
        'lng': position.longitude,
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }

  Future<void> resolve() async {
    SosStore.instance.stopSos();
    try {
      await ApiClient.instance.post('/sos/resolve', body: {
        'timestamp': DateTime.now().toIso8601String(),
      });
    } catch (_) {}
  }
}