import 'package:flutter/material.dart';
import './BaseListItem.dart';
import '../../theme/color.dart';
import '../../theme/typography.dart';

class ConfigItem extends StatelessWidget {
  final String label;
  final String value;

  const ConfigItem({
    Key? key,
    required this.label,
    required this.value,
  }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return BaseListItem(
      title: Text(
        label,
        style: AppTextStyles.subtitle,
      ),
      trailing: Text(
        value,
        style: AppTextStyles.subtitle.copyWith(color: AppColors.darkGray),
      ),
    );
  }
}