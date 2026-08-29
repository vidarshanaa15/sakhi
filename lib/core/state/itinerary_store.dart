import 'package:flutter/foundation.dart';
import '../../models/destination.dart';

/// Simple app-wide store for the user's itinerary.
/// Singleton so any screen can read/update it without prop-drilling.
class ItineraryStore extends ChangeNotifier {
  ItineraryStore._internal();
  static final ItineraryStore instance = ItineraryStore._internal();

  final List<Destination> _items = [];
  List<Destination> get items => List.unmodifiable(_items);

  bool isAdded(String destinationId) =>
      _items.any((d) => d.id == destinationId);

  void add(Destination destination) {
    if (!isAdded(destination.id)) {
      _items.add(destination);
      notifyListeners();
    }
  }

  void remove(String destinationId) {
    _items.removeWhere((d) => d.id == destinationId);
    notifyListeners();
  }

  void toggle(Destination destination) {
    isAdded(destination.id) ? remove(destination.id) : add(destination);
  }
}