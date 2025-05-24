import 'package:flutter/material.dart';
import '../../theme/color.dart';
import '../icon/CustomIcon.dart';
import '../icon/IconUtils.dart';

class FavoriteButton extends StatefulWidget {
  final VoidCallback onFavoriteToggle;

  const FavoriteButton({
    Key? key,
    required this.onFavoriteToggle,
  }) : super(key: key);

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>{
  bool isFavorited = false;
  
  void _toggleFavorite(){
    setState((){
      isFavorited = !isFavorited;
    });

    widget.onFavoriteToggle();
  }

  @override
  Widget build(BuildContext context) {
    return CustomIcon(
      iconData: isFavorited ? AppIcons.star : AppIcons.starRound,
      color: AppColors.blue(context),
      backgroundColor:  AppColors.paleBlue(context),
      borderColor: AppColors.paleBlue(context),
      onTap: _toggleFavorite,
      isClickable: true,
    );
  }
}
