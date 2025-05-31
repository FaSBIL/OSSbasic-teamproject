import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelter/models/shelter.dart';
import 'package:shelter/map/user_marker.dart';
import 'package:shelter/component/bottomSheet/ShelterBottomSheet.dart';
import 'package:shelter/component/bottomSheet/data/ShelterDetailView.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shelter/map/shelter_map.dart';
import 'package:shelter/theme/color.dart';
import 'package:shelter/utils/favorite_utils.dart';
import 'package:provider/provider.dart';
import 'package:shelter/provider/favorite_provider.dart';

class SearchMapScreen extends StatefulWidget {
  final String region;
  final List<Shelter> shelters;
  final LatLng? currentPosition;
  final Shelter? selectedShelter;

  const SearchMapScreen({
    super.key,
    required this.region,
    this.shelters = const [],
    this.selectedShelter,
    this.currentPosition,
  });

  @override
  State<SearchMapScreen> createState() => _SearchMapScreenState();
}

class _SearchMapScreenState extends State<SearchMapScreen> {
  late Shelter? _selectedShelter;

  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _selectedShelter = widget.selectedShelter;
  }

  Color _getMarkerColor(Shelter shelter) {
    if (shelter.earthquakeSafe) return Colors.purple; // 지진
    if (shelter.tsunamiSafe) return Colors.green; // 해일
    if (!shelter.earthquakeSafe && !shelter.tsunamiSafe)
      return AppColors.blue; // 민방위
    return Colors.grey;
  }

  LatLng _calculateCenter() {
    if (_selectedShelter != null) {
      return LatLng(_selectedShelter!.latitude, _selectedShelter!.longitude);
    } else if (widget.shelters.isNotEmpty) {
      final avgLat =
          widget.shelters.map((s) => s.latitude).reduce((a, b) => a + b) /
          widget.shelters.length;
      final avgLng =
          widget.shelters.map((s) => s.longitude).reduce((a, b) => a + b) /
          widget.shelters.length;
      return LatLng(avgLat, avgLng);
    } else {
      return const LatLng(36.5, 127.5);
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _calculateCenter();

    final List<Marker> markers =
        widget.shelters.map((shelter) {
          return Marker(
            width: 60,
            height: 60,
            point: LatLng(shelter.latitude, shelter.longitude),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedShelter = shelter;
                });
              },
              child: Icon(
                Icons.location_on,
                color: _getMarkerColor(shelter),
                size: 30,
              ),
            ),
          );
        }).toList();

    if (_selectedShelter != null) {
      markers.add(
        Marker(
          width: 60,
          height: 60,
          point: LatLng(
            _selectedShelter!.latitude,
            _selectedShelter!.longitude,
          ),
          child: const Icon(Icons.location_on, color: AppColors.blue, size: 40),
        ),
      );
    }

    if (widget.currentPosition != null) {
      markers.add(
        Marker(
          width: 60,
          height: 60,
          point: widget.currentPosition!,
          child: const LocationMarker(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text('${widget.region} 대피소 지도')),
      body: Stack(
        children: [
          ShelterMap(
            currentPosition: widget.currentPosition,
            shelterMarkers: markers,
            mapController: _mapController,
            initialCenter: center,
          ),

          if (_selectedShelter != null && widget.currentPosition != null)
            ShelterBottomSheet(
              mode: SheetMode.detail,
              child: Builder(
                builder: (context) {
                  final favoriteProvider = context.watch<FavoriteProvider>();
                  final isFavorite = favoriteProvider.isFavorite(
                    _selectedShelter!.name,
                  );

                  return ShelterDetailView(
                    shelters: {
                      'name': _selectedShelter!.name,
                      'address': _selectedShelter!.address,
                      'latitude': _selectedShelter!.latitude,
                      'longitude': _selectedShelter!.longitude,
                      'earthquake': _selectedShelter!.earthquakeSafe ? 1 : 0,
                      'tsunami': _selectedShelter!.tsunamiSafe ? 1 : 0,
                      'isFavorite': isFavorite ? 1 : 0,
                    },
                    currentPosition: Position(
                      latitude: widget.currentPosition!.latitude,
                      longitude: widget.currentPosition!.longitude,
                      timestamp: DateTime.now(),
                      accuracy: 0,
                      altitude: 0,
                      heading: 0,
                      speed: 0,
                      speedAccuracy: 0,
                      altitudeAccuracy: 0,
                      headingAccuracy: 0,
                    ),
                    onFavoriteToggle: (shelterMap) async {
                      final provider = context.read<FavoriteProvider>();
                      final tableName = getTableName(shelterMap);
                      final name = _selectedShelter!.name;

                      await provider.toggleFavorite(tableName, name);

                      // 상태 갱신
                      setState(() {
                        _selectedShelter = _selectedShelter!.copyWith(
                          isFavorite: provider.isFavorite(name),
                        );
                      });

                      // 사용자 피드백
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            provider.isFavorite(name)
                                ? '즐겨찾기에 추가되었습니다.'
                                : '즐겨찾기에서 제거되었습니다.',
                          ),
                          duration: const Duration(seconds: 1),
                        ),
                      );
                    },
                    onNavigate: (_) {
                      Navigator.pushNamed(
                        context,
                        '/navigationPreview',
                        arguments: {
                          'start': widget.currentPosition,
                          'destination': LatLng(
                            _selectedShelter!.latitude,
                            _selectedShelter!.longitude,
                          ),
                        },
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
