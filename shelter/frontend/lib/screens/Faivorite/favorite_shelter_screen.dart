import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelter/models/shelter.dart';
import 'package:shelter/screens/search/search_map_screen.dart';
import 'package:shelter/services/favorite_service.dart';
import 'package:shelter/theme/color.dart';
import 'package:shelter/component/icon/favorite_icon_static.dart';
import 'package:shelter/services/user_location.dart';

class FavoriteShelterScreen extends StatefulWidget {
  const FavoriteShelterScreen({super.key});

  @override
  State<FavoriteShelterScreen> createState() => _FavoriteShelterScreenState();
}

class _FavoriteShelterScreenState extends State<FavoriteShelterScreen> {
  List<Shelter> _favoriteShelters = [];
  bool _isLoading = true;
  LatLng? _currentPosition;

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
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _favoriteShelters.isEmpty
              ? const Center(child: Text('즐겨찾기한 대피소가 없습니다.'))
              : ListView.separated(
                itemCount: _favoriteShelters.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final shelter = _favoriteShelters[index];
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
    );
  }
}
