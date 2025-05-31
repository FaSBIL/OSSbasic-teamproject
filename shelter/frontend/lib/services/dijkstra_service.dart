import 'dart:convert';
import 'package:collection/collection.dart';
import 'package:latlong2/latlong.dart';
import 'package:sqflite/sqlite_api.dart';
import 'package:sqflite/sqflite.dart';
import '../utils/db_loader.dart' as loader;
import '../services/filter_shelters.dart';

class DijkstraService {
  late Map<int, LatLng> _nodeMap;
  late Map<int, List<Map<String, num>>> _edgeMap;
  late final ShelterService _shelterService = ShelterService();
  bool _initialized = false;

  Future<void> loadRegionData(double lat, double lon) async {
    final region = await loader.getRegionFromLatLng(lat, lon); // 예: 'chungbuk'
    final db = await loader.loadRegionDatabase(region);

    final List<Map<String, dynamic>> allEdgesData = [];
    const chunkSize = 900; // SQLite에서 안전한 범위

    final nodesData = await db.query(
     'nodes',
      where: 'lat BETWEEN ? AND ? AND lon BETWEEN ? AND ?',
     whereArgs: [lat - 0.02, lat + 0.02, lon - 0.02, lon + 0.02],
    );

    final nodeIds = nodesData.map((row) => row['id'] as int).toList();

    if (nodeIds.isEmpty) {
      throw Exception('[오류] 조건에 맞는 노드가 없습니다.');
    }

    for (int i = 0; i < nodeIds.length; i += chunkSize) {
      final chunk = nodeIds.sublist(
        i,
        (i + chunkSize > nodeIds.length) ? nodeIds.length : i + chunkSize,
     );

      final chunkEdges = await db.query(
       'edges',
       where: 'from_id IN (${List.filled(chunk.length, '?').join(',')})',
       whereArgs: chunk,
      );

      print('[DEBUG] chunkEdges.length (${i ~/ chunkSize}): ${chunkEdges.length}');
      if (chunkEdges.isNotEmpty) print('[DEBUG] 예시: ${chunkEdges.first}');

  allEdgesData.addAll(chunkEdges);
}

    _nodeMap = {
    for (var row in nodesData)
    row['id'] as int: LatLng(
      (row['lat'] as num).toDouble(),
      (row['lon'] as num).toDouble(),
    ),
};

    _edgeMap = {};
    for (var row in allEdgesData) {
      final from = row['from_id'] as int;
      final to = row['to_id'] as int;
      final weight = row['distance'] as num;
      _edgeMap.putIfAbsent(from, () => []).add({'to': to, 'weight': weight});
    }
      print('[DEBUG] 노드 수: ${_nodeMap.length}');
      print('[DEBUG] 엣지 수: ${_edgeMap.length}');
    _initialized = true;
  }

  void _ensureInitialized() {
    if (!_initialized) {
      throw Exception('[DijkstraService] loadRegionData() must be called before using this method.');
    }
  }

  Future<int?> findClosestNode(double lat, double lon) async {
    _ensureInitialized();
    if (!_initialized) {
    throw Exception('[DijkstraService] loadRegionData() must be called before using findClosestNode().');
  }
    print('[DEBUG] findClosestNode 호출됨: 입력 위치 → lat: $lat, lon: $lon');
    double minDist = double.infinity;
    int? closestId;

    final Distance distance = const Distance();
    for (final entry in _nodeMap.entries) {
      final d = distance.as(LengthUnit.Meter, entry.value, LatLng(lat, lon));
      if (d < minDist) {
        minDist = d;
        closestId = entry.key;
      }
    }

    print('[DEBUG] 가장 가까운 노드 ID: $closestId (거리: $minDist m)');
    return closestId;
  }

  Future<List<int>> findShortestPath(int start, int end) async {
    _ensureInitialized();
    if (!_initialized) {
    throw Exception('[DijkstraService] loadRegionData() must be called before using findClosestNode().');
  }
    final dist = <int, double>{};
    final prev = <int, int?>{};
    final visited = <int>{};
    final queue = <int>[];

    for (final node in _nodeMap.keys) {
      dist[node] = double.infinity;
      prev[node] = null;
    }
    dist[start] = 0;
    queue.add(start);

    while (queue.isNotEmpty) {
      queue.sort((a, b) => dist[a]!.compareTo(dist[b]!));
      final current = queue.removeAt(0);
      if (current == end) break;
      if (visited.contains(current)) continue;

      visited.add(current);

      for (final neighbor in _edgeMap[current] ?? []) {
        final next = neighbor['to'] as int;
        final weight = neighbor['weight'] as num;
        final alt = dist[current]! + weight;
        if (alt < dist[next]!) {
          dist[next] = alt;
          prev[next] = current;
          queue.add(next);
        }
      }
    }

    final path = <int>[];
    int? u = end;
    while (u != null) {
      path.insert(0, u);
      u = prev[u];
    }
    return path;
  }

  Future<List<LatLng>> getLatLngListFromNodeIds(List<int> nodeIds) async {
    _ensureInitialized();
    if (!_initialized) {
    throw Exception('[DijkstraService] loadRegionData() must be called before using findClosestNode().');
  }
    return nodeIds.map((id) => _nodeMap[id]!).toList();
  }
  
  Future<LatLng?> findNearestShelter(LatLng currentLocation, String region) async {
    _ensureInitialized();

    await _shelterService.initialize(); // 초기화
    final shelter = await _shelterService.findNearestShelter(
      currentLocation.latitude,
      currentLocation.longitude,
      region,
    );
    
    if (!_initialized) {
    throw Exception('[DijkstraService] loadRegionData() must be called before using findClosestNode().');
  }
  if (_nodeMap.isEmpty) {
    print('[오류] _nodeMap이 비어 있습니다.');
    return null;
  }
  // 1. 현재 지역 내 모든 대피소 가져오기
  final shelterList = await _shelterService.getAllShelters(region);

  if (shelterList.isEmpty) {
    print('[오류] 지역 $region 내 대피소가 없습니다.');
    return null;
  } 

  // 2. 대피소 위경도와 nodeMap의 노드들 간 거리 계산 → 가장 가까운 노드 ID 선택
  final Distance distance = const Distance();
  double minDist = double.infinity;
  int? closestShelterNodeId;
  LatLng? closestShelterLatLng;

  for (final shelter in shelterList) {
  final shelterLatLng = LatLng(shelter.latitude, shelter.longitude);


  // shelter 위치와 가장 가까운 노드 찾기
    for (final entry in _nodeMap.entries) {
      final d = distance.as(LengthUnit.Meter, entry.value, shelterLatLng);
      if (d < minDist) {
        minDist = d;
        closestShelterNodeId = entry.key;
        closestShelterLatLng = entry.value;
      }
    }
  }
  if (closestShelterNodeId == null) {
    print('[오류] 대피소에 해당하는 노드를 찾을 수 없습니다.');
    return null;
  }
/*
  for (var entry in _nodeMap.entries) {
    final distance = Distance().as(
      LengthUnit.Meter,
      currentLocation,
      entry.value,
    );
    if (distance < minDist) {
      minDist = distance;
      closestNodeId = entry.key;
    }
  }

  if (closestNodeId != null) {
    return _nodeMap[closestNodeId];
  }
*/
  print('[DEBUG] 가장 가까운 대피소 노드 ID: $closestShelterNodeId (거리: $minDist m)');
  return closestShelterLatLng;
}
Future<int?> findNearestShelterNodeId(LatLng currentLocation, String region) async {
  _ensureInitialized();

  await _shelterService.initialize();
  final shelter = await _shelterService.findNearestShelter(
    currentLocation.latitude,
    currentLocation.longitude,
    region,
  );

  if (shelter == null) {
    print('[오류] 지역 $region 내에서 대피소를 찾지 못했습니다.');
    return null;
  }

  final shelterLatLng = LatLng(shelter.latitude, shelter.longitude);

  if (_nodeMap.isEmpty) {
    print('[오류] _nodeMap이 비어 있습니다.');
    return null;
  }

  double minDist = double.infinity;
  int? closestNodeId;

  final distance = const Distance();
  for (final entry in _nodeMap.entries) {
    final d = distance.as(LengthUnit.Meter, entry.value, shelterLatLng);
    if (d < minDist) {
      minDist = d;
      closestNodeId = entry.key;
    }
  }

  print('[DEBUG] 대피소 위치와 가장 가까운 노드 ID: $closestNodeId (거리: $minDist m)');
  return closestNodeId;
}
Map<int, LatLng> get nodeMap => _nodeMap;
}
