import 'package:flutter/material.dart';
import 'package:shelter/services/favorite_service.dart';

/// 테이블명을 자동 추출하는 유틸 함수
String getTableName(Map<String, dynamic> shelter) {
  final address = shelter['address'] ?? '';

  if (address.contains('서울')) return 'seoul';
  if (address.contains('부산')) return 'busan';
  if (address.contains('대전')) return 'daejeon';
  if (address.contains('광주')) return 'gwangju';
  if (address.contains('인천')) return 'incheon';
  if (address.contains('대구')) return 'daegu';
  if (address.contains('울산')) return 'ulsan';
  if (address.contains('세종')) return 'sejong';
  if (address.contains('경기')) return 'gyeonggi';
  if (address.contains('강원')) return 'gangwon';
  if (address.contains('충북')) return 'chungbuk';
  if (address.contains('충남')) return 'chungnam';
  if (address.contains('전북')) return 'jeonbuk';
  if (address.contains('전남')) return 'jeonnam';
  if (address.contains('경북')) return 'gyeongbuk';
  if (address.contains('경남')) return 'gyeongnam';
  if (address.contains('제주')) return 'jeju';

  return 'seoul'; // 기본값 (없을 경우)
}

Future<void> toggleFavoriteAndRefresh(
  BuildContext context,
  Map<String, dynamic> shelter,
  VoidCallback onUpdated,
) async {
  final tableName = getTableName(shelter);
  final name = shelter['name'];

  // 즐겨찾기 토글 → newValue(1 or 0)로 반환받기
  final newValue = await FavoriteService().toggleFavorite(tableName, name);

  // UI 업데이트
  onUpdated();

  // 사용자 피드백
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(newValue == 1 ? '즐겨찾기에 추가되었습니다.' : '즐겨찾기에서 제거되었습니다.'),
      duration: const Duration(seconds: 1),
    ),
  );
}
