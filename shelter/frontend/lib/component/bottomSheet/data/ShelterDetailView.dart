import 'package:flutter/material.dart';
import 'package:shelter/component/icon/IconUtils.dart';
import 'package:shelter/theme/color.dart';
import 'package:shelter/theme/typography.dart';
import 'package:flutter/services.dart';
import 'ShelterListItem.dart';
import 'package:shelter/utils/distance_calculator.dart';

class ShelterDetailView extends StatelessWidget {
  final Map<String, dynamic> shelter;
  final void Function(Map<String, dynamic>) onFavoriteToggle;
  final void Function(Map<String, dynamic>) onNavigate;

  const ShelterDetailView({
    super.key,
    required this.shelter,
    required this.onFavoriteToggle,
    required this.onNavigate,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<String>(
          future: DistanceCalculator.calculateDistance(
            shelter['latitude'] ?? 0.0,
            shelter['longitude'] ?? 0.0,
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
              title: shelter['name'] ?? 'no Data',
              address: shelter['address'] ?? 'no Data',
              distance: distanceText,
              isFavorite: (shelter['isFavorite'] ?? 0) == 1,
              isEarthquakeSafe: (shelter['earthquake'] ?? 0) == 1,
              isTsunamiSafe: (shelter['tsunami'] ?? 0) == 1,
              onFavoriteToggle: () => onFavoriteToggle(shelter),
              onNavigatePressed: () => onNavigate(shelter),
              onTap: () {},
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
                  shelter['address'] ?? 'no Data',
                  style: AppTextStyles.bodyGray,
                ),
              ),
              GestureDetector(
                onTap: () {
                  Clipboard.setData(
                    ClipboardData(text: shelter['address'] ?? ''),
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