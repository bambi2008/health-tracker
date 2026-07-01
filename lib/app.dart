import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'config/router.dart';
import 'providers/user_settings_provider.dart';

class HealthTrackerApp extends StatelessWidget {
  const HealthTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserSettingsProvider>(
      builder: (context, settings, _) {
        final themeMode = _mapThemeMode(settings.settings.themeMode);
        return MaterialApp.router(
          title: '症状追踪',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: ThemeData.dark(useMaterial3: true),
          themeMode: themeMode,
          routerConfig: router,
        );
      },
    );
  }

  ThemeMode _mapThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }
}
