import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class NavigationScreen extends StatelessWidget {
  final LatLng start;
  final LatLng destination;

  const NavigationScreen({
    super.key,
    required this.start,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('실시간 길 안내')),
      body: Center(
        child: Text(
          '길 안내 기능은 추후 구현 할 예정.\n\n출발지: ${start.latitude}, ${start.longitude}\n도착지: ${destination.latitude}, ${destination.longitude}',
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
