import 'dart:math';
import 'package:latlong2/latlong.dart';
import 'package:flutter/widgets.dart';

/// 두 벡터 (a→b, b→c) 사이의 각도를 계산해 반환
/// 반환값은 -180도 ~ 180도 사이이며, 음수면 우회전, 양수면 좌회전
double calculateAngleBetweenPoints(LatLng a, LatLng b, LatLng c) {
  final ab = _vectorFrom(a, b);
  final bc = _vectorFrom(b, c);

  final dotProduct = ab.dx * bc.dx + ab.dy * bc.dy;
  final crossProduct = ab.dx * bc.dy - ab.dy * bc.dx;

  final angle = atan2(crossProduct, dotProduct) * (180 / pi);
  return angle; // +: 좌회전, -: 우회전
}

/// 주어진 각도(angle)에 따라 방향을 문자열로 반환
/// 예: "좌회전", "우회전", "직진"
String getTurnDirection(double angle, {double threshold = 30}) {
  if (angle.abs() > 135) return '뒤로 돌아가세요';
  if (angle.abs() < threshold) return '직진';
  return angle > 0 ? '좌회전' : '우회전';
}

/// LatLng 두 점을 입력받아 Offset 벡터로 변환
Offset _vectorFrom(LatLng from, LatLng to) {
  return Offset(to.longitude - from.longitude, to.latitude - from.latitude);
}

class GuidancePoint {
  final LatLng position;
  final String message;
  bool announced;
  Set<int> distanceAnnounced = {};
  GuidancePoint({
    required this.position,
    required this.message,
    this.announced = false,
  });
}

/// 경로(path)를 분석해서 회전 지점을 찾고 안내 메시지 생성
List<GuidancePoint> extractGuidancePoints(List<LatLng> path) {
  List<GuidancePoint> points = [];

  for (int i = 0; i < path.length - 2; i++) {
    final a = path[i];
    final b = path[i + 1];
    final c = path[i + 2];

    final angle = calculateAngleBetweenPoints(a, b, c);
    final direction = getTurnDirection(angle);

    if (direction != '직진') {
      points.add(
        GuidancePoint(position: b, message: '10미터 앞에서 $direction입니다.'),
      );
    }
  }

  if (path.isNotEmpty) {
    points.add(GuidancePoint(position: path.last, message: '목적지에 도착했습니다.'));
  }

  return points;
}

List<GuidancePoint> extractGuidancePointsFromNodePath(
  List<int> nodePath,
  Map<int, LatLng> nodeMap,
) {
  List<GuidancePoint> points = [];

  for (int i = 0; i < nodePath.length - 2; i++) {
    final a = nodeMap[nodePath[i]]!;
    final b = nodeMap[nodePath[i + 1]]!;
    final c = nodeMap[nodePath[i + 2]]!;

    final angle = calculateAngleBetweenPoints(a, b, c);
    final direction = getTurnDirection(angle);

    if (direction != '직진') {
      points.add(
        GuidancePoint(position: b, message: '10미터 앞에서 $direction입니다.'),
      );
    }
  }

  if (nodePath.isNotEmpty) {
    final last = nodeMap[nodePath.last]!;
    points.add(GuidancePoint(position: last, message: '목적지에 도착했습니다.'));
  }

  return points;
}

double calculateBearing(LatLng from, LatLng to) {
  final lat1 = from.latitude * pi / 180;
  final lat2 = to.latitude * pi / 180;
  final dLon = (to.longitude - from.longitude) * pi / 180;

  final y = sin(dLon) * cos(lat2);
  final x = cos(lat1) * sin(lat2) - sin(lat1) * cos(lat2) * cos(dLon);
  final bearing = atan2(y, x) * 180 / pi;
  return (bearing + 360) % 360;
}

/// 사용자 heading과 경로 bearing 차이를 바탕으로 회전 방향을 알려주는 함수
String getTurnInstruction(double userHeading, double pathBearing) {
  final diff = (userHeading - pathBearing + 360) % 360;
  if (diff > 180) {
    return diff < 225 ? '좌회전하세요' : '뒤로 돌아가세요';
  } else {
    return diff > 135 ? '우회전하세요' : '직진하세요';
  }
}
