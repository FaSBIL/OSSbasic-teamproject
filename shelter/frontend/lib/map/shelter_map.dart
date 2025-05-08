import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelter/map/user_marker.dart';
import 'package:flutter_compass/flutter_compass.dart';

class ShelterMap extends StatelessWidget {
  final LatLng? currentPosition;
  final List<Marker> shelterMarkers;
  final MapController mapController;

  const ShelterMap({
    super.key,
    required this.currentPosition,
    required this.shelterMarkers,
    required this.mapController,
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
      mapController: mapController,
      options: MapOptions(
        initialCenter: currentPosition!,
        initialZoom: 17.0,
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
              width: 80,
              height: 80,
              point: currentPosition!,
              child: StreamBuilder<double?>(
                stream: FlutterCompass.events!.map((event) => event.heading),
                builder: (context, snapshot) {
                  final heading = snapshot.data ?? 0.0;
                  return LocationMarker(
                    heading: heading, // 회전 각도
                    size: 40,
                  );
                },
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
