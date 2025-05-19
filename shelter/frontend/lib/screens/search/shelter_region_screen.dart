import 'package:flutter/material.dart';
import 'package:shelter/component/input/SearchInput.dart';
import 'package:shelter/screens/search/shelter_list_screen.dart';
import 'package:shelter/theme/color.dart';

class ShelterRegionScreen extends StatelessWidget {
  final List<String> regions = [
    '서울특별시',
    '부산광역시',
    '대구광역시',
    '인천광역시',
    '광주광역시',
    '대전광역시',
    '울산광역시',
    '세종특별자치시',
    '경기도',
    '강원특별자치도',
    '충청북도',
    '충청남도',
    '전북특별자치도',
    '전라남도',
    '경상북도',
    '경상남도',
    '제주특별자치도',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white, // 배경 흰색으로 통일
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: SearchInput(
                    hintText: '대피소 검색',
                    onSubmitted: (keyword) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ShelterListScreen(region: keyword),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 1),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text('지역별 대피소', style: TextStyle(fontSize: 12)),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 32),
              itemCount: regions.length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final region = regions[index];
                return ListTile(
                  title: Text(region),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ShelterListScreen(region: region),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
