import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/user_location.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final UserLocationService _locationService = UserLocationService();
  Position? _currentPosition;
  String _errorMessage = '';
  String _nearestLocation = ''; // 가장 가까운 지역명 저장
  String _nearestCity = ''; // 가장 가까운 도시명 저장

  Future<void> _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentLocation();
      final nearestLocationData = await _locationService.getNearestLocation(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _currentPosition = position;
        _nearestLocation = nearestLocationData['do'] ?? '';
        _nearestCity = nearestLocationData['city'] ?? '';
        _errorMessage = '';
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('위치 정보')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_currentPosition != null) ...[
              Text('위도: ${_currentPosition!.latitude}'),
              Text('경도: ${_currentPosition!.longitude}'),
              Text('현재 지역: $_nearestLocation'), // 지역명 표시
              Text('시/군/구: $_nearestCity'),
            ],
            if (_errorMessage.isNotEmpty)
              Text(_errorMessage, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _getCurrentLocation,
              child: const Text('현재 위치 가져오기'),
            ),
          ],
        ),
      ),
    );
  }
}
