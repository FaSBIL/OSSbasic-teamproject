import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:shelter/map/user_marker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/foundation.dart';

class ShelterMap extends StatefulWidget {
  final LatLng? currentPosition;
  final List<Marker> shelterMarkers;
  final MapController mapController;
  final void Function()? onMapTap;
  final void Function(LatLng latLng)? onShelterTap;
  final LatLng? initialCenter;

  const ShelterMap({
    super.key,
    required this.currentPosition,
    required this.shelterMarkers,
    required this.mapController,
    this.onMapTap,
    this.onShelterTap,
    this.initialCenter,
  });

  @override
  State<ShelterMap> createState() => _ShelterMapState();
}

class _ShelterMapState extends State<ShelterMap> {
  late final Future<MbTilesTileProvider> _tileProviderFuture;

  @override
  void initState() {
    super.initState();
    _tileProviderFuture = _loadTileProvider();
  }

  Future<MbTilesTileProvider> _loadTileProvider() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      // Android: 외부 저장소에서 로드
      final status = await Permission.storage.request();
      final dir = await getExternalStorageDirectory();
      if (dir == null) {
        print('[ERROR] 외부 저장소 디렉토리를 찾을 수 없습니다.');
        throw Exception("외부 저장소 디렉토리를 찾을 수 없습니다.");
      }

      final path = '${dir.path}/8_16kr-map.mbtiles';
      print('[DEBUG] 시도 중: $path');

      final file = File(path);
      if (!await file.exists()) {
        print('[ERROR] 파일이 존재하지 않습니다.');
        throw Exception("MBTiles 파일이 존재하지 않습니다: $path");
      }

      return MbTilesTileProvider.fromPath(path: file.path);
    } else if (defaultTargetPlatform == TargetPlatform.iOS) {
      // iOS: assets에서 내부 디렉토리로 복사 후 사용
      final data = await rootBundle.load('assets/mbtiles/8_16kr-map.mbtiles');
      final dir = await getApplicationDocumentsDirectory();
      final file = File('${dir.path}/8_16kr-map.mbtiles');

      if (!await file.exists()) {
        await file.writeAsBytes(data.buffer.asUint8List());
      }

      return MbTilesTileProvider.fromPath(path: file.path);
    } else {
      throw UnsupportedError('지원되지 않는 플랫폼입니다.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final LatLng fallback = LatLng(36.5, 127.5); // currentPosition 없을 때 기본 위치

    return FutureBuilder<MbTilesTileProvider>(
      future: _tileProviderFuture,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        return FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            initialCenter:
                widget.initialCenter ?? widget.currentPosition ?? fallback,
            initialZoom: 15.0,
            minZoom: 8.0,
            maxZoom: 16.0,
            onTap: (_, __) {
              if (context.mounted) {
                widget.onMapTap?.call();
              }
            },
          ),
          children: [
            TileLayer(
              tileProvider: snapshot.data!,
              userAgentPackageName: 'com.yourcompany.shelterapp',
            ),
            MarkerLayer(
              markers: [
                if (widget.currentPosition != null)
                  Marker(
                    point: widget.currentPosition!,
                    width: 40,
                    height: 40,
                    child: StreamBuilder<double?>(
                      stream: FlutterCompass.events!.map((e) => e.heading),
                      builder: (_, snapshot) {
                        final heading = snapshot.data ?? 0.0;
                        return LocationMarker(heading: heading, size: 40);
                      },
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
    _tileProviderFuture.then((p) => p.dispose());
    super.dispose();
  }
}
