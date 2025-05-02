import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import '../../services/location_service.dart';

class Mapbox extends StatefulWidget {
  final double latitude;
  final double longitude;
  final double zoom;

  const Mapbox({
    super.key,
    required this.latitude,
    required this.longitude,
    this.zoom = 14.0,
  });

  @override
  State<Mapbox> createState() => MapboxState();
}

class MapboxState extends State<Mapbox> {
  MapboxMap? mapboxMap;

  //현재 위치로 이동하는 함수
  void moveToCurrentLocation() async {
    try {
      final position = await LocationService().getCurrentLocation();

      await mapboxMap?.setCamera(
        CameraOptions(
          center: Point(
            coordinates: Position.named(
              lat: position.latitude,
              lng: position.longitude,
            ),
          ),
          zoom: 15.0,
        ),
      );

      print('현재 위치로 이동 완료');
    } catch (e) {
      print('위치 정보를 가져올 수 없습니다: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MapWidget(
      key: const ValueKey("mapWidget"),
      cameraOptions: CameraOptions(
        center: Point(
          coordinates: Position.named(
            lng: widget.longitude,
            lat: widget.latitude,
          ),
        ),
        zoom: widget.zoom,
      ),
      styleUri: 'mapbox://styles/rrreerrr/cma5lpaxg005y01spbmoyaegv',
      onMapCreated: (map) {
        mapboxMap = map;
        print(' MapboxMap 생성됨!'); // 테스트 로그
      },
    );
  }
}
