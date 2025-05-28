class Shelter {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  final bool earthquakeSafe;
  final bool tsunamiSafe;
  final bool isFavorite;

  final String? type;

  Shelter({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.earthquakeSafe = false,
    this.tsunamiSafe = false,
    this.isFavorite = false,
    this.type,
  });

  factory Shelter.fromMap(Map<String, dynamic> map) {
    String? type;
    if (map['civil'] == 1) {
      type = 'civil';
    } else if (map['earthquake'] == 1) {
      type = 'earthquake';
    } else if (map['tsunami'] == 1) {
      type = 'tsunami';
    }

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
      earthquakeSafe: map['earthquake'] == 1,
      tsunamiSafe: map['tsunami'] == 1,
      isFavorite: map['isFavorite'] == 1,
      type: type,
    );
  }

  Shelter copyWith({
    String? name,
    String? address,
    double? latitude,
    double? longitude,
    bool? earthquakeSafe,
    bool? tsunamiSafe,
    bool? isFavorite,
    String? type,
  }) {
    return Shelter(
      name: name ?? this.name,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      earthquakeSafe: earthquakeSafe ?? this.earthquakeSafe,
      tsunamiSafe: tsunamiSafe ?? this.tsunamiSafe,
      isFavorite: isFavorite ?? this.isFavorite,
      type: type ?? this.type,
    );
  }
}
