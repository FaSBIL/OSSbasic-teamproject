import 'package:flutter/material.dart';
import '../list/BaseListItem.dart';
import '../../theme/color.dart';
import '../../theme/typography.dart';
import '../icon/IconUtils.dart';

class ThemeModeItem extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ThemeModeItem({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return BaseListItem(
      title: Text(
        label,
        style: AppTextStyles.subtitle,
      ),
      trailing: SizedBox(
        width: 24,
        height: 24,
        child: isSelected
        ? Icon(AppIcons.check, color: AppColors.blue) : const SizedBox.shrink(),
      ),
      onTap: onTap,
    );
  }
}