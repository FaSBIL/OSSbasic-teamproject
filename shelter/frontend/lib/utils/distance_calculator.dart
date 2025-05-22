import 'package:geolocator/geolocator.dart';

class DistanceCalculator {
  // 거리만 계산
  static Future<String> calculateDistance(
    double currentLat,
    double currentLon,
    double destLat,
    double destLon,
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

  // 거리 + 시간 같이 계산
  static Future<String> calculateDistanceWithTime(
    double currentLat,
    double currentLon,
    double destLat,
    double destLon,
  ) async {
    try {
      final distanceInMeters = Geolocator.distanceBetween(
        currentLat,
        currentLon,
        destLat,
        destLon,
      );

      final distanceStr =
          distanceInMeters >= 1000
              ? '${(distanceInMeters / 1000).toStringAsFixed(1)} km'
              : '${distanceInMeters.toInt()} m';

      final timeStr = estimateWalkingTime(distanceInMeters);

      return '$distanceStr (약 $timeStr)';
    } catch (e) {
      print('Distance calculation error: $e');
      return '거리 계산 실패';
    }
  }

  static String estimateWalkingTime(double distanceInMeters) {
    final minutes = distanceInMeters / 66.6;
    if (minutes < 1.5) return '1분 미만';
    if (minutes < 60) return '${minutes.round()}분';
    final hours = (minutes / 60).floor();
    final remaining = (minutes % 60).round();
    return '$hours시간 $remaining분';
  }
}
