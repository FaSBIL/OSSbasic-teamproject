import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelter/map/shelter_map_screen.dart'; // 지도를 띄울 위젯
import 'package:shelter/services/dijkstra_service.dart'; // 다익스트라 구현한 서비스
import '../utils/db_loader.dart';

class NavigationStarter {
  final DijkstraService dijkstraService;

  NavigationStarter(this.dijkstraService);

  Future<void> navigateToShelter(
  BuildContext context,
  LatLng currentLocation,
  LatLng destinationLocation,
) async {
  final int? startNode = await dijkstraService.findClosestNode(
    currentLocation.latitude,
    currentLocation.longitude,
  );
  final int? endNode = await dijkstraService.findClosestNode(
    destinationLocation.latitude,
    destinationLocation.longitude,
  );

  if (startNode == null || endNode == null) {
    print('❌ 노드 탐색 실패');
    return;
  }

  final List<int> pathNodeIds =
      await dijkstraService.findShortestPath(startNode, endNode);

  final List<LatLng> pathPoints =
      await dijkstraService.getLatLngListFromNodeIds(pathNodeIds);

  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ShelterMapScreen(pathPoints: pathPoints),
    ),
  );
}

}
