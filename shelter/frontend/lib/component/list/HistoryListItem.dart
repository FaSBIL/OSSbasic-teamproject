import 'package:flutter/material.dart';
import './BaseListItem.dart';
import '../../theme/color.dart';
import '../../theme/typography.dart';
import '../icon/CustomIcon.dart';
import '../icon/IconUtils.dart';

class HistoryListItem extends StatelessWidget {
  final String title;
  final bool isFavorite;
  final VoidCallback? onTap;

  const HistoryListItem({
    Key? key,
    required this.title,
    this.isFavorite = false,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BaseListItem(
      leading: CustomIcon(
        iconData: isFavorite ? AppIcons.star : AppIcons.history,
        color: isFavorite ? AppColors.blue : AppColors.darkGray,
        backgroundColor: isFavorite ? AppColors.paleBlue : AppColors.lightGray,
        borderColor: isFavorite ? AppColors.paleBlue : AppColors.lightGray,
      ),
      title: Text(
        title,
        style: AppTextStyles.subtitle,
      )
    );
  }
}