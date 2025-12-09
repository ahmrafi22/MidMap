class MapEntry {
  final int id;
  final String title;
  final double lat;
  final double lon;
  final String? image;

  MapEntry({
    required this.id,
    required this.title,
    required this.lat,
    required this.lon,
    this.image,
  });

  factory MapEntry.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to int
    int parseInt(dynamic value) {
      if (value == null || value == '') {
        return 0;
      } else if (value is int) {
        return value;
      } else if (value is String) {
        return int.tryParse(value) ?? 0;
      } else if (value is double) {
        return value.toInt();
      }
      return 0;
    }

    // Helper function to safely convert to double
    double parseDouble(dynamic value) {
      if (value == null || value == '') {
        return 0.0;
      } else if (value is int) {
        return value.toDouble();
      } else if (value is double) {
        return value;
      } else if (value is String) {
        return double.tryParse(value) ?? 0.0;
      }
      return 0.0;
    }

    return MapEntry(
      id: parseInt(json['id']),
      title: json['title'] as String? ?? '',
      lat: parseDouble(json['lat']),
      lon: parseDouble(json['lon']),
      image: json['image'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'title': title, 'lat': lat, 'lon': lon, 'image': image};
  }

  // Create MapEntry from database map
  factory MapEntry.fromDatabase(Map<String, dynamic> map) {
    return MapEntry(
      id: map['id'] as int,
      title: map['title'] as String? ?? '',
      lat: map['lat'] as double? ?? 0.0,
      lon: map['lon'] as double? ?? 0.0,
      image: map['image'] as String?,
    );
  }

  // Convert MapEntry to database map
  Map<String, dynamic> toDatabase() {
    return {'id': id, 'title': title, 'lat': lat, 'lon': lon, 'image': image};
  }
}
