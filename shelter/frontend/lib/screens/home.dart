import 'package:flutter/material.dart';
import 'package:shelter/map/shelter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:latlong2/latlong.dart' as latlng;
import 'package:shelter/component/input/MainInput.dart';
import 'package:shelter/component/buttons/GpsButton.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:shelter/map/user_marker.dart';
import 'package:shelter/services/user_location.dart';
import 'package:shelter/services/filter_shelters.dart';
import 'package:shelter/models/shelter.dart';
import 'package:shelter/screens/search/search_screen.dart';
import 'package:shelter/component/bottomSheet/ShelterBottomSheet.dart';
import 'package:shelter/component/bottomSheet/data/ShelterDetailView.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shelter/screens/navigation/navigation_preview_screen.dart';
import 'package:shelter/screens/settings/SettingsMainScreens.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng? _currentPosition;
  List<Marker> _shelterMarkers = [];
  final MapController _mapController = MapController();

  final ShelterService _shelterService = ShelterService(); // 대피소 서비스
  Shelter? _selectedShelter; // 선택된 대피소 정보를 담는 변수

  List<String> _recentSearches = [];

  @override
  void initState() {
    super.initState();
    _getUserLocation();
    _loadRecentSearches();
  }

  void _loadRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('recent_searches') ?? [];
    setState(() {
      _recentSearches = history;
    });
  }

  void _saveRecentSearch(String keyword) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList('recent_searches') ?? [];
    history.remove(keyword);
    history.insert(0, keyword);
    if (history.length > 10) history.removeLast();
    await prefs.setStringList('recent_searches', history);
    _loadRecentSearches();
  }

  void _getUserLocation() async {
    try {
      final locationService = UserLocationService();
      final position = await locationService.getCurrentLocation();
      final currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = currentLatLng;
      });

      WidgetsBinding.instance.addPostFrameCallback((_) {
        _mapController.move(currentLatLng, 16.0);
      });
      await _shelterService.initialize();

      // 반경 거리 계산용 도구
      final distance = latlng.Distance();
      final maxDistance = 3000.0; // 반경 3km 이내 (단위: 미터)

      final allRegions = [
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

      List<Shelter> nearbyShelters = [];

      for (final region in allRegions) {
        try {
          final civilShelters = await _shelterService
              .getSheltersByRegionAndType(region, 'civil');
          final earthquakeShelters = await _shelterService
              .getSheltersByRegionAndType(region, 'earthquake');
          final tsunamiShelters = await _shelterService
              .getSheltersByRegionAndType(region, 'tsunami');

          final allShelters = [
            ...civilShelters,
            ...earthquakeShelters,
            ...tsunamiShelters,
          ];

          final filtered =
              allShelters.where((shelter) {
                final shelterLatLng = LatLng(
                  shelter.latitude,
                  shelter.longitude,
                );
                final dist = distance(currentLatLng, shelterLatLng);
                return dist <= maxDistance;
              }).toList();

          nearbyShelters.addAll(filtered);
        } catch (e) {
          print('❌ [$region] 지역 대피소 로딩 실패: $e');
        }
      }

      setState(() {
        _shelterMarkers =
            nearbyShelters.map((shelter) {
              return Marker(
                width: 60,
                height: 60,
                point: LatLng(shelter.latitude, shelter.longitude),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedShelter = shelter;
                    });
                  },
                  child: const Icon(Icons.location_pin, color: Colors.green),
                ),
              );
            }).toList();
      });
    } catch (e) {
      print('❌ 위치 또는 대피소 로딩 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도
          ShelterMap(
            currentPosition: _currentPosition,
            shelterMarkers: _shelterMarkers,
            mapController: _mapController,
            onMapTap: () {
              setState(() {
                _selectedShelter = null;
              });
            },
          ),

          //검색창
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                MainInput(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    );
                  },
                  onMenuTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SettingsMainScreen(),
                      ),
                    );
                  },
                  searchText: '',
                ),
                const SizedBox(height: 10),
                ..._recentSearches.map(
                  (keyword) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: GestureDetector(
                      onTap: () {
                        _saveRecentSearch(keyword);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => SearchScreen(initialKeyword: keyword),
                          ),
                        );
                      },
                      child: Text(
                        '• $keyword',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 현재 위치 버튼
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            bottom: _selectedShelter != null ? 360 : 280,
            right: 16,
            child: GpsButton(mapController: _mapController),
          ),

          if (_selectedShelter != null && _currentPosition != null)
            ShelterBottomSheet(
              mode: SheetMode.detail,
              child: ShelterDetailView(
                shelters: {
                  'name': _selectedShelter!.name,
                  'address': _selectedShelter!.address,
                  'latitude': _selectedShelter!.latitude,
                  'longitude': _selectedShelter!.longitude,
                  'earthquake': _selectedShelter!.earthquakeSafe ? 1 : 0,
                  'tsunami': _selectedShelter!.tsunamiSafe ? 1 : 0,
                  'isFavorite': _selectedShelter!.isFavorite ? 1 : 0,
                },
                currentPosition: Position(
                  latitude: _currentPosition!.latitude,
                  longitude: _currentPosition!.longitude,
                  timestamp: DateTime.now(),
                  accuracy: 0,
                  altitude: 0,
                  heading: 0,
                  speed: 0,
                  speedAccuracy: 0,
                  altitudeAccuracy: 0,
                  headingAccuracy: 0,
                ),
                onFavoriteToggle: (shelterMap) {
                  setState(() {
                    _selectedShelter = _selectedShelter!.copyWith(
                      isFavorite: !_selectedShelter!.isFavorite,
                    );
                  });
                },
                onNavigate: (shelterMap) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => NavigationPreviewScreen(
                            start: _currentPosition!,
                            destination: LatLng(
                              _selectedShelter!.latitude,
                              _selectedShelter!.longitude,
                            ),
                          ),
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
