import 'package:flutter/material.dart';
import '../../theme/typography.dart';
import './BaseListItem.dart';

class EvacuationSiteItem extends StatelessWidget {
  final String title;
  final String address;
  final VoidCallback? onTap;

  const EvacuationSiteItem({
    Key? key,
    required this.title,
    required this.address,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context){
    return BaseListItem(
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