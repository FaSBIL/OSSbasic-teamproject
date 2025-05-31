import 'package:flutter/material.dart';
import 'package:shelter/theme/color.dart';
import 'package:shelter/component/icon/CustomIcon.dart';
import 'package:shelter/component/icon/IconUtils.dart';

class FavoriteIconStatic extends StatelessWidget {
  const FavoriteIconStatic({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomIcon(
      iconData: AppIcons.star,
      color: AppColors.blue,
      backgroundColor: AppColors.paleBlue,
      borderColor: AppColors.paleBlue,
      isClickable: false,
      onTap: null,
    );
  }
}
