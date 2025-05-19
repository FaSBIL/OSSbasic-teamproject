import 'package:flutter/material.dart';
import 'package:shelter/component/icon/IconUtils.dart';
import 'package:shelter/component/input/SearchInput.dart';
import 'package:shelter/theme/color.dart';
import 'package:shelter/routes/AppRoutes.dart';
import 'package:shelter/screens/search/shelter_map_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});
  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedTab = 0;
  final List<Map<String, dynamic>> _recentSearches = [
    {'type': 'star', 'text': '대피소 이름23'},
    {'type': 'history', 'text': '청주시'},
    {'type': 'history', 'text': '주소00000000000000000000'},
    {'type': 'history', 'text': '서울'},
    {'type': 'history', 'text': '인천'},
    {'type': 'star', 'text': '대피소 이름50'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단: 뒤로가기 + 검색창
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: SearchInput(
                    onSubmitted: (value) {
                      if (value.trim().isNotEmpty) {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.searchResult,
                          arguments: value.trim(),
                        );
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _tabBtn(Icons.star_rounded, '즐겨찾기', '등록 10개', 0),
                const SizedBox(width: 16),
                _tabBtn(Icons.dns_rounded, '대피소 일람', '지역별 대피소', 1),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Text(
              '최근검색',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
          ),
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.only(left: 8, right: 8, bottom: 32),
              itemCount: _recentSearches.length,
              separatorBuilder: (c, i) => const Divider(height: 1),
              itemBuilder: (c, i) {
                final item = _recentSearches[i];
                return ListTile(
                  leading: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color:
                          item['type'] == 'star'
                              ? AppColors.paleBlue
                              : AppColors.lightGray,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item['type'] == 'star'
                          ? Icons.star_rounded
                          : Icons.watch_later_outlined,
                      color:
                          item['type'] == 'star'
                              ? AppColors.blue
                              : AppColors.gray,
                      size: 20,
                    ),
                  ),

                  title: Text(item['text']),
                  onTap: () {},
                  dense: true,
                  contentPadding: const EdgeInsets.only(left: 8, right: 16),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tabBtn(IconData icon, String title, String subtitle, int idx) {
    final selected = _selectedTab == idx;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() => _selectedTab = idx);
          if (idx == 1) {
            Navigator.pushNamed(context, AppRoutes.shelterRegion);
          }
        },
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: AppColors.paleBlue,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: AppColors.blue, size: 20),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(color: AppColors.gray, fontSize: 11),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
