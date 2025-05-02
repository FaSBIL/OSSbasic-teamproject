import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../services/user_location.dart';
import '../services/filter_shelters.dart'; // 대피소 데이터 필터링 서비스 추가

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserLocationService _locationService = UserLocationService();
  final ShelterService _shelterService = ShelterService(); // 대피소 서비스 추가
  LatLng? _currentPosition; // 사용자 위치 저장
  String _errorMessage = ''; // 오류 메시지 저장
  late Stream<Position> _positionStream; // 실시간 위치 스트림
  String _selectedShelterType = 'civil'; // 기본 대피소 유형: 민방위
  List<Marker> _shelterMarkers = []; // 지도에 표시할 대피소 마커

  // 한글 지역명 -> 영문 코드 매핑
  final Map<String, String> regionNameToCode = {
    '서울특별시': 'seoul',
    '부산광역시': 'busan',
    '대구광역시': 'daegu',
    '인천광역시': 'incheon',
    '광주광역시': 'gwangju',
    '대전광역시': 'daejeon',
    '울산광역시': 'ulsan',
    '세종특별자치시': 'sejong',
    '경기도': 'gyeonggi',
    '강원특별자치도': 'gangwon',
    '충청북도': 'chungbuk',
    '충청남도': 'chungnam',
    '전북특별자치도': 'jeonbuk', // '전라북도' 대신 사용될 수 있음
    '전라북도': 'jeonbuk',
    '전라남도': 'jeonnam',
    '경상북도': 'gyeongbuk',
    '경상남도': 'gyeongnam',
    '제주특별자치도': 'jeju',
  };

  @override
  void initState() {
    super.initState();
    _initializePositionStream(); // 실시간 위치 스트림 초기화
    _initializeServices(); // 서비스 초기화 (DB 로딩 및 초기 위치 설정 포함)
  }

  Future<void> _initializeServices() async {
    try {
      // ShelterService 초기화 (DB 로딩)
      await _shelterService.initialize();
      print('[Home] ShelterService initialized.');

      // 초기 위치 설정
      await _setInitialLocation();
      print('[Home] Initial location set.');
    } catch (e) {
      setState(() {
        _errorMessage = '초기화 중 오류 발생: $e';
      });
      print('[Home] Initialization error: $e'); // 콘솔에도 에러 출력
    }
  }

  void _initializePositionStream() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10미터 이상 이동 시 업데이트
      ),
    );

    _positionStream.listen(
      (Position position) {
        if (mounted) {
          // 위젯이 여전히 트리에 있는지 확인
          print(
            '[Home] Position updated: ${position.latitude}, ${position.longitude}',
          );
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
            _errorMessage = ''; // 위치 업데이트 성공 시 오류 메시지 초기화
          });
          // 위치가 변경될 때마다 대피소 다시 로드
          _loadShelters();
        }
      },
      onError: (e) {
        if (mounted) {
          setState(() {
            _errorMessage = '위치 스트림 오류: $e';
          });
          print('[Home] Position stream error: $e');
        }
      },
    );
  }

  Future<void> _setInitialLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      if (mounted) {
        setState(() {
          _currentPosition = LatLng(position.latitude, position.longitude);
        });
        // 초기 위치 설정 후 대피소 데이터 로드
        await _loadShelters();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '초기 위치 설정 오류: $e';
        });
        print('[Home] Error setting initial location: $e');
      }
    }
  }

  Future<void> _loadShelters() async {
    if (_currentPosition == null) {
      print('[Home] Cannot load shelters, current position is null.');
      return;
    }
    if (!mounted) return; // 위젯이 마운트되지 않았으면 중단

    print('[Home] Loading shelters for type: $_selectedShelterType');

    try {
      final regionData = await _locationService.getNearestLocation(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      final String koreanRegionName = regionData['do']?.trim() ?? '';
      print('[Home] Nearest Korean region: $koreanRegionName');

      final String? regionCode =
          regionNameToCode[koreanRegionName]; // 영문 코드로 변환
      print('[Home] Corresponding region code: $regionCode');

      if (regionCode == null) {
        if (mounted) {
          setState(() {
            _errorMessage = '알 수 없는 지역입니다: $koreanRegionName';
            _shelterMarkers = []; // 마커 초기화
          });
        }
        print('[Home] Unknown region: $koreanRegionName');
        return; // 지역 코드를 찾을 수 없으면 중단
      }

      List<Map<String, dynamic>> shelters = [];
      Stopwatch stopwatch = Stopwatch()..start(); // 시간 측정 시작

      if (_selectedShelterType == 'civil') {
        shelters = await _shelterService.getCivilShelters(regionCode);
      } else if (_selectedShelterType == 'earthquake') {
        shelters = await _shelterService.getEarthquakeShelters(regionCode);
      } else if (_selectedShelterType == 'tsunami') {
        // 쓰나미 대피소는 전국 단위일 수 있으므로 regionCode가 필요 없을 수 있음
        // ShelterService의 getTsunamiShelters 구현에 따라 regionCode 전달 여부 결정
        shelters = await _shelterService.getTsunamiShelters(
          regionCode,
        ); // 현재는 regionCode 전달
      }
      // 다른 대피소 유형 ('fire', 'flood' 등)에 대한 로직 추가 필요
      else {
        print('[Home] Unsupported shelter type: $_selectedShelterType');
        shelters = []; // 지원하지 않는 타입이면 빈 리스트
      }

      stopwatch.stop(); // 시간 측정 종료
      print(
        '[Home] Loaded ${shelters.length} shelters for $regionCode ($_selectedShelterType) in ${stopwatch.elapsedMilliseconds}ms',
      );

      if (mounted) {
        setState(() {
          _shelterMarkers =
              shelters
                  .map((shelter) {
                    // 위도, 경도 타입 확인 및 변환
                    final latitude = shelter['latitude'];
                    final longitude = shelter['longitude'];

                    if (latitude is num && longitude is num) {
                      return Marker(
                        width: 80.0, // 마커 크기 지정 (선택 사항)
                        height: 80.0,
                        point: LatLng(
                          latitude.toDouble(),
                          longitude.toDouble(),
                        ),
                        child: Icon(
                          Icons.location_pin, // 기본 아이콘
                          color: _getMarkerColor(
                            _selectedShelterType,
                          ), // 타입별 색상
                          size: 30,
                        ),
                        // key: Key('shelter_${shelter['id']}'), // 고유 ID가 있다면 Key 사용 고려
                      );
                    } else {
                      print('[Home] Invalid coordinates for shelter: $shelter');
                      return null; // 잘못된 데이터는 마커 생성 안 함
                    }
                  })
                  .whereType<Marker>()
                  .toList(); // null이 아닌 마커만 리스트에 포함
          _errorMessage = ''; // 성공 시 오류 메시지 초기화
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = '대피소 데이터를 로드하는 중 오류 발생: $e';
          _shelterMarkers = []; // 오류 시 마커 초기화
        });
      }
      print('[Home] Error loading shelters: $e'); // 콘솔에도 에러 출력
    }
  }

  // 마커 색상 반환 함수
  Color _getMarkerColor(String type) {
    switch (type) {
      case 'civil':
        return Colors.green; // 민방위: 초록색
      case 'earthquake':
        return Colors.orange; // 지진: 주황색
      case 'tsunami':
        return Colors.blue; // 해일: 파란색
      // case 'fire': return Colors.red; // 예시: 화재
      // case 'flood': return Colors.purple; // 예시: 홍수
      default:
        return Colors.grey; // 기타: 회색
    }
  }

  void _onShelterTypeChanged(String type) {
    if (_selectedShelterType == type) return; // 같은 타입이면 변경 안 함

    print('[Home] Shelter type changed to: $type');
    setState(() {
      _selectedShelterType = type;
      _shelterMarkers = []; // 타입 변경 시 마커 즉시 초기화 (선택 사항)
      _errorMessage = ''; // 타입 변경 시 오류 메시지 초기화
    });
    // 변경된 타입으로 대피소 다시 로드
    _loadShelters();
  }

  @override
  Widget build(BuildContext context) {
    print('[Home] Building UI. Current position: $_currentPosition');
    return Scaffold(
      body: Stack(
        children: [
          // 지도 표시 영역
          if (_currentPosition != null)
            FlutterMap(
              options: MapOptions(
                initialCenter: _currentPosition!, // 사용자 위치로 초기화
                initialZoom: 14.0, // 초기 줌 레벨 조정
                minZoom: 10.0,
                maxZoom: 18.0,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png', // 오픈스트리트맵 타일 사용
                  userAgentPackageName: 'com.example.shelter', // 앱 패키지 이름
                  // subdomains: ['a', 'b', 'c'], // 필요 시 서브도메인 사용
                ),
                MarkerLayer(
                  markers: [
                    // 현재 위치 마커
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _currentPosition!,
                      child: const Icon(
                        Icons.my_location, // 현재 위치 아이콘
                        color: Colors.redAccent,
                        size: 35,
                      ),
                      key: const Key('current_location'),
                    ),
                    // 대피소 마커 목록
                    ..._shelterMarkers,
                  ],
                ),
              ],
            )
          else
            // 로딩 중 표시
            const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 10),
                  Text('현재 위치를 가져오는 중...'),
                ],
              ),
            ),

          // 상단 UI 요소 (검색창, 설정 버튼)
          Positioned(
            top: 60, // 상태 표시줄 높이 고려
            left: 16,
            right: 70, // 설정 버튼 공간 확보
            child: GestureDetector(
              onTap: () {
                // TODO: 검색 기능 구현
                print('[Home] Search bar tapped');
              },
              child: Container(
                height: 45,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 5,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: [
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8),
                    Text("대피소 검색", style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: 60,
            right: 16,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.9),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 5,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.settings, color: Colors.black54),
                onPressed: () {
                  // TODO: 설정 화면으로 이동 로직 구현
                  print('[Home] Settings button tapped');
                  // Navigator.pushNamed(context, AppRoutes.settings); // 예시
                },
              ),
            ),
          ),

          // 필터 버튼 영역
          Positioned(
            top: 120, // 검색창 아래
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              height: 50, // 버튼 높이 고정
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal, // 가로 스크롤
                child: Row(
                  children: [
                    _buildFilterButton(
                      Icons.security,
                      '민방위',
                      'civil',
                    ), // 아이콘 변경
                    _buildFilterButton(Icons.waves, '해일', 'tsunami'), // 아이콘 변경
                    _buildFilterButton(
                      Icons.landslide,
                      '지진',
                      'earthquake',
                    ), // 아이콘 변경
                    // _buildFilterButton(Icons.flood, '홍수', 'flood'), // 필요 시 추가
                    // _buildFilterButton(Icons.local_fire_department, '화재', 'fire'), // 필요 시 추가
                  ],
                ),
              ),
            ),
          ),

          // 오류 메시지 표시 영역
          if (_errorMessage.isNotEmpty)
            Positioned(
              bottom: 80, // 하단 버튼 위
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.redAccent.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  _errorMessage,
                  style: const TextStyle(color: Colors.white),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

          // 현재 위치로 이동 버튼
          Positioned(
            bottom: 24,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                if (_currentPosition != null) {
                  // TODO: 지도 컨트롤러를 사용하여 부드럽게 이동하는 로직 추가
                  print('[Home] My Location button tapped');
                  // mapController.move(_currentPosition!, 15.0); // 예시
                  setState(() {
                    // 임시로 setState만 호출하여 지도 리빌드 유도 (컨트롤러 없을 경우)
                  });
                }
              },
              child: const Icon(Icons.my_location, color: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }

  // 필터 버튼 위젯 생성 함수
  Widget _buildFilterButton(IconData icon, String label, String type) {
    bool isSelected = _selectedShelterType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () => _onShelterTypeChanged(type),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ), // 패딩 조정
          decoration: BoxDecoration(
            color:
                isSelected
                    ? Theme.of(context).primaryColor
                    : Colors.white, // 테마 색상 사용
            borderRadius: BorderRadius.circular(20), // 둥근 모서리
            border: Border.all(
              color:
                  isSelected
                      ? Theme.of(context).primaryColor
                      : Colors.grey[300]!,
              width: 1,
            ),
            boxShadow:
                isSelected
                    ? [
                      BoxShadow(
                        color: Theme.of(context).primaryColor.withOpacity(0.3),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ]
                    : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min, // 내용물 크기에 맞춤
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.black54,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.black87,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
