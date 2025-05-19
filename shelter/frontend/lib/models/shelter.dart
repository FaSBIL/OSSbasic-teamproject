class Shelter {
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final String? type;

  Shelter({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.type,
  });

  factory Shelter.fromMap(Map<String, dynamic> map) {
    return Shelter(
      name: map['name'],
      address: map['address'],
      latitude:
          map['latitude'] is double
              ? map['latitude']
              : double.parse(map['latitude'].toString()),
      longitude:
          map['longitude'] is double
              ? map['longitude']
              : double.parse(map['longitude'].toString()),
      type: map['type'],
    );
  }

  Shelter copyWith({
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    String? type,
  }) {
    return Shelter(
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      type: type ?? this.type,
    );
  }
}
