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
import 'package:shelter/component/bottomSheet/data/ShelterListView.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shelter/screens/navigation/navigation_screen.dart';
import 'package:shelter/screens/settings/SettingsMainScreens.dart';
import 'package:shelter/theme/color.dart';
import 'package:shelter/utils/favorite_utils.dart';
import 'package:shelter/utils/navigation_animation.dart';
import 'package:shelter/services/favorite_service.dart';
import 'package:provider/provider.dart';
import 'package:shelter/provider/favorite_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

String getTableName(Shelter shelter) {
  final address = shelter.address;

  if (address.contains('서울')) return 'seoul';
  if (address.contains('부산')) return 'busan';
  if (address.contains('대전')) return 'daejeon';
  if (address.contains('광주')) return 'gwangju';
  if (address.contains('인천')) return 'incheon';
  if (address.contains('대구')) return 'daegu';
  if (address.contains('울산')) return 'ulsan';
  if (address.contains('세종')) return 'sejong';
  if (address.contains('경기도') || address.contains('경기')) return 'gyeonggi';
  if (address.contains('강원도') || address.contains('강원')) return 'gangwon';
  if (address.contains('충청북도') || address.contains('충북')) return 'chungbuk';
  if (address.contains('충청남도') || address.contains('충남')) return 'chungnam';
  if (address.contains('전라북도') || address.contains('전북')) return 'jeonbuk';
  if (address.contains('전라남도') || address.contains('전남')) return 'jeonnam';
  if (address.contains('경상북도') || address.contains('경북')) return 'gyeongbuk';
  if (address.contains('경상남도') || address.contains('경남')) return 'gyeongnam';
  if (address.contains('제주')) return 'jeju';

  throw Exception('❌ getTableName: 알 수 없는 주소 형식입니다 -> ${shelter.address}');
}

String getTableNameFromAddress(String address) {
  if (address.contains('서울')) return 'seoul';
  if (address.contains('부산')) return 'busan';
  if (address.contains('대전')) return 'daejeon';
  if (address.contains('광주')) return 'gwangju';
  if (address.contains('인천')) return 'incheon';
  if (address.contains('대구')) return 'daegu';
  if (address.contains('울산')) return 'ulsan';
  if (address.contains('세종')) return 'sejong';
  if (address.contains('경기도') || address.contains('경기')) return 'gyeonggi';
  if (address.contains('강원도') || address.contains('강원')) return 'gangwon';
  if (address.contains('충청북도') || address.contains('충북')) return 'chungbuk';
  if (address.contains('충청남도') || address.contains('충남')) return 'chungnam';
  if (address.contains('전라북도') || address.contains('전북')) return 'jeonbuk';
  if (address.contains('전라남도') || address.contains('전남')) return 'jeonnam';
  if (address.contains('경상북도') || address.contains('경북')) return 'gyeongbuk';
  if (address.contains('경상남도') || address.contains('경남')) return 'gyeongnam';
  if (address.contains('제주')) return 'jeju';

  throw Exception('❌ getTableNameFromAddress: 알 수 없는 주소 형식입니다 -> $address');
}

class _HomeScreenState extends State<HomeScreen> {
  LatLng? _currentPosition;
  List<Marker> _shelterMarkers = [];
  final MapController _mapController = MapController();

  final DraggableScrollableController _sheetController =
      DraggableScrollableController();

  final ShelterService _shelterService = ShelterService(); // 대피소 서비스
  Shelter? _selectedShelter; // 선택된 대피소 정보를 담는 변수

  List<Shelter> _nearbyShelters = [];

  @override
  void initState() {
    super.initState();
    _getUserLocation();

    Future.microtask(() {
      final provider = context.read<FavoriteProvider>();
      provider.loadFavorites([
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
      ]);
    });
  }

  Color _getMarkerColor(Shelter shelter) {
    if (shelter.earthquakeSafe) return Colors.purple; // 지진
    if (shelter.tsunamiSafe) return Colors.green; // 해일
    if (!shelter.earthquakeSafe && !shelter.tsunamiSafe)
      return AppColors.blue; // 민방위
    return Colors.grey;
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

      nearbyShelters.sort((a, b) {
        final distA = distance(currentLatLng, LatLng(a.latitude, a.longitude));
        final distB = distance(currentLatLng, LatLng(b.latitude, b.longitude));
        return distA.compareTo(distB);
      });
      nearbyShelters = nearbyShelters.take(10).toList();

      setState(() {
        _shelterMarkers =
            nearbyShelters.map((shelter) {
              return Marker(
                width: 60,
                height: 60,
                point: LatLng(shelter.latitude, shelter.longitude),
                child: GestureDetector(
                  onTap: () {
                    final tappedShelter = _nearbyShelters.firstWhere(
                      (s) =>
                          s.name == shelter.name &&
                          s.address == shelter.address,
                      orElse: () => shelter,
                    );

                    setState(() {
                      _selectedShelter = tappedShelter;
                    });
                  },

                  child: Icon(
                    Icons.location_pin,
                    color: _getMarkerColor(shelter),
                    size: 40,
                  ),
                ),
              );
            }).toList();

        _nearbyShelters = nearbyShelters.take(10).toList();
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
            top: 70,
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
                      slideFromLeft(const SettingsMainScreen()),
                    );
                  },
                  searchText: '',
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),

          // 현재 위치 버튼
          Positioned(
            bottom: 360,
            right: 16,
            child: GpsButton(mapController: _mapController),
          ),

          if (_selectedShelter != null && _currentPosition != null)
            ShelterBottomSheet(
              mode: SheetMode.detail,
              controller: _sheetController,
              child: Builder(
                builder: (context) {
                  final provider = context.watch<FavoriteProvider>();
                  final isFavorite = provider.isFavorite(
                    _selectedShelter!.name,
                  );

                  return ShelterDetailView(
                    shelters: {
                      'name': _selectedShelter!.name,
                      'address': _selectedShelter!.address,
                      'latitude': _selectedShelter!.latitude,
                      'longitude': _selectedShelter!.longitude,
                      'earthquake': _selectedShelter!.earthquakeSafe ? 1 : 0,
                      'tsunami': _selectedShelter!.tsunamiSafe ? 1 : 0,
                      'isFavorite': isFavorite ? 1 : 0,
                    },
                    // ... 아래 onFavoriteToggle는 아래에서 설명 ...
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
                    onFavoriteToggle: (shelterMap) async {
                      final provider = context.read<FavoriteProvider>();
                      final tableName = getTableName(_selectedShelter!);
                      final name = _selectedShelter!.name;

                      await provider.toggleFavorite(tableName, name);

                      final isNowFavorite = provider.isFavorite(name);
                      setState(() {
                        _selectedShelter = _selectedShelter!.copyWith(
                          isFavorite: isNowFavorite,
                        );
                        _nearbyShelters =
                            _nearbyShelters.map((shelter) {
                              if (shelter.name == name &&
                                  shelter.address ==
                                      _selectedShelter!.address) {
                                return shelter.copyWith(
                                  isFavorite: isNowFavorite,
                                );
                              }
                              return shelter;
                            }).toList();
                      });

                      // 사용자 피드백
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isNowFavorite
                                ? '즐겨찾기에 추가되었습니다.'
                                : '즐겨찾기에서 제거되었습니다.',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    onNavigate: (shelterMap) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => NavigationScreen(
                                start: _currentPosition!,
                                destination: LatLng(
                                  _selectedShelter!.latitude,
                                  _selectedShelter!.longitude,
                                ),
                                shelter: _selectedShelter!,
                              ),
                        ),
                      );
                    },
                    navButtonText: '경로 보기',
                  );
                },
              ),
            )
          else if (_currentPosition != null)
            ShelterBottomSheet(
              mode: SheetMode.list,
              controller: _sheetController,
              child: Builder(
                builder: (context) {
                  final provider = context.watch<FavoriteProvider>();

                  final nearbySheltersMap = _nearbyShelters.map((shelter) => {
                    'name': shelter.name,
                    'address': shelter.address,
                    'latitude': shelter.latitude,
                    'longitude': shelter.longitude,
                    'earthquake': shelter.earthquakeSafe ? 1 : 0,
                    'tsunami': shelter.tsunamiSafe ? 1 : 0,
                    'isFavorite': provider.isFavorite(shelter.name) ? 1 : 0,
                  }).toList();

                  return ShelterListView(
                    scrollController: ScrollController(),
                    shelters: nearbySheltersMap,
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
                    onTapItem: (shelterMap) {
                      final tapped = _nearbyShelters.firstWhere(
                        (s) => s.name == shelterMap['name'],
                        orElse: () => _nearbyShelters.first,
                      );
                      setState(() {
                        _selectedShelter = tapped;
                      });
                    },
                    onFavoriteToggle: (shelterMap) async {
                      final address = shelterMap['address'] ?? '';
                      final name = shelterMap['name'] ?? '';

                      final tableName = getTableNameFromAddress(address);
                      final provider = context.read<FavoriteProvider>();

                      await provider.toggleFavorite(tableName, name);
                      final isNowFavorite = provider.isFavorite(name);

                      setState(() {
                        _nearbyShelters = _nearbyShelters.map((shelter) {
                          if (shelter.name == name && shelter.address == address) {
                            return shelter.copyWith(isFavorite: isNowFavorite);
                          }
                          return shelter;
                        }).toList();
                      });

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            isNowFavorite ? '즐겨찾기에 추가되었습니다.' : '즐겨찾기에서 제거되었습니다.',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    onNavigate: (shelterMap) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (_) => NavigationScreen(
                                start: _currentPosition!,
                                destination: LatLng(
                                  shelterMap['latitude'],
                                  shelterMap['longitude'],
                                ),
                                shelter: Shelter(
                                  name: shelterMap['name'],
                                  address: shelterMap['address'],
                                  latitude: shelterMap['latitude'],
                                  longitude: shelterMap['longitude'],
                                  earthquakeSafe: shelterMap['earthquake'] == 1,
                                  tsunamiSafe: shelterMap['tsunami'] == 1,
                                  isFavorite: shelterMap['isFavorite'] == 1,
                                ),
                              ),
                        ),
                      );
                    },
                    navButtonText: '경로 보기',
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
