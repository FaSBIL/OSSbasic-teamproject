import 'package:flutter/material.dart';
import '../../theme/color.dart';
import '../../theme/typography.dart';
import '../icon/iconUtils.dart';

class SearchInput extends StatelessWidget {
  final VoidCallback? onBackTap;
  final TextEditingController? controller;
  final String hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const SearchInput({
    Key? key,
    this.onBackTap,
    this.controller,
    this.hintText = "대피소 검색",
    this.onChanged,
    this.onSubmitted,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.lightGray,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: onBackTap ?? () => Navigator.pop(context),
              child: const Icon(AppIcons.arrowRight, size: 20, color: AppColors.black),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                style: AppTextStyles.body,
                decoration: InputDecoration(
                  hintText: hintText,
                  hintStyle: AppTextStyles.body.copyWith(color: AppColors.gray),
                  border: InputBorder.none,
                  isDense: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}