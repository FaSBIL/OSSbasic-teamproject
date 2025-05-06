import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import '../services/user_location.dart';
import '../services/filter_shelters.dart';
import '../map/shelter_map.dart';
import '../widgets/shelter_filter_buttons.dart';
import '../widgets/error_banner.dart';

class HomeScreen extends StatefulWidget {
  final MapController _mapController = MapController();
  HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final UserLocationService _locationService = UserLocationService();
  final ShelterService _shelterService = ShelterService();
  final MapController _mapController = MapController();
  LatLng? _currentPosition;
  String _errorMessage = '';
  final MapController _mapController = MapController();
  late Stream<Position> _positionStream;
  String _selectedShelterType = 'civil';
  List<Marker> _shelterMarkers = [];

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
    '전북특별자치도': 'jeonbuk',
    '전라북도': 'jeonbuk',
    '전라남도': 'jeonnam',
    '경상북도': 'gyeongbuk',
    '경상남도': 'gyeongnam',
    '제주특별자치도': 'jeju',
  };

  @override
  void initState() {
    super.initState();
    _initializePositionStream();
    _initializeServices();
  }

  void _initializePositionStream() {
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    );

    _positionStream.listen(
      (Position position) {
        if (!mounted) return;
        final newPosition = LatLng(position.latitude, position.longitude);
        setState(() => _currentPosition = newPosition);

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _mapController.move(newPosition, _mapController.camera.zoom);
          }
        });

        _loadShelters();
      },
      onError: (e) {
        if (!mounted) return;
        setState(() => _errorMessage = '위치 스트림 오류: $e');
      },
    );
  }

  Future<void> _initializeServices() async {
    try {
      await _shelterService.initialize();
      await _setInitialLocation();
    } catch (e) {
      setState(() => _errorMessage = '초기화 오류: $e');
    }
  }

  Future<void> _setInitialLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      final initialPosition = LatLng(position.latitude, position.longitude);
      setState(() => _currentPosition = initialPosition);

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _mapController.move(initialPosition, 14.0);
        }
      });

      await _loadShelters();
    } catch (e) {
      setState(() => _errorMessage = '위치 설정 오류: $e');
    }
  }

  Future<void> _loadShelters() async {
    if (_currentPosition == null) return;

    try {
      final regionData = await _locationService.getNearestLocation(
        _currentPosition!.latitude,
        _currentPosition!.longitude,
      );
      final regionCode = regionNameToCode[regionData['do']?.trim() ?? ''];
      if (regionCode == null) throw Exception('알 수 없는 지역');

      List<Map<String, dynamic>> shelters = [];
      if (_selectedShelterType == 'civil') {
        shelters = await _shelterService.getCivilShelters(regionCode);
      } else if (_selectedShelterType == 'earthquake') {
        shelters = await _shelterService.getEarthquakeShelters(regionCode);
      } else if (_selectedShelterType == 'tsunami') {
        shelters = await _shelterService.getTsunamiShelters(regionCode);
      }

      setState(() {
        _shelterMarkers =
            shelters
                .map((shelter) {
                  final lat = shelter['latitude'];
                  final lng = shelter['longitude'];
                  return lat is num && lng is num
                      ? Marker(
                        width: 80,
                        height: 80,
                        point: LatLng(lat.toDouble(), lng.toDouble()),
                        child: Icon(
                          Icons.location_pin,
                          color: _getMarkerColor(_selectedShelterType),
                          size: 30,
                        ),
                      )
                      : null;
                })
                .whereType<Marker>()
                .toList();
      });
    } catch (e) {
      setState(() {
        _errorMessage = '대피소 로드 오류: $e';
        _shelterMarkers = [];
      });
    }
  }

  Color _getMarkerColor(String type) {
    switch (type) {
      case 'civil':
        return Colors.green;
      case 'earthquake':
        return Colors.orange;
      case 'tsunami':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  void _onShelterTypeChanged(String type) {
    if (_selectedShelterType != type) {
      setState(() {
        _selectedShelterType = type;
        _shelterMarkers = [];
      });
      _loadShelters();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          ShelterMap(
            currentPosition: _currentPosition,
            shelterMarkers: _shelterMarkers,
            mapController: _mapController,
          ),
          _buildSearchBar(),
          _buildSettingsButton(),
          ShelterFilterButtons(
            selectedType: _selectedShelterType,
            onTypeChanged: _onShelterTypeChanged,
          ),
          if (_errorMessage.isNotEmpty) ErrorBanner(message: _errorMessage),
          _buildLocationButton(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() => Positioned(
    top: 60,
    left: 16,
    right: 70,
    child: GestureDetector(
      onTap: () => print('[Home] Search tapped'),
      child: Container(
        height: 45,
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
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
  );

  Widget _buildSettingsButton() => Positioned(
    top: 60,
    right: 16,
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 2)),
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.settings, color: Colors.black54),
        onPressed: () => print('[Home] Settings tapped'),
      ),
    ),
  );

  Widget _buildLocationButton() => Positioned(
    bottom: 24,
    right: 16,
    child: FloatingActionButton(
      mini: true,
      backgroundColor: Colors.white,
      onPressed: () => setState(() {}),
      child: const Icon(Icons.my_location, color: Colors.black54),
    ),
  );
}
