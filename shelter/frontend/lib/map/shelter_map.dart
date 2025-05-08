import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelter/map/user_marker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_map_mbtiles/flutter_map_mbtiles.dart';
import 'package:flutter_compass/flutter_compass.dart';

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
  late final Future<MbTilesTileProvider> _tileProviderFuture;

  @override
  void initState() {
    super.initState();
    _tileProviderFuture = _loadTileProvider();
  }

  Future<MbTilesTileProvider> _loadTileProvider() async {
    // 1) Copy the MBTiles file out of assets
    final data = await rootBundle.load('assets/kr-map.mbtiles');
    final dir = await getApplicationSupportDirectory();
    final file = File('${dir.path}/kr-map.mbtiles');
    if (!await file.exists()) {
      await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
    }
    // 2) Create the tile provider with a named `path:` argument
    return await MbTilesTileProvider.fromPath(path: file.path);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.currentPosition == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return FutureBuilder<MbTilesTileProvider>(
      future: _tileProviderFuture,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError || !snap.hasData) {
          return Center(child: Text('타일 로드 오류: ${snap.error}'));
        }

        return FlutterMap(
          mapController: widget.mapController,
          options: MapOptions(
            // use the new initialCenter/initialZoom names
            initialCenter: widget.currentPosition!,
            initialZoom: 8.0,
            minZoom: 8.0,
            maxZoom: 14.0,
          ),
          children: [
            // Use the plain TileLayer with our MBTiles provider
            TileLayer(tileProvider: snap.data!, tms: true),

            // And your existing markers, but switch to `child:` instead of `builder:`
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
    // make sure to close the MBTiles DB
    _tileProviderFuture.then((p) => p.dispose());
    super.dispose();
  }
}
