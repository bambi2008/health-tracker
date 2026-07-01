import 'package:flutter/material.dart';

class AppTheme {
  // 主色调 — 柔和鼠尾草绿，不刺眼的医疗感
  static const primary = Color(0xFF6B9080);    // sage green
  static const secondary = Color(0xFFA4C3B2);  // light sage
  static const surface = Color(0xFFF6F8F5);    // warm white bg
  static const accent = Color(0xFF4A7C96);     // muted blue

  // 严重度色阶
  static Color severityColor(int v) {
    if (v <= 3) return const Color(0xFF8BB19C);
    if (v <= 6) return const Color(0xFFE8B44F);
    return const Color(0xFFD4746B);
  }

  static const bodyPartColors = <String, Color>{
    'head': Color(0xFFD4A5A5), 'neck': Color(0xFFD4B8A5),
    'chest': Color(0xFFC4B5D4), 'abdomen': Color(0xFFB5C4D4),
    'back': Color(0xFFA5C4D4), 'limb': Color(0xFFA5D4C4),
    'skin': Color(0xFFC4D4A5), 'general': Color(0xFFC4C4C4),
  };
  static Color bodyPartColor(String p) => bodyPartColors[p] ?? Colors.grey;

  static ThemeData light() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      surface: surface,
      brightness: Brightness.light,
    ),
    fontFamily: 'System',
    scaffoldBackgroundColor: surface,
    appBarTheme: const AppBarTheme(
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: Colors.transparent,
      titleTextStyle: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E)),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.only(bottom: 12),
    ),
    navigationBarTheme: NavigationBarThemeData(
      elevation: 0,
      backgroundColor: Colors.white,
      indicatorColor: primary.withValues(alpha: 0.12),
      labelTextStyle: WidgetStatePropertyAll(TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: primary)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary, foregroundColor: Colors.white,
        elevation: 0, padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true, fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.shade200)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: primary)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    chipTheme: ChipThemeData(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: BorderSide.none,
      backgroundColor: Colors.grey.shade100,
    ),
  );
}
