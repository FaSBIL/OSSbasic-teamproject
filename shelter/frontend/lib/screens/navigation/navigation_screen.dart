import 'dart:async';
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
import 'package:shelter/map/user_marker.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:shelter/services/user_location.dart';
import 'package:shelter/utils/navigation_guidance_utils.dart';
import 'package:shelter/controllers/tts_controller.dart';
import 'package:shelter/utils/navigation_guidance_utils.dart';

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
  final TTSController _ttsController = TTSController();
  bool _navigationStarted = false;

  String distance = '계산 중...';
  List<LatLng> _path = [];
  List<GuidancePoint> _guidancePoints = [];
  LatLng? _currentPosition;
  StreamSubscription<Position>? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _ttsController.initTTS();
    _currentPosition = widget.start;
    _loadDistance();
    _calculatePath(widget.start);

    _positionSubscription = UserLocationService().getPositionStream().listen((
      position,
    ) {
      final updatedPosition = LatLng(position.latitude, position.longitude);
      if (mounted) {
        setState(() {
          _currentPosition = updatedPosition;
        });
        _calculatePath(updatedPosition);
        final zoom = _mapController.camera.zoom;
        _mapController.move(updatedPosition, zoom);
        _handleGuidance(updatedPosition);
      }
    });
  }

  @override
  void dispose() {
    _positionSubscription?.cancel();
    super.dispose();
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

  Future<void> _calculatePath(LatLng currentPos) async {
    try {
      await _dijkstraService.loadRegionData(
        currentPos.latitude,
        currentPos.longitude,
      );
      final int? startNode = await _dijkstraService.findClosestNode(
        currentPos.latitude,
        currentPos.longitude,
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
      final Map<int, LatLng> nodeMap = _dijkstraService.nodeMap;

      final List<LatLng> latLngPath = await _dijkstraService
          .getLatLngListFromNodeIds(nodePath);

      if (mounted) {
        setState(() {
          _path = latLngPath;
          _guidancePoints = extractGuidancePointsFromNodePath(
            nodePath,
            nodeMap,
          );
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

  double calculateRemainingPathDistance(LatLng currentPos, List<LatLng> path) {
    final distance = const Distance();

    // 경로에서 현재 위치와 가장 가까운 지점 찾기
    int closestIndex = 0;
    double minDist = double.infinity;
    for (int i = 0; i < path.length; i++) {
      final d = distance.as(LengthUnit.Meter, currentPos, path[i]);
      if (d < minDist) {
        minDist = d;
        closestIndex = i;
      }
    }

    // 현재 위치에서 가장 가까운 경로 지점까지 거리
    double total = distance.as(
      LengthUnit.Meter,
      currentPos,
      path[closestIndex],
    );

    // 이후 경로 구간 누적
    for (int i = closestIndex; i < path.length - 1; i++) {
      total += distance.as(LengthUnit.Meter, path[i], path[i + 1]);
    }

    return total;
  }

  void _handleGuidance(LatLng currentPos) async {
    if (!_navigationStarted) return; // 안내 시작 안했으면 종료

    final double distanceToDest = calculateRemainingPathDistance(
      currentPos,
      _path,
    );

    // 도착 안내
    if (distanceToDest <= 5 &&
        !_guidancePoints.any((p) => p.message == "목적지에 도착했습니다.")) {
      _ttsController.speak("목적지에 도착했습니다.");
      _guidancePoints.add(
        GuidancePoint(position: widget.destination, message: "목적지에 도착했습니다."),
      );
      return;
    }

    // 거리 기반 안내 (1km ~ 10m)
    final List<int> alertDistances = [
      1000,
      500,
      400,
      300,
      200,
      100,
      50,
      40,
      30,
      20,
      10,
    ];
    for (final dist in alertDistances) {
      if ((distanceToDest - dist).abs() <= 3) {
        if (!_guidancePoints.any((p) => p.message == "$dist미터 남았습니다.")) {
          _ttsController.speak("$dist미터 남았습니다.");
          _guidancePoints.add(
            GuidancePoint(
              position: widget.destination,
              message: "$dist미터 남았습니다.",
            ),
          );
          return;
        }
      }
    }

    for (final point in _guidancePoints) {
      final double dist = const Distance().as(
        LengthUnit.Meter,
        currentPos,
        point.position,
      );
      final List<int> turnDistances = [10, 5, 1, 0];

      for (final d in turnDistances) {
        if ((dist - d).abs() <= 1 && !point.distanceAnnounced.contains(d)) {
          // 사용자 heading 가져오기
          final compassEvent = await FlutterCompass.events!.first;
          final userHeading = compassEvent.heading ?? 0.0;

          // 경로상 다음 방향의 bearing 계산
          final pathBearing = calculateBearing(currentPos, point.position);

          // 실제 회전 방향 안내 문구 결정
          final instruction = getTurnInstruction(userHeading, pathBearing);

          final spokenText = d == 0 ? instruction : '$d미터 앞에서 $instruction';

          _ttsController.speak(spokenText);
          point.distanceAnnounced.add(d);
          break;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: _navigationStarted ? AppColors.blue : AppColors.white,
        title: Text(
          _navigationStarted ? '안내 중...' : '경로 미리보기',
          style: TextStyle(
            color: _navigationStarted ? Colors.white : Colors.black,
          ),
        ),
      ),
      body: Stack(
        children: [
          // 지도
          Positioned.fill(
            child: ShelterMap(
              currentPosition: _currentPosition ?? widget.start,
              mapController: _mapController,
              initialCenter: widget.start,
              shelterMarkers: [
                if (_currentPosition != null)
                  Marker(
                    width: 60,
                    height: 60,
                    point: _currentPosition!,
                    child: StreamBuilder<double?>(
                      stream: FlutterCompass.events!.map((e) => e.heading),
                      builder: (context, snapshot) {
                        final heading = snapshot.data ?? 0.0;
                        return LocationMarker(size: 40, heading: heading);
                      },
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
                  currentPosition: createMockPosition(
                    _currentPosition ?? widget.start,
                  ),
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
                  onNavigate: (_) {
                    setState(() {
                      _navigationStarted = true;
                      _ttsController.speak('안내를 시작합니다.');
                    });
                  },
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
