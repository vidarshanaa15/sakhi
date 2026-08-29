class SafetyReport {
  final String id;
  final String category; // e.g. 'Harassment', 'Poor lighting', 'Unsafe area'
  final String description;
  final double lat;
  final double lng;
  final DateTime timestamp;

  SafetyReport({
    required this.id,
    required this.category,
    required this.description,
    required this.lat,
    required this.lng,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'category': category,
        'description': description,
        'lat': lat,
        'lng': lng,
        'timestamp': timestamp.toIso8601String(),
      };

  factory SafetyReport.fromJson(Map<String, dynamic> json) => SafetyReport(
        id: json['id'].toString(),
        category: json['category'],
        description: json['description'],
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        timestamp: DateTime.parse(json['timestamp']),
      );
}