import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class ShelterMap extends StatelessWidget {
  final LatLng? currentPosition;
  final List<Marker> shelterMarkers;

  const ShelterMap({
    super.key,
    required this.currentPosition,
    required this.shelterMarkers,
  });

  @override
  Widget build(BuildContext context) {
    if (currentPosition == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 10),
            Text('현재 위치를 가져오는 중...'),
          ],
        ),
      );
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: currentPosition!,
        initialZoom: 14.0,
        minZoom: 10.0,
        maxZoom: 18.0,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.shelter',
        ),
        MarkerLayer(
          markers: [
            Marker(
              width: 80.0,
              height: 80.0,
              point: currentPosition!,
              child: const Icon(
                Icons.my_location,
                color: Colors.redAccent,
                size: 35,
              ),
              key: const Key('current_location'),
            ),
            ...shelterMarkers,
          ],
        ),
      ],
    );
  }
}
