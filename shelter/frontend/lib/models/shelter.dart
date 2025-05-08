class Shelter {
  final String name;
  final String address;
  final double latitude;
  final double longitude;

  Shelter({
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
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
    );
  }
}
