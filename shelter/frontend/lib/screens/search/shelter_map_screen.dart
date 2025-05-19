import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelter/models/shelter.dart';
import 'package:shelter/map/user_marker.dart';

class ShelterMapScreen extends StatelessWidget {
  final String region;
  final List<Shelter> shelters;
  final LatLng? currentPosition;

  // ✅ 추가: 검색 결과인지 여부
  final bool isSingleResult;

  const ShelterMapScreen({
    super.key,
    required this.region,
    required this.shelters,
    this.currentPosition,
    this.isSingleResult = false, // 기본은 false
  });

  LatLng _calculateCenter(List<Shelter> shelters) {
    final avgLat =
        shelters.map((s) => s.latitude).reduce((a, b) => a + b) /
        shelters.length;
    final avgLng =
        shelters.map((s) => s.longitude).reduce((a, b) => a + b) /
        shelters.length;
    return LatLng(avgLat, avgLng);
  }

  @override
  Widget build(BuildContext context) {
    final center =
        (shelters.isNotEmpty)
            ? _calculateCenter(shelters)
            : const LatLng(36.5, 127.5);

    return Scaffold(
      appBar: AppBar(title: Text('$region 대피소 지도')),
      body: FlutterMap(
        options: MapOptions(initialCenter: center, initialZoom: 13),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayer(
            markers: [
              if (currentPosition != null)
                Marker(
                  width: 60,
                  height: 60,
                  point: currentPosition!,
                  child: const LocationMarker(),
                ),

              ...shelters.map((shelter) {
                return Marker(
                  width: 60,
                  height: 60,
                  point: LatLng(shelter.latitude, shelter.longitude),
                  child: Tooltip(
                    message: '${shelter.name}\n${shelter.type ?? ''}',
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.green,
                      size: 30,
                    ),
                  ),
                );
              }).toList(),
            ],
          ),
        ],
      ),
    );
  }
}
