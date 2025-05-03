import 'package:flutter/material.dart';
import 'package:shelter/map/shelter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelter/component/input/MainInput.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 지도
          const ShelterMap(
            currentPosition: LatLng(37.5665, 126.9780),
            shelterMarkers: [],
          ),

          //검색창
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: MainInput(
              onTap: () {
                // 검색 페이지로 이동하거나 검색 기능 실행
                print('검색창 선택됨');
              },
              searchText: '', // 또는 최근 검색어, 상태값 등
            ),
          ),

          // 현재 위치 버튼
          Positioned(
            bottom: 24,
            right: 16,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: Colors.white,
              onPressed: () {
                // 현재 위치 이동 기능
              },
              child: const Icon(Icons.my_location, color: Colors.black),
            ),
          ),
        ],
      ),
    );
  }
}
