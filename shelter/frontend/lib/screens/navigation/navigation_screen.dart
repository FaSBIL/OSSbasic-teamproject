import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelter/theme/color.dart';
import 'package:shelter/utils/distance_calculator.dart' as calc;
import 'package:flutter_map/flutter_map.dart';
import 'package:shelter/map/shelter_map.dart';
import '../../services/dijkstra_service.dart';
import '../../utils/db_loader.dart' as loader;
import 'package:shelter/component/bottomSheet/ShelterBottomSheet.dart';
import 'package:shelter/component/bottomSheet/data/ShelterDetailView.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shelter/models/shelter.dart';
import 'package:shelter/utils/favorite_utils.dart';
import 'package:provider/provider.dart';
import 'package:shelter/provider/favorite_provider.dart';

Position createMockPosition(LatLng latLng) {
  return Position(
    latitude: latLng.latitude,
    longitude: latLng.longitude,
    timestamp: DateTime.now(),
    accuracy: 1.0,
    altitude: 0.0,
    heading: 0.0,
    speed: 0.0,
    speedAccuracy: 0.0,
    altitudeAccuracy: 0.0,
    headingAccuracy: 0.0,
  );
}

class NavigationScreen extends StatefulWidget {
  final LatLng start;
  final LatLng destination;
  final Shelter shelter;

  const NavigationScreen({
    super.key,
    required this.start,
    required this.destination,
    required this.shelter,
  });

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  final DijkstraService _dijkstraService = DijkstraService();
  final MapController _mapController = MapController();

  String distance = '계산 중...';
  List<LatLng> _path = [];

  @override
  void initState() {
    super.initState();
    _loadDistance();
    _calculatePath();
  }

  Future<void> _loadDistance() async {
    final result = await calc.DistanceCalculator.calculateDistanceWithTime(
      widget.start.latitude,
      widget.start.longitude,
      widget.destination.latitude,
      widget.destination.longitude,
    );

    if (mounted) {
      setState(() {
        distance = result;
      });
    }
  }

  Future<void> _calculatePath() async {
    try {
      await _dijkstraService.loadRegionData(
        widget.start.latitude,
        widget.start.longitude,
      );

      final int? startNode = await _dijkstraService.findClosestNode(
        widget.start.latitude,
        widget.start.longitude,
      );
      final int? endNode = await _dijkstraService.findClosestNode(
        widget.destination.latitude,
        widget.destination.longitude,
      );

      if (startNode == null || endNode == null) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('경로 탐색에 실패했습니다.')));
        }
        return;
      }

      final List<int> nodePath = await _dijkstraService.findShortestPath(
        startNode,
        endNode,
      );
      final List<LatLng> latLngPath = await _dijkstraService
          .getLatLngListFromNodeIds(nodePath);

      if (mounted) {
        setState(() {
          _path = latLngPath;
        });
      }
    } catch (e) {
      print('[경로 탐색 실패] $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('경로 탐색 중 오류가 발생했습니다.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(backgroundColor: AppColors.white, title: Text('경로 미리보기')),
      body: Stack(
        children: [
          // 지도
          Positioned.fill(
            child: ShelterMap(
              currentPosition: widget.start,
              mapController: _mapController,
              initialCenter: widget.start,
              shelterMarkers: [
                Marker(
                  width: 60,
                  height: 60,
                  point: widget.start,
                  child: const Icon(
                    Icons.my_location,
                    color: AppColors.blue,
                    size: 40,
                  ),
                ),
                Marker(
                  width: 60,
                  height: 60,
                  point: widget.destination,
                  child: const Icon(
                    Icons.location_on,
                    color: AppColors.blue,
                    size: 40,
                  ),
                ),
              ],
              path: _path,
            ),
          ),

          // 바텀시트
          ShelterBottomSheet(
            mode: SheetMode.detail,
            child: Builder(
              builder: (context) {
                final provider = context.watch<FavoriteProvider>();
                final isFavorite = provider.isFavorite(widget.shelter.name);

                return ShelterDetailView(
                  shelters: {
                    'name': widget.shelter.name,
                    'address': widget.shelter.address,
                    'latitude': widget.shelter.latitude,
                    'longitude': widget.shelter.longitude,
                    'earthquake': widget.shelter.earthquakeSafe ? 1 : 0,
                    'tsunami': widget.shelter.tsunamiSafe ? 1 : 0,
                    'isFavorite': isFavorite ? 1 : 0,
                  },
                  currentPosition: createMockPosition(widget.start),
                  onFavoriteToggle: (shelterMap) async {
                    final provider = context.read<FavoriteProvider>();
                    final tableName = getTableName(shelterMap);
                    final name = shelterMap['name'];

                    await provider.toggleFavorite(tableName, name);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          provider.isFavorite(name)
                              ? '즐겨찾기에 추가되었습니다.'
                              : '즐겨찾기에서 제거되었습니다.',
                        ),
                        duration: const Duration(seconds: 1),
                      ),
                    );
                  },
                  onNavigate: (_) {},
                  navButtonText: '안내 시작',
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
