import 'package:flutter/material.dart';
import '../../theme/color.dart';
import '../../theme/typography.dart';
import '../icon/IconUtils.dart';

class MainInput extends StatelessWidget {
  final VoidCallback onTap;
  final VoidCallback? onMenuTap;
  final String searchText;

  const MainInput({
    Key? key,
    required this.onTap,
    this.onMenuTap,
    this.searchText = '',
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onMenuTap,
              child: Icon(AppIcons.menu, color: AppColors.darkGray),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                searchText.isEmpty ? '대파소 검색' : searchText,
                style: AppTextStyles.body.copyWith(
                  color: searchText.isEmpty ? AppColors.gray : AppColors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
