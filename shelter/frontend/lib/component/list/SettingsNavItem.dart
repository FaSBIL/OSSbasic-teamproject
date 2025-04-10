import 'package:flutter/material.dart';
import './BaseListItem.dart';
import '../../theme/color.dart';
import '../../theme/typography.dart';
import '../icon/iconUtils.dart';

class SettingsNavItem extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const SettingsNavItem({
    Key? key,
    required this.label,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return BaseListItem(
      title: Text(
        label,
        style: AppTextStyles.subtitle,
      ),
      trailing: const Icon(
        AppIcons.arrowLeft,
        color: AppColors.darkGray,
        size: 20,
      ),
      onTap: onTap,
    );
  }
}