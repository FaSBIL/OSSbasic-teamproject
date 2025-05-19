import 'package:flutter/material.dart';
import 'package:shelter/models/shelter.dart';
import 'package:shelter/services/filter_shelters.dart';
import 'package:shelter/screens/search/shelter_map_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelter/services/user_location.dart';
import 'package:shelter/theme/color.dart';

class ShelterListScreen extends StatefulWidget {
  final String region;

  const ShelterListScreen({super.key, required this.region});

  @override
  State<ShelterListScreen> createState() => _ShelterListScreenState();
}

class _ShelterListScreenState extends State<ShelterListScreen> {
  final ShelterService _shelterService = ShelterService();
  List<Shelter> _shelters = [];
  bool _isLoading = true;
  LatLng? _currentPosition;

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
    '전라남도': 'jeonnam',
    '경상북도': 'gyeongbuk',
    '경상남도': 'gyeongnam',
    '제주특별자치도': 'jeju',
  };

  @override
  void initState() {
    super.initState();
    _loadShelters();
  }

  Future<void> _loadShelters() async {
    await _shelterService.initialize();
    final regionCode = regionNameToCode[widget.region];
    if (regionCode == null) {
      setState(() => _isLoading = false);
      return;
    }

    final civil = await _shelterService.getSheltersByRegionAndType(
      regionCode,
      'civil',
    );
    final earthquake = await _shelterService.getSheltersByRegionAndType(
      regionCode,
      'earthquake',
    );
    final tsunami = await _shelterService.getSheltersByRegionAndType(
      regionCode,
      'tsunami',
    );

    final position = await UserLocationService().getCurrentLocation();
    _currentPosition = LatLng(position.latitude, position.longitude);

    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
      _shelters = [
        ...civil.map((s) => s.copyWith(type: '민방위')),
        ...earthquake.map((s) => s.copyWith(type: '지진')),
        ...tsunami.map((s) => s.copyWith(type: '해일')),
      ];
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        title: Text('${widget.region} 대피소'),
        actions: [
          IconButton(
            icon: const Icon(Icons.map_outlined),
            tooltip: '지도 보기',
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder:
                        (_) => ShelterMapScreen(
                          region: widget.region,
                          shelters: _shelters,
                          currentPosition: _currentPosition,
                        ),
                  ),
                ),
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _shelters.isEmpty
              ? const Center(child: Text('대피소 데이터가 없습니다.'))
              : ListView.separated(
                itemCount: _shelters.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final shelter = _shelters[index];
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
                    leading: const Icon(Icons.location_on_outlined),
                    trailing: const Icon(Icons.chevron_right),
                  );
                },
              ),
    );
  }
}
