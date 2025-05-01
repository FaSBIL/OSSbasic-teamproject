import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  // 싱글톤 패턴 구현
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  Future<Position> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // 위치 서비스가 활성화되어 있는지 확인
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('위치 서비스가 비활성화되어 있습니다.');
    }

    // 위치 권한 확인
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('위치 권한이 거부되었습니다.');
      }
    }

    // 영구적으로 권한이 거부된 경우
    if (permission == LocationPermission.deniedForever) {
      throw Exception('위치 권한이 영구적으로 거부되었습니다. 설정에서 권한을 허용해주세요.');
    }

    // 현재 위치 반환
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  Future<String> getNearestLocation(double latitude, double longitude) async {
    try {
      // JSON 파일 로드 (올바른 경로로 수정)
      final String response = await rootBundle.loadString(
        'lib/assets/user_locations/user_locations.json',
      );
      final List<dynamic> locations = json.decode(response);

      double minDistance = double.infinity;
      String nearestLocation = '';

      // 각 지역과의 거리 계산
      for (final location in locations) {
        final double locLat = location['latitude'];
        final double locLng = location['longitude'];
        final double distance = _calculateDistance(
          latitude,
          longitude,
          locLat,
          locLng,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearestLocation = location['do'];
        }
      }

      return nearestLocation;
    } catch (e) {
      throw Exception('지역명을 찾는 중 오류 발생: $e');
    }
  }

  double _calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    const double earthRadius = 6371; // 지구 반지름 (단위: km)
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a =
        sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * pi / 180;
  }
}
