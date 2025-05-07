import 'package:flutter/material.dart';
import 'package:shelter/component/icon/IconUtils.dart';
import 'package:shelter/theme/color.dart';
import 'package:shelter/theme/typography.dart';
import 'package:flutter/services.dart';
import 'ShelterListItem.dart';

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
          ShelterListItem(
            title: shelter['name'] ?? 'nonData',
            address: shelter['address'] ?? 'nonData',
            distance: shelter['distance'] ?? 0.0,
            isFavorite: shelter['isFavorite'] ?? false,
            isEarthquakeSafe: shelter['earthquake'] ?? false,
            isTsunamiSafe: shelter['tsunami'] ?? false,
            onFavoriteToggle: () => onFavoriteToggle(shelter),
            onNavigatePressed: () => onNavigate(shelter),
            onTap: () {},
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
                    shelter['address'] ?? 'nonData',
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