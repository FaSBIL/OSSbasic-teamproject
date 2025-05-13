import 'package:geolocator/geolocator.dart';

class DistanceCalculator {
  // 현재 위치와 대상 위치 사이의 거리 계산
  static Future<String> calculateDistance(
    double currentLat,
    double currentLon,
    double destLat,
    double destLon
    ) async {
    try {
      double distanceInMeters = Geolocator.distanceBetween(
        currentLat,
        currentLon,
        destLat,
        destLon,
      );

      if (distanceInMeters >= 1000) {
        return '${(distanceInMeters / 1000).toStringAsFixed(1)} km';
      } else {
        return '${distanceInMeters.toInt()} m';
      }
    } catch (e) {
      print('Distance calculation error: $e');
      return 'Distance calculation failed';
    }
  }
}