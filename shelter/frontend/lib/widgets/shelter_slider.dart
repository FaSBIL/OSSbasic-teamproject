import 'package:flutter/material.dart';
import 'shelter_card.dart';
import 'package:shelter/widgets/guide_start_button.dart';

class ShelterSlider extends StatelessWidget {
  final List<Map<String, dynamic>> shelterList;

  // 선택된 대피소를 부모로 전달하는 콜백
  final void Function(Map<String, dynamic>)? onShelterSelected;

  const ShelterSlider({
    super.key,
    required this.shelterList,
    this.onShelterSelected, // 생성자에 추가
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200, // 카드 + 버튼 포함 높이
      child: PageView.builder(
        controller: PageController(viewportFraction: 0.88),
        itemCount: shelterList.length,
        itemBuilder: (context, index) {
          final shelter = shelterList[index];

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 카드
                ShelterCard(
                  name: shelter['name'],
                  address: shelter['address'],
                  distance: shelter['distance'],
                ),
                const SizedBox(height: 8),

                // 안내 버튼 → 여기 포함!
                SizedBox(
                  width: double.infinity,
                  child: GuideStartButton(
                    onPressed: () {
                      print('안내 시작: ${shelter['name']}');
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
