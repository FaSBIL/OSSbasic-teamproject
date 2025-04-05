import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

/// 📌 지도 확대/축소 버튼 묶음 위젯
class ZoomControlButtons extends StatelessWidget {
  final MapController mapController; // 지도 컨트롤러

  const ZoomControlButtons({super.key, required this.mapController});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FloatingActionButton.small(
          heroTag: "zoomIn",
          onPressed: () {
            final camera = mapController.camera;
            mapController.move(
              camera.center,
              camera.zoom + 1, // 지도 확대
            );
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.add),
        ),
        const SizedBox(height: 10),
        FloatingActionButton.small(
          heroTag: "zoomOut",
          onPressed: () {
            final camera = mapController.camera;
            mapController.move(
              camera.center,
              camera.zoom - 1, // 지도 축소
            );
          },
          backgroundColor: Colors.white,
          child: const Icon(Icons.remove),
        ),
      ],
    );
  }
}
