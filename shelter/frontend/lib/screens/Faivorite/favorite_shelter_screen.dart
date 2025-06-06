import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelter/models/shelter.dart';
import 'package:shelter/screens/search/search_map_screen.dart';
import 'package:shelter/services/favorite_service.dart';
import 'package:shelter/theme/color.dart';
import 'package:shelter/component/icon/favorite_icon_static.dart';
import 'package:shelter/services/user_location.dart';
import 'package:shelter/component/favorite/favorite_filter_bar.dart';
import 'package:shelter/utils/favorite_filter_utils.dart';

class FavoriteShelterScreen extends StatefulWidget {
  const FavoriteShelterScreen({super.key});

  @override
  State<FavoriteShelterScreen> createState() => _FavoriteShelterScreenState();
}

class _FavoriteShelterScreenState extends State<FavoriteShelterScreen> {
  List<Shelter> _favoriteShelters = [];
  bool _isLoading = true;
  LatLng? _currentPosition;
  List<Shelter> _filteredShelters = [];
  String _selectedSort = '이름순';
  bool _filterEarthquake = false;
  bool _filterTsunami = false;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
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

    final favoriteList = <Shelter>[];
    final position = await UserLocationService().getCurrentLocation();
    _currentPosition = LatLng(position.latitude, position.longitude);

    for (final table in regionTables) {
      final shelters = await FavoriteService().getFavoriteShelterObjects(table);
      favoriteList.addAll(shelters);
      _currentPosition = LatLng(position.latitude, position.longitude);
    }

    setState(() {
      _favoriteShelters = favoriteList;
      _isLoading = false;
      _applyFilters();
    });
  }

  void _applyFilters() {
    final filtered = applyFavoriteFilters(
      shelters: _favoriteShelters,
      sort: _selectedSort,
      filterEarthquake: _filterEarthquake,
      filterTsunami: _filterTsunami,
      currentPosition: _currentPosition,
    );

    setState(() {
      _filteredShelters = filtered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: const Text('즐겨찾기한 대피소'),
      ),
      body: Column(
        children: [
          FavoriteFilterBar(
            selectedSort: _selectedSort,
            onSortChanged: (value) {
              setState(() {
                _selectedSort = value!;
              });
              _applyFilters();
            },
            filterEarthquake: _filterEarthquake,
            filterTsunami: _filterTsunami,
            onEarthquakeChanged: (value) {
              setState(() {
                _filterEarthquake = value ?? false;
              });
              _applyFilters();
            },
            onTsunamiChanged: (value) {
              setState(() {
                _filterTsunami = value ?? false;
              });
              _applyFilters();
            },
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.separated(
              itemCount: _filteredShelters.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final shelter = _filteredShelters[index];
                return ListTile(
                  title: Text(shelter.name),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(shelter.address),
                      Text(
                        shelter.type ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  leading: const FavoriteIconStatic(),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder:
                            (_) => SearchMapScreen(
                              region: '즐겨찾기',
                              shelters: [shelter],
                              selectedShelter: shelter,
                              currentPosition: _currentPosition,
                            ),
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
