import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:shelter/map/location_marker.dart';

class ShelterMap extends StatefulWidget {
  final LatLng? currentPosition;
  final List<Marker> shelterMarkers;
  final MapController mapController;

  const ShelterMap({
    Key? key,
    required this.currentPosition,
    required this.shelterMarkers,
    required this.mapController,
  }) : super(key: key);

  @override
  State<ShelterMap> createState() => _ShelterMapState();
}

class _ShelterMapState extends State<ShelterMap> {
  late final Future<MbTilesTileProvider> _providerFuture;

  @override
  void initState() {
    super.initState();
    _providerFuture = _loadTileProvider();
  }

  Future<MbTilesTileProvider> _loadTileProvider() async {
    // 앱 전용 외부 저장소 경로 가져오기
    final dir = await getExternalStorageDirectory();
    if (dir == null) {
      throw '앱 전용 외부 저장소 경로를 찾을 수 없습니다.';
    }

    // mbtiles 파일 위치: files 폴더 밑에 저장된 파일명
    final mbtilesPath = '${dir.path}/8_16kr-map.mbtiles';
    final mbtilesFile = File(mbtilesPath);
    if (!await mbtilesFile.exists()) {
      throw '파일이 없습니다: $mbtilesPath';
    }

    // TileProvider 생성
    return await MbTilesTileProvider.fromPath(path: mbtilesPath);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<MbTilesTileProvider>(
      future: _providerFuture,
      builder: (ctx, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(child: Text('타일 로드 오류: ${snap.error}'));
        }

        final provider = snap.data!;
        return FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            // 초기 중심 및 줌 설정
            initialCenter: widget.currentPosition!,
            initialZoom: 8.0,
            minZoom: 8.0,
            maxZoom: 16.0,
          ),
          children: [
            TileLayer(
              tileProvider: provider,
              tms: true,
              minZoom: 8,
              maxZoom: 16,
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: widget.currentPosition!,
                  width: 40,
                  height: 40,
                  child: StreamBuilder<double?>(
                    stream: FlutterCompass.events!.map((e) => e.heading),
                    builder:
                        (_, s) =>
                            LocationMarker(heading: s.data ?? 0.0, size: 40),
                  ),
                ),
                ...widget.shelterMarkers,
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _providerFuture.then((p) => p.dispose());
    super.dispose();
  }
}
