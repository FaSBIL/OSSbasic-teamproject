import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelter/map/path_painter.dart'; // draw path on map 파일 import

class ShelterMapScreen extends StatelessWidget {
  final List<LatLng> pathPoints;

  const ShelterMapScreen({super.key, required this.pathPoints});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('대피 경로 안내')),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: pathPoints.isNotEmpty ? pathPoints.first : LatLng(36.5, 127.5),
          initialZoom: 15,
        ),
        children: [
          TileLayer(
            tileProvider: AssetTileProvider(),
            urlTemplate: 'assets/kr-map.mbtiles',
          ),
          PathLayer(path: pathPoints),
          MarkerLayer(
            markers: [
              Marker(
                width: 40,
                height: 40,
                point: pathPoints.first,
                child: const Icon(Icons.my_location, color: Colors.blue, size: 36),
              ),
              Marker(
                width: 40,
                height: 40,
                point: pathPoints.last,
                child: const Icon(Icons.flag, color: Colors.red, size: 36),
              ),
            ],
          )
        ],
      ),
    );
  }
}
