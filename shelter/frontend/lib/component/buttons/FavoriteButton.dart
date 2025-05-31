import 'package:flutter/material.dart';
import '../../theme/color.dart';
import '../icon/CustomIcon.dart';
import '../icon/IconUtils.dart';

class FavoriteButton extends StatelessWidget {
  final bool isFavorited; // 외부에서 즐겨찾기 상태 전달받음
  final VoidCallback onFavoriteToggle;

  const FavoriteButton({
    Key? key,
    required this.isFavorited,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomIcon(
      iconData: isFavorited ? AppIcons.star : AppIcons.starRound,
      color: AppColors.blue,
      backgroundColor: AppColors.paleBlue,
      borderColor: AppColors.paleBlue,
      onTap: onFavoriteToggle,
      isClickable: true,
    );
  }
}
