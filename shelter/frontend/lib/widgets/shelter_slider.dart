import 'package:flutter/material.dart';
import 'shelter_card.dart';

class ShelterSlider extends StatelessWidget {
  final List<Map<String, dynamic>> shelterList;

  // ✅ 선택된 대피소를 부모로 전달하는 콜백
  final void Function(Map<String, dynamic>)? onShelterSelected;

  const ShelterSlider({
    super.key,
    required this.shelterList,
    this.onShelterSelected, // ✅ 생성자에 추가
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.88),
        itemCount: shelterList.length,
        onPageChanged: (index) {
          if (onShelterSelected != null) {
            onShelterSelected!(shelterList[index]); // ✅ 콜백 실행
          }
        },
        itemBuilder: (context, index) {
          final shelter = shelterList[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ShelterCard(
                  name: shelter['name']!,
                  address: shelter['address']!,
                  distance: shelter['distance']!,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
