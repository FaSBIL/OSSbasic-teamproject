import 'package:flutter/material.dart';
import 'package:shelter/component/icon/IconUtils.dart';
import 'package:shelter/theme/color.dart';
import 'package:shelter/theme/typography.dart';
import 'package:flutter/services.dart';
import 'ShelterListItem.dart';
import 'package:shelter/utils/distance_calculator.dart';
import 'package:geolocator/geolocator.dart';

class ShelterDetailView extends StatelessWidget {
  final Map<String, dynamic> shelters;
  final Position? currentPosition;
  final void Function(Map<String, dynamic>) onFavoriteToggle;
  final void Function(Map<String, dynamic>) onNavigate;
  final String navButtonText;

  const ShelterDetailView({
    super.key,
    required this.shelters,
    required this.currentPosition,
    required this.onFavoriteToggle,
    required this.onNavigate,
    required this.navButtonText,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<String>(
          future: DistanceCalculator.calculateDistance(
            currentPosition!.latitude,
            currentPosition!.longitude,
            (shelters['latitude'] as num?)?.toDouble() ?? 0.0,
            (shelters['longitude'] as num?)?.toDouble() ?? 0.0,
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

            return ShelterListItem(
              title: shelters['name'] ?? 'no Data',
              address: shelters['address'] ?? 'no Data',
              distance: distanceText,
              isFavorite: (shelters['isFavorite'] ?? 0) == 1,
              isEarthquakeSafe: (shelters['earthquake'] ?? 0) == 1,
              isTsunamiSafe: (shelters['tsunami'] ?? 0) == 1,
              onFavoriteToggle: () => onFavoriteToggle(shelters),
              onNavigatePressed: () => onNavigate(shelters),
              onTap: () {},
              navButtonText: navButtonText,
            );
          },
        ),
        const SizedBox(height: 24),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(AppIcons.destination, color: AppColors.darkGray),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  shelters['address'] ?? 'no Data',
                  style: AppTextStyles.bodyGray,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: shelters['address'] ?? ''),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('주소가 복사되었습니다.')),
                  );
                },
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    '복사',
                    style: TextStyle(
                      color: AppColors.blue,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}