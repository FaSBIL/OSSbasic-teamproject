import 'dart:math';
import 'package:flutter/material.dart';

class LocationMarker extends StatelessWidget {
  final double size;
  final double heading;

  const LocationMarker({super.key, this.size = 40.0, this.heading = 0.0});

  @override
  Widget build(BuildContext context) {
    final double rotation = heading * (pi / 180); // 라디안 변환

    return Stack(
      alignment: Alignment.center,
      children: [
        // 위치 정확도 원
        Container(
          width: size * 1.6,
          height: size * 1.6,
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.15),
            shape: BoxShape.circle,
          ),
        ),

        // 방향 표시 (부채꼴)
        Transform.rotate(
          angle: rotation,
          alignment: Alignment.center,
          child: ClipPath(
            clipper: _ConeClipper(),
            child: Container(
              width: size * 1.6,
              height: size * 1.6,
              decoration: BoxDecoration(color: Colors.blue.withOpacity(0.25)),
            ),
          ),
        ),

        // 흰색 테두리 원
        Container(
          width: size * 0.7,
          height: size * 0.7,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
          ),
        ),

        // 파란색 내부 점
        Container(
          width: size * 0.5,
          height: size * 0.5,
          decoration: const BoxDecoration(
            shape: BoxShape.circle,
            color: Color(0xFF0060C7),
          ),
        ),
      ],
    );
  }
}

// 부채꼴(파이 모양)
class _ConeClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    const sweepAngle = pi / 3; // 60도
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    path.moveTo(center.dx, center.dy);
    path.arcTo(
      Rect.fromCircle(center: center, radius: radius),
      -sweepAngle / 2,
      sweepAngle,
      false,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
