import 'package:flutter/material.dart';
import './BaseListItem.dart';
import '../../theme/color.dart';
import '../../theme/typography.dart';
import '../icon/iconUtils.dart';
import '../icon/customIcon.dart';

class FavoriteListItem extends StatelessWidget {
  final String title;
  final String address;
  final VoidCallback? onTap;

  const FavoriteListItem({
    Key? key,
    required this.title,
    required this.address,
    this. onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return BaseListItem(
      leading: CustomIcon(
        iconData: AppIcons.starRound,
        backgroundColor: AppColors.paleBlue,
        color: AppColors.blue,
        borderColor: AppColors.paleBlue,
      ),
      title: Text(
        title,
        style: AppTextStyles.subtitle,
      ),
      subtitle: Text(
        address,
        style: AppTextStyles.bodyGray,
      ),
      onTap: onTap,
    );
  }
}