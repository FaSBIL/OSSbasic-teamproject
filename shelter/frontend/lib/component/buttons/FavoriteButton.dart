import 'package:flutter/material.dart';
import '../../theme/color.dart';
import '../icon/CustomIcon.dart';
import '../icon/IconUtils.dart';

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({
    Key? key
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
  }

  @override
  Widget build(BuildContext context) {
    return CustomIcon(
      iconData: isFavorited ? AppIcons.star : AppIcons.starRound,
      color: AppColors.blue,
      backgroundColor:  AppColors.paleBlue,
      borderColor: AppColors.paleBlue,
      onTap: _toggleFavorite,
      isClickable: true,
    );
  }
}
