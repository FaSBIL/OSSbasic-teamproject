import 'package:flutter/material.dart';
import 'package:shelter/services/filter_shelters.dart';
import 'package:shelter/models/shelter.dart';
import 'package:shelter/screens/search/search_map_screen.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelter/theme/color.dart';
import 'package:shelter/services/user_location.dart';

class SearchResultScreen extends StatefulWidget {
  final String keyword;

  const SearchResultScreen({super.key, required this.keyword});

  @override
  State<SearchResultScreen> createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final ShelterService _shelterService = ShelterService();
  List<Shelter> _results = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadResults();
  }

  Future<void> _loadResults() async {
    await _shelterService.initialize();
    final found = await _shelterService.searchShelters(widget.keyword);
    setState(() {
      _results = found;
      _isLoading = false;
    });
  }

  void _openMap(Shelter shelter) async {
    final position = await UserLocationService().getCurrentLocation();
    final currentLatLng = LatLng(position.latitude, position.longitude);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (_) => SearchMapScreen(
              region: shelter.address,
              shelters: [shelter],
              currentPosition: currentLatLng, // 현재 위치 전달
              selectedShelter: shelter,
            ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        title: Text('검색: "${widget.keyword}"'),
        backgroundColor: AppColors.white,
      ),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _results.isEmpty
              ? const Center(child: Text('검색 결과가 없습니다.'))
              : ListView.separated(
                itemCount: _results.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final shelter = _results[index];
                  return ListTile(
                    title: Text(shelter.name),
                    subtitle: Text(shelter.address),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openMap(shelter),
                  );
                },
              ),
    );
  }
}
