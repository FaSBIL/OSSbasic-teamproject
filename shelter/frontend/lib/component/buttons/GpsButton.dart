import 'package:flutter/material.dart';
import '../../theme/color.dart';

class GpsButton extends StatelessWidget {
  const GpsButton({
    Key? key
    }): super(key: key);

  void _handleGpsPress(){
    // 현재 위치를 중심으로 지도를 이동하는 로직 구현 에정
  }

  @override
  Widget build(BuildContext context){
    return Material(
      elevation: 1.5,
      shape: const CircleBorder(),
      color: AppColors.white,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: _handleGpsPress,
        child: Padding (
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
