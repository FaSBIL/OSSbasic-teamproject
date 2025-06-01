import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelter/utils/db_loader.dart';
import 'package:shelter/component/bottomSheet/ShelterBottomSheet.dart';
import 'package:shelter/component/bottomSheet/data/ShelterListView.dart';
import 'package:geolocator/geolocator.dart';

class BottomSheetTestScreen extends StatefulWidget {
  const BottomSheetTestScreen({super.key});

  @override
  State<BottomSheetTestScreen> createState() => _BottomSheetTestScreenState();
}

class _BottomSheetTestScreenState extends State<BottomSheetTestScreen> {
  List<Map<String, dynamic>> shelters = [];
  Position? currentPosition;

  @override
  void initState() {
    super.initState();
    initialize();
  }

  Future<void> initialize() async {
    await getCurrentLocation();
    await loadData();
  }

  Future<void> getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        throw Exception('Location services are disabled.');
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Location permissions are denied');
        }
      }

      if (permission == LocationPermission.deniedForever) {
        throw Exception('Location permissions are permanently denied');
      }

      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      setState(() {
        currentPosition = position;
      });

      print('✅ 현재지 취득 성공: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      print('❌ 현재 위치 취득 실패: $e');
    }
  }

  Future<void> loadData() async {
    try {
      final db = await loadDatabase();
      final rows = await db.query('seoul', limit: 10);
      await db.close();

      setState(() {
        shelters = rows;
      });
      print('✅ DB 로드 성공: ${shelters.length} 件');
    } catch (e) {
      print('❌ DB 로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(initialCenter: LatLng(37.5665, 126.9780)),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.osm_map',
              ),
              MarkerLayer(
                markers:
                    shelters.map((shelter) {
                      return Marker(
                        point: LatLng(
                          shelter['latitude'] ?? 0.0,
                          shelter['longitude'] ?? 0.0,
                        ),
                        width: 80,
                        height: 80,
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40,
                        ),
                      );
                    }).toList(),
              ),
            ],
          ),

          // Align(
          //   alignment: Alignment.bottomCenter,
          //   child: shelters.isEmpty
          //       ? const CircularProgressIndicator()
          //       : ShelterBottomSheet(
          //           mode: SheetMode.detail,
          //           child: ShelterListView(
          //             scrollController: ScrollController(),
          //             shelters: shelters,
          //             currentPosition: currentPosition,
          //             onFavoriteToggle: (updatedShelter) {
          //               print('favorite Button: ${updatedShelter['name']}');
          //             },
          //             onNavigate: (updatedShelter) {
          //               print('nav Start: ${updatedShelter['name']}');
          //             },
          //             onTapItem: (shelter) {
          //               print('onTap click: ${shelter['name']}');
          //             },
          //           ),
          //         ),
          // ),
        ],
      ),
    );
  }
}
