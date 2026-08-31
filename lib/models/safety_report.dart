class SafetyReport {
  final String id;
  final String category;
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
        'reported_at': timestamp.toIso8601String(), // match DB column name
      };

  factory SafetyReport.fromJson(Map<String, dynamic> json) => SafetyReport(
        id: json['id'].toString(),
        category: json['category'] as String? ?? '',
        description: json['description'] as String? ?? '',
        lat: (json['lat'] as num).toDouble(),
        lng: (json['lng'] as num).toDouble(),
        timestamp: json['reported_at'] != null
            ? DateTime.parse(json['reported_at'] as String)
            : DateTime.now(),
      );
}