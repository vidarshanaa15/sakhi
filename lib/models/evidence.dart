class Evidence {
  final String id;
  final String filePath;
  final String type; // 'photo' or 'video'
  final double lat;
  final double lng;
  final DateTime timestamp;
  bool uploaded;

  Evidence({
    required this.id,
    required this.filePath,
    required this.type,
    required this.lat,
    required this.lng,
    required this.timestamp,
    this.uploaded = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'filePath': filePath,
        'type': type,
        'lat': lat,
        'lng': lng,
        'timestamp': timestamp.toIso8601String(),
        'uploaded': uploaded,
      };

  factory Evidence.fromJson(Map<String, dynamic> json) => Evidence(
        id: json['id'],
        filePath: json['filePath'],
        type: json['type'],
        lat: json['lat'],
        lng: json['lng'],
        timestamp: DateTime.parse(json['timestamp']),
        uploaded: json['uploaded'] ?? false,
      );
}