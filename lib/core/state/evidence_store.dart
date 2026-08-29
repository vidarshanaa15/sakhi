import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/evidence.dart';

class EvidenceStore extends ChangeNotifier {
  EvidenceStore._internal();
  static final EvidenceStore instance = EvidenceStore._internal();

  final List<Evidence> _items = [];
  static const _prefsKey = 'evidence_items';

  List<Evidence> get items => List.unmodifiable(_items);

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? [];
    _items
      ..clear()
      ..addAll(raw.map((s) => Evidence.fromJson(jsonDecode(s))));
    notifyListeners();
  }

  Future<void> _persist() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      _prefsKey,
      _items.map((e) => jsonEncode(e.toJson())).toList(),
    );
  }

  Future<void> add(Evidence evidence) async {
    _items.add(evidence);
    notifyListeners();
    await _persist();
  }

  Future<void> markUploaded(String id) async {
    final e = _items.firstWhere((e) => e.id == id);
    e.uploaded = true;
    notifyListeners();
    await _persist();
  }

  Future<void> remove(String id) async {
    _items.removeWhere((e) => e.id == id);
    notifyListeners();
    await _persist();
  }
}