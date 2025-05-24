import 'package:flutter/material.dart';

class AppColors {
  static Color black(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? Colors.white
          : const Color(0xFF1D1D1D);

  static Color darkGray(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFCCCCCC)
          : const Color(0xFF505050);

  static Color gray(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFFAAAAAA)
          : const Color(0xFF848484);

  static Color lightGray(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF444444)
          : const Color(0xFFE2E2E2);

  static Color white(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF121212)
          : const Color(0xFFFFFFFF);

  static Color blue(BuildContext context) =>
      const Color(0xFF0060C7);

  static Color lightBlue(BuildContext context) =>
      const Color(0xFF1D78DA);

  static Color paleBlue(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark
          ? const Color(0xFF2A3E55)
          : const Color(0xFFDBECFF);
}