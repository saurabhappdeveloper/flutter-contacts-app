import 'package:flutter/material.dart';

class AppColors {
  static const primary     = Color(0xFF1A73E8);
  static const primaryDark = Color(0xFF1557B0);
  static const green       = Color(0xFF34A853);
  static const error       = Color(0xFFEA4335);

  static const background  = Color(0xFFF8F9FA);
  static const surface     = Colors.white;

  static const textDark    = Color(0xFF202124);
  static const textGrey    = Color(0xFF5F6368);

  static const List<Color> avatarColors = [
    Color(0xFF1A73E8),
    Color(0xFF34A853),
    Color(0xFFEA4335),
    Color(0xFFFBBC04),
    Color(0xFF9334E6),
    Color(0xFF00ACC1),
    Color(0xFFE67C73),
    Color(0xFF33B679),
    Color(0xFF0B8043),
    Color(0xFF8D6E63),
  ];
  static Color avatarColor(String name) {
    if (name.isEmpty) return avatarColors[0];
    return avatarColors[name.codeUnitAt(0) % avatarColors.length];
  }
}
