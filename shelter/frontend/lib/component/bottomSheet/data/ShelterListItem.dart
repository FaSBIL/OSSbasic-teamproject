import 'package:flutter/material.dart';
import 'package:shelter/theme/color.dart';
import 'package:shelter/theme/typography.dart';
import 'package:shelter/component/buttons/FavoriteButton.dart';
import 'package:shelter/component/buttons/NavButton.dart';
import 'package:shelter/component/icon/CustomIcon.dart';
import 'package:shelter/component/icon/IconUtils.dart';

class ShelterListItem extends StatelessWidget {
  final String title;
  final String address;
  final String distance;
  final bool isFavorite;
  final bool isTsunamiSafe;
  final bool isEarthquakeSafe;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;
  final VoidCallback onNavigatePressed;

  const ShelterListItem({
    super.key,
    required this.title,
    required this.address,
    required this.distance,
    required this.isFavorite,
    required this.isTsunamiSafe,
    required this.isEarthquakeSafe,
    required this.onTap,
    required this.onFavoriteToggle,
    required this.onNavigatePressed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text( title, style: AppTextStyles.subtitle),
              const SizedBox(height: 6),
              Text('$distance | $address', style: AppTextStyles.captionGray),
              const SizedBox(height: 14),
              Row(
                children: [
                  if(isTsunamiSafe) const CustomIcon( iconData: AppIcons.tsunami, color: AppColors.black),
                  if(isTsunamiSafe) const SizedBox(width: 8),
                  if(isEarthquakeSafe) const CustomIcon( iconData: AppIcons.earthquake, color: AppColors.black),
                  if(isEarthquakeSafe) const SizedBox(width: 8),
                  FavoriteButton(),
                  const SizedBox(width: 8),
                  NavButton(
                    text: '안내 시작',
                    onPressed: onNavigatePressed,
                  ),
                ],
              ),
            ],
          ),
          
        ],
      ),
    );
  }

} 