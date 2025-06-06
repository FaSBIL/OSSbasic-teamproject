import 'package:latlong2/latlong.dart';
import 'package:shelter/models/shelter.dart';

List<Shelter> applyFavoriteFilters({
  required List<Shelter> shelters,
  required String sort,
  required bool filterEarthquake,
  required bool filterTsunami,
  required LatLng? currentPosition,
}) {
  List<Shelter> filtered = [...shelters];

  if (filterEarthquake) {
    filtered = filtered.where((s) => s.earthquakeSafe).toList();
  }
  if (filterTsunami) {
    filtered = filtered.where((s) => s.tsunamiSafe).toList();
  }

  if (sort == '이름순') {
    filtered.sort((a, b) => a.name.compareTo(b.name));
  } else if (sort == '거리순' && currentPosition != null) {
    final distance = const Distance();
    filtered.sort(
      (a, b) => distance(
        currentPosition,
        LatLng(a.latitude, a.longitude),
      ).compareTo(distance(currentPosition, LatLng(b.latitude, b.longitude))),
    );
  }

  return filtered;
}
