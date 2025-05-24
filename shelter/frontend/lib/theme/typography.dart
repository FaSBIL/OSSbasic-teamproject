import 'package:flutter/material.dart';

class AppTextStyles {
  static const String fontFamily = 'NotoSansKR';

  static TextStyle title(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).textTheme.titleLarge?.color,
      );

  static TextStyle subtitle(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).textTheme.titleMedium?.color,
      );

  static TextStyle body(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).textTheme.bodyMedium?.color,
      );

  static TextStyle bodyGray(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).hintColor,
      );

  static TextStyle caption(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).textTheme.bodySmall?.color,
      );

  static TextStyle captionGray(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).hintColor,
      );

  static TextStyle small(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).textTheme.labelSmall?.color,
      );

  static TextStyle smallGray(BuildContext context) => TextStyle(
        fontFamily: fontFamily,
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: Theme.of(context).hintColor,
      );
}