import 'package:flutter/material.dart';

class AppTheme {
  // === 品牌色 ===
  static const primaryColor = Color(0xFF4CAF50); // 绿色 — 健康
  static const secondaryColor = Color(0xFF2196F3); // 蓝色 — 信任
  static const accentColor = Color(0xFFFF9800); // 橙色 — 警示
  static const errorColor = Color(0xFFE53935);

  // === 严重度颜色 ===
  static const severityLow = Color(0xFF8BC34A);
  static const severityMid = Color(0xFFFFC107);
  static const severityHigh = Color(0xFFFF5722);

  /// 严重度 → 颜色
  static Color severityColor(int severity) {
    if (severity <= 3) return severityLow;
    if (severity <= 6) return severityMid;
    return severityHigh;
  }

  // === 身体部位颜色 ===
  static const bodyPartColors = <String, Color>{
    'head': Color(0xFFEF9A9A),
    'neck': Color(0xFFF48FB1),
    'chest': Color(0xFFCE93D8),
    'abdomen': Color(0xFFB39DDB),
    'back': Color(0xFF9FA8DA),
    'limb': Color(0xFF90CAF9),
    'skin': Color(0xFFA5D6A7),
    'general': Color(0xFFB0BEC5),
  };

  static Color bodyPartColor(String part) =>
      bodyPartColors[part] ?? Colors.grey;

  static ThemeData lightTheme() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        colorSchemeSeed: primaryColor,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );

  static ThemeData darkTheme() => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: primaryColor,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
}
