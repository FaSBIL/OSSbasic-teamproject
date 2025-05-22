import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelter/map/user_marker.dart';

class ShelterOsmMap extends StatelessWidget {
  final MapController mapController;
  final LatLng initialCenter;
  final List<Marker> shelterMarkers;
  final LatLng? currentPosition;

  const ShelterOsmMap({
    Key? key,
    required this.mapController,
    required this.initialCenter,
    required this.shelterMarkers,
    this.currentPosition,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(initialCenter: initialCenter, initialZoom: 13),
      children: [
        TileLayer(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
          userAgentPackageName: 'com.example.shelter_map',
        ),
        MarkerLayer(
          markers: [
            if (currentPosition != null)
              Marker(
                point: currentPosition!,
                width: 60,
                height: 60,
                child: LocationMarker(size: 40, heading: 0.0),
              ),
            ...shelterMarkers,
          ],
        ),
      ],
    );
  }
}
