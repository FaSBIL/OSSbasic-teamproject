import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:shelter/models/shelter.dart';
import 'package:shelter/map/user_marker.dart';
import 'package:shelter/component/bottomSheet/ShelterBottomSheet.dart';
import 'package:shelter/component/bottomSheet/data/ShelterDetailView.dart';
import 'package:geolocator/geolocator.dart';

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

  @override
  void initState() {
    super.initState();
    _selectedShelter = widget.selectedShelter;
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

    return Scaffold(
      appBar: AppBar(title: Text('${widget.region} 대피소 지도')),
      body: Stack(
        children: [
          FlutterMap(
            options: MapOptions(
              initialCenter: center,
              initialZoom: _selectedShelter != null ? 16 : 13,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: ['a', 'b', 'c'],
              ),
              MarkerLayer(
                markers: [
                  if (_selectedShelter != null)
                    Marker(
                      width: 60,
                      height: 60,
                      point: LatLng(
                        _selectedShelter!.latitude,
                        _selectedShelter!.longitude,
                      ),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedShelter = _selectedShelter;
                          });
                        },
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 35,
                        ),
                      ),
                    ),

                  ...widget.shelters.map((shelter) {
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
                          color:
                              _selectedShelter == shelter
                                  ? Colors.red
                                  : Colors.green,
                          size: _selectedShelter == shelter ? 35 : 30,
                        ),
                      ),
                    );
                  }),

                  // 3. 현재 위치 마커
                  if (widget.currentPosition != null)
                    Marker(
                      width: 60,
                      height: 60,
                      point: widget.currentPosition!,
                      child: const LocationMarker(),
                    ),
                ],
              ),
            ],
          ),

          if (_selectedShelter != null && widget.currentPosition != null)
            ShelterBottomSheet(
              mode: SheetMode.detail,
              child: ShelterDetailView(
                shelters: {
                  'name': _selectedShelter!.name,
                  'address': _selectedShelter!.address,
                  'latitude': _selectedShelter!.latitude,
                  'longitude': _selectedShelter!.longitude,
                  'earthquake': _selectedShelter!.earthquakeSafe ? 1 : 0,
                  'tsunami': _selectedShelter!.tsunamiSafe ? 1 : 0,
                  'isFavorite': _selectedShelter!.isFavorite ? 1 : 0,
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
                onFavoriteToggle: (_) {},
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
              ),
            ),
        ],
      ),
    );
  }
}
