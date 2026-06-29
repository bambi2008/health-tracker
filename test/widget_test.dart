import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:health_tracker/app.dart';
import 'package:health_tracker/providers/user_settings_provider.dart';
import 'package:health_tracker/providers/symptom_provider.dart';
import 'package:health_tracker/providers/diet_provider.dart';
import 'package:health_tracker/providers/sleep_provider.dart';
import 'package:health_tracker/providers/stress_provider.dart';
import 'package:health_tracker/providers/report_provider.dart';
import 'package:health_tracker/adapters/adapters.dart';

void main() {
  testWidgets('App builds and shows bottom navigation', (tester) async {
    // Initialize Hive for testing
    Hive.init('test_hive_widget');
    registerAdapters();
    await Future.wait([
      Hive.openBox('symptoms'),
      Hive.openBox('diet_logs'),
      Hive.openBox('sleep_logs'),
      Hive.openBox('stress_logs'),
      Hive.openBox('user_settings'),
      Hive.openBox('reports'),
    ]);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => UserSettingsProvider()..init()),
          ChangeNotifierProvider(create: (_) => SymptomProvider()..init()),
          ChangeNotifierProvider(create: (_) => DietProvider()..init()),
          ChangeNotifierProvider(create: (_) => SleepProvider()..init()),
          ChangeNotifierProvider(create: (_) => StressProvider()..init()),
          ChangeNotifierProvider(create: (_) => ReportProvider()..init()),
        ],
        child: const HealthTrackerApp(),
      ),
    );
    await tester.pumpAndSettle();

    // Should show the bottom navigation bar
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('症状'), findsWidgets);
  });
}
