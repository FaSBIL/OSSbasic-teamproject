import 'package:flutter/material.dart';
import 'package:shelter/utils/db_loader.dart'; // DB 복사 및 열기 함수가 정의된 파일

class ShelterListScreen extends StatefulWidget {
  const ShelterListScreen({super.key});

  @override
  State<ShelterListScreen> createState() => _ShelterListScreenState();
}

class _ShelterListScreenState extends State<ShelterListScreen> {
  List<Map<String, dynamic>> shelters = [];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // DB에서 서울 지역 shelter 데이터를 불러옴
  Future<void> loadData() async {
    try {
      final db = await loadDatabase('civilSheltersByRegion.db');
      final rows = await db.query('civil_seoul'); // 테이블명에 맞게 수정
      await db.close();

      setState(() {
        shelters = rows;
      });
    } catch (e) {
      print('❌ DB 로드 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('서울 대피소')),
      body:
          shelters.isEmpty
              ? const Center(child: CircularProgressIndicator())
              : ListView.builder(
                itemCount: shelters.length,
                itemBuilder: (context, index) {
                  final shelter = shelters[index];
                  return ListTile(
                    leading: const Icon(Icons.location_on),
                    title: Text(shelter['name'] ?? '이름 없음'),
                    subtitle: Text(
                      '위도: ${shelter['latitude']}, 경도: ${shelter['longitude']}',
                    ),
                  );
                },
              ),
    );
  }
}
