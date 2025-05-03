import 'package:flutter/material.dart';
import '../../theme/color.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../services/user_location.dart';
import 'package:latlong2/latlong.dart';

class GpsButton extends StatelessWidget {
  final MapController mapController;
  const GpsButton({Key? key, required this.mapController}) : super(key: key);

  void _handleGpsPress() async {
    final locationService = UserLocationService();
    final position = await locationService.getCurrentLocation();
    final latLng = LatLng(position.latitude, position.longitude);

    mapController.move(latLng, 17.0);
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 1.5,
      shape: const CircleBorder(),
      color: AppColors.white,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _handleGpsPress,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Icon(
            Icons.my_location,
            color: AppColors.lightBlue,
            size: 24.0,
          ),
        ),
      ),
    );
  }
}
