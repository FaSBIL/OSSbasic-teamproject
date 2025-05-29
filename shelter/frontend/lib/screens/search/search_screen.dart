import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelter/component/icon/IconUtils.dart';
import 'package:shelter/component/input/SearchInput.dart';
import 'package:shelter/theme/color.dart';
import 'package:shelter/routes/AppRoutes.dart';
import 'package:shelter/screens/Faivorite/favorite_shelter_screen.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite/sqflite.dart';
import 'package:shelter/services/favorite_service.dart';

class SearchScreen extends StatefulWidget {
  final String? initialKeyword;

  const SearchScreen({super.key, this.initialKeyword});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  int _selectedTab = 0;
  List<String> _recentSearches = [];
  late final TextEditingController _controller;
  int _favoriteCount = 0;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialKeyword ?? '');
    _loadRecentSearches();
    _loadFavoriteCount();
    if (widget.initialKeyword?.isNotEmpty ?? false) {
      _addRecentSearch(widget.initialKeyword!);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _recentSearches = prefs.getStringList('recent_searches') ?? [];
    });
  }

  Future<void> _addRecentSearch(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    final updated = [keyword, ..._recentSearches.where((e) => e != keyword)];
    await prefs.setStringList('recent_searches', updated.take(10).toList());
    _loadRecentSearches();
  }

  Future<void> _deleteRecentSearch(String keyword) async {
    final prefs = await SharedPreferences.getInstance();

    // 현재 목록에서 해당 키워드 제거
    final updated = _recentSearches.where((item) => item != keyword).toList();

    // 업데이트된 리스트 저장
    await prefs.setStringList('recent_searches', updated);

    // 화면 갱신
    setState(() {
      _recentSearches = updated;
    });
  }

  Future<void> _loadFavoriteCount() async {
    final regionTables = [
      'seoul',
      'busan',
      'daegu',
      'incheon',
      'gwangju',
      'daejeon',
      'ulsan',
      'sejong',
      'gyeonggi',
      'gangwon',
      'chungbuk',
      'chungnam',
      'jeonbuk',
      'jeonnam',
      'gyeongbuk',
      'gyeongnam',
      'jeju',
    ];

    int total = 0;
    final db = await FavoriteService().getDatabase();

    for (final table in regionTables) {
      try {
        final count =
            Sqflite.firstIntValue(
              await db.rawQuery(
                'SELECT COUNT(*) FROM $table WHERE isFavorite = 1',
              ),
            ) ??
            0;
        total += count;
      } catch (_) {} // 존재하지 않는 테이블 에러 무시
    }

    setState(() {
      _favoriteCount = total;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 검색창
          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                  child: SearchInput(
                    controller: _controller,
                    onSubmitted: (value) {
                      final keyword = value.trim();
                      if (keyword.isNotEmpty) {
                        _addRecentSearch(keyword);
                        Navigator.pushNamed(
                          context,
                          AppRoutes.searchResult,
                          arguments: keyword,
                        ).then((_) => _loadRecentSearches());
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // 탭 버튼
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                _tabBtn(Icons.star_rounded, '즐겨찾기', '등록 $_favoriteCount개', 0),
                const SizedBox(width: 16),
                _tabBtn(Icons.dns_rounded, '대피소 일람', '지역별 대피소', 1),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),

          // 최근 검색
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
                final keyword = _recentSearches[i];
                return ListTile(
                  leading: Container(
                    width: 30,
                    height: 30,
                    decoration: const BoxDecoration(
                      color: AppColors.lightGray,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.watch_later_outlined,
                      color: AppColors.gray,
                      size: 20,
                    ),
                  ),
                  title: Text(keyword),

                  trailing: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.gray,
                      size: 20,
                    ),
                    onPressed: () {
                      _deleteRecentSearch(keyword); // 삭제 함수 호출
                    },
                  ),

                  onTap: () {
                    _addRecentSearch(keyword); // 순서 갱신
                    Navigator.pushNamed(
                      context,
                      AppRoutes.searchResult,
                      arguments: keyword,
                    ).then((_) => _loadRecentSearches());
                  },
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
          if (idx == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoriteShelterScreen()),
            );
          } else if (idx == 1) {
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
