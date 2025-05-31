// lib/map/path_painter.dart
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class PathLayer extends StatelessWidget {
  final List<LatLng> path;

  const PathLayer({super.key, required this.path});

  @override
  Widget build(BuildContext context) {
    return PolylineLayer(
      polylines: [
        Polyline(
          points: path,
          strokeWidth: 5.0,
          color: Colors.blueAccent,
        ),
      ],
    );
  }
}
