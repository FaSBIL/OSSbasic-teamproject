import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';

import '../../services/dijkstra_service.dart';
import '../../services/user_location.dart';
import '../../utils/db_loader.dart' as loader;
import '../../map/path_painter.dart';

class AutoNavigationScreen extends StatefulWidget {
  const AutoNavigationScreen({Key? key}) : super(key: key);

  @override
  State<AutoNavigationScreen> createState() => _AutoNavigationScreenState();
}

class _AutoNavigationScreenState extends State<AutoNavigationScreen> {
  final DijkstraService _dijkstraService = DijkstraService();

  LatLng? _currentLocation;
  List<LatLng> _path = [];

  @override
  void initState() {
    super.initState();
    _navigateAutomatically();
  }

  Future<void> _navigateAutomatically() async {
    try {
      // 현재 위치 가져오기
      final locationService = UserLocationService();
      final Position position = await locationService.getCurrentLocation();
      _currentLocation = LatLng(position.latitude, position.longitude);
      //_currentLocation = LatLng(36.6, 127.4);// 테스트용 위치
      // 지역별 노드/간선 로딩
      await _dijkstraService.loadRegionData(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
      );
      print('[디버그] region DB 로드 완료');
      print('[디버그] _nodeMap 현재 상태: ${_dijkstraService.nodeMap.length}개 노드');
      // 시작/도착 노드 탐색
      final int? startNode = await _dijkstraService.findClosestNode(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
      );
      final region = await loader.getRegionFromLatLng(
        _currentLocation!.latitude,
       _currentLocation!.longitude,
      );

      final int? endNode = await _dijkstraService.findNearestShelterNodeId(
        _currentLocation!,
       region,
      );

      print('startNode: $startNode, endNode: $endNode');
      // 경로 탐색
      final List<int> pathNodeIds =
          await _dijkstraService.findShortestPath(startNode!, endNode!);

      print('pathNodeIds: $pathNodeIds');

      // ✅ 대피소와 같은 위치일 경우: 마커만 표시하고 안내 후 종료
      if (pathNodeIds.length <= 1) {
        setState(() {
          _path = []; // 경로는 없음
      });

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('알림림'),
      content: const Text('이미 대피소 근처입니다.'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('확인'),
        ),
      ],
    ),
  );
  return;
}

      final List<LatLng> pathLatLngs =
          await _dijkstraService.getLatLngListFromNodeIds(pathNodeIds);

      setState(() {
        _path = pathLatLngs;
      });
    } catch (e) {
      print('[에러 발생] 자동 내비게이션 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("자동 대피 경로 안내")),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: _currentLocation ?? const LatLng(36.5, 127.5),
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
            userAgentPackageName: 'com.example.app',
          ),
          if (_currentLocation != null)
            MarkerLayer(
              markers: [
                Marker(
                  point: _currentLocation!,
                  width: 40,
                  height: 40,
                  child: const Icon(
                    Icons.my_location,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          if (_path.length > 1)
            PolylineLayer(
              polylines: [
                Polyline(
                  points: _path,
                  strokeWidth: 4.0,
                  color: Colors.red,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
