import 'package:flutter/material.dart';
import '../../theme/color.dart';
import '../icon/CustomIcon.dart';
import '../icon/IconUtils.dart';

class FavoriteButton extends StatefulWidget {
  final bool isFavorited; // 외부에서 즐겨찾기 상태 전달받음
  final VoidCallback onFavoriteToggle;

  const FavoriteButton({
    Key? key,
    required this.isFavorited,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton> {
  bool isFavorited = false;

  void _toggleFavorite() {
    setState(() {
      isFavorited = !isFavorited;
    });

    widget.onFavoriteToggle();
  }

  @override
  Widget build(BuildContext context) {
    return CustomIcon(
      iconData:
          widget.isFavorited ? AppIcons.star : AppIcons.starRound, // 외부 상태 반영
      color: AppColors.blue,
      backgroundColor: AppColors.paleBlue,
      borderColor: AppColors.paleBlue,
      onTap: _toggleFavorite,
      isClickable: true,
    );
  }
}
