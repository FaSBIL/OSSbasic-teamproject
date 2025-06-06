import 'package:flutter/material.dart';
import 'package:shelter/theme/color.dart'; // AppColors 사용 시

class FavoriteFilterBar extends StatelessWidget {
  final String selectedSort;
  final void Function(String?) onSortChanged;
  final bool filterEarthquake;
  final bool filterTsunami;
  final void Function(bool?) onEarthquakeChanged;
  final void Function(bool?) onTsunamiChanged;

  const FavoriteFilterBar({
    super.key,
    required this.selectedSort,
    required this.onSortChanged,
    required this.filterEarthquake,
    required this.filterTsunami,
    required this.onEarthquakeChanged,
    required this.onTsunamiChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            // 드롭다운: 하얀 배경
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(color: AppColors.white),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: selectedSort,
                  dropdownColor: AppColors.white,
                  items:
                      ['이름순', '거리순'].map((sort) {
                        return DropdownMenuItem<String>(
                          value: sort,
                          child: Text(sort),
                        );
                      }).toList(),
                  onChanged: onSortChanged,
                ),
              ),
            ),

            const SizedBox(width: 16),

            // 지진 대피소 필터
            Row(
              children: [
                Checkbox(
                  value: filterEarthquake,
                  onChanged: onEarthquakeChanged,
                  activeColor: AppColors.blue, // 체크 색상
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Text('지진 대피소'),
              ],
            ),

            const SizedBox(width: 8),

            // 해일 대피소 필터
            Row(
              children: [
                Checkbox(
                  value: filterTsunami,
                  onChanged: onTsunamiChanged,
                  activeColor: AppColors.blue,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                const Text('해일 대피소'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
