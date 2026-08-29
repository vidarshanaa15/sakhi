import 'package:flutter/foundation.dart';

class SettingsStore extends ChangeNotifier {
  SettingsStore._internal();
  static final SettingsStore instance = SettingsStore._internal();

  bool _locationSharingEnabled = true;
  bool _notificationsEnabled = true;
  bool _offlineAlertsEnabled = true; // LoRa distress relay toggle

  bool get locationSharingEnabled => _locationSharingEnabled;
  bool get notificationsEnabled => _notificationsEnabled;
  bool get offlineAlertsEnabled => _offlineAlertsEnabled;

  void setLocationSharing(bool value) {
    _locationSharingEnabled = value;
    notifyListeners();
  }

  void setNotifications(bool value) {
    _notificationsEnabled = value;
    notifyListeners();
  }

  void setOfflineAlerts(bool value) {
    _offlineAlertsEnabled = value;
    notifyListeners();
  }
}