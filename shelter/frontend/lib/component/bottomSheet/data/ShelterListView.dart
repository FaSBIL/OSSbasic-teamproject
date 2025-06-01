import 'package:flutter/material.dart';
import 'ShelterListItem.dart';
import 'package:shelter/utils/distance_calculator.dart';
import 'package:geolocator/geolocator.dart';

class ShelterListView extends StatelessWidget {
  final ScrollController scrollController;
  final List<Map<String, dynamic>> shelters;
  final Position? currentPosition;
  final void Function(Map<String, dynamic>) onTapItem;
  final void Function(Map<String, dynamic>) onFavoriteToggle;
  final void Function(Map<String, dynamic>) onNavigate;
  final String navButtonText;

  const ShelterListView({
    super.key,
    required this.scrollController,
    required this.shelters,
    required this.currentPosition,
    required this.onTapItem,
    required this.onFavoriteToggle,
    required this.onNavigate,
    required this.navButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(
        shelters.length,
        (index) {
          final shelter = shelters[index];

          return FutureBuilder<String>(
            future: DistanceCalculator.calculateDistance(
              currentPosition!.latitude,
              currentPosition!.longitude,
              (shelter['latitude'] as num?)?.toDouble() ?? 0.0,
              (shelter['longitude'] as num?)?.toDouble() ?? 0.0,
            ),
            builder: (context, snapshot) {
              String distanceText;
              if (snapshot.connectionState == ConnectionState.waiting) {
                distanceText = 'Calculating';
              } else if (snapshot.hasError) {
                distanceText = 'Error: ${snapshot.error}';
              } else {
                distanceText = snapshot.data ?? '거리 취득 장애';
              }

              return GestureDetector(
                onTap: () => onTapItem(shelter),
                child: ShelterListItem(
                  title: shelter['name'] ?? 'no Data',
                  address: shelter['address'] ?? 'no Data',
                  distance: distanceText,
                  isFavorite: (shelter['isFavorite'] ?? 0) == 1,
                  isEarthquakeSafe: (shelter['earthquake'] ?? 0) == 1,
                  isTsunamiSafe: (shelter['tsunami'] ?? 0) == 1,
                  onTap: () => onTapItem(shelter),
                  onFavoriteToggle: () => onFavoriteToggle(shelter),
                  onNavigatePressed: () => onNavigate(shelter),
                  navButtonText: navButtonText,
                ),
              );
            },
          );
        },
      ),
    );
  }
}