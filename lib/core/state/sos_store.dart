import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/user_profile.dart';

class SosStore extends ChangeNotifier {
  SosStore._internal();
  static final SosStore instance = SosStore._internal();

  final List<EmergencyContact> _contacts = [];
  bool _sosActive = false;
  DateTime? _sosStartedAt;

  List<EmergencyContact> get contacts => List.unmodifiable(_contacts);
  bool get sosActive => _sosActive;
  DateTime? get sosStartedAt => _sosStartedAt;

  static const _prefsKey = 'sos_contacts';

  /// Loads saved contacts, falling back to the mock profile's contacts
  /// the first time (until real auth/backend is wired up).
  Future<void> loadContacts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey);

    _contacts.clear();
    if (raw == null || raw.isEmpty) {
      _contacts.addAll(mockUserProfile.emergencyContacts);
    } else {
      _contacts.addAll(raw.map((s) {
        final m = jsonDecode(s);
        return EmergencyContact(name: m['name'], phone: m['phone']);
      }));
    }
    notifyListeners();
  }

  Future<void> _persistContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      _contacts
          .map((c) => jsonEncode({'name': c.name, 'phone': c.phone}))
          .toList(),
    );
  }

  Future<void> addContact(EmergencyContact contact) async {
    if (_contacts.any((c) => c.phone == contact.phone)) return;
    _contacts.add(contact);
    notifyListeners();
    await _persistContacts();
  }

  /// phone is used as the unique key since EmergencyContact has no id.
  Future<void> removeContact(String phone) async {
    _contacts.removeWhere((c) => c.phone == phone);
    notifyListeners();
    await _persistContacts();
  }

  void startSos() {
    _sosActive = true;
    _sosStartedAt = DateTime.now();
    notifyListeners();
  }

  void stopSos() {
    _sosActive = false;
    _sosStartedAt = null;
    notifyListeners();
  }
}