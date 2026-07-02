import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'config/constants.dart';
import 'adapters/adapters.dart';
import 'models/symptom.dart';
import 'models/diet_log.dart';
import 'models/sleep_log.dart';
import 'models/stress_log.dart';
import 'models/user_settings.dart';
import 'models/health_report.dart';
import 'models/medical_case.dart';
import 'models/comment.dart';
import 'providers/symptom_provider.dart';
import 'providers/diet_provider.dart';
import 'providers/sleep_provider.dart';
import 'providers/stress_provider.dart';
import 'providers/report_provider.dart';
import 'providers/user_settings_provider.dart';
import 'providers/community_provider.dart';
import 'providers/auth_provider.dart';
import 'services/sample_data.dart';
import 'app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化 Hive
  await Hive.initFlutter();

  // 注册手动 TypeAdapter
  registerAdapters();

  // 打开所有 Box（类型必须与 Provider 中的一致）
  await Future.wait([
    Hive.openBox<Symptom>(AppConstants.symptomsBox),
    Hive.openBox<DietLog>(AppConstants.dietLogsBox),
    Hive.openBox<SleepLog>(AppConstants.sleepLogsBox),
    Hive.openBox<StressLog>(AppConstants.stressLogsBox),
    Hive.openBox<UserSettings>(AppConstants.userSettingsBox),
    Hive.openBox<HealthReport>(AppConstants.reportsBox),
    Hive.openBox<MedicalCase>('medical_cases'),
    Hive.openBox<Comment>('comments'),
  ]);

  // 获取 providers 引用以便 auto-seed
  final symptomProv = SymptomProvider()..init();
  final dietProv = DietProvider()..init();
  final sleepProv = SleepProvider()..init();
  final stressProv = StressProvider()..init();
  final communityProv = CommunityProvider()..init();

  // 首次启动自动导入示例数据
  if (symptomProv.symptoms.isEmpty) {
    await SampleData.importAll(
      symptomProv: symptomProv,
      dietProv: dietProv,
      sleepProv: sleepProv,
      stressProv: stressProv,
      communityProv: communityProv,
    );
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserSettingsProvider()..init()),
        ChangeNotifierProvider(create: (_) => symptomProv),
        ChangeNotifierProvider(create: (_) => dietProv),
        ChangeNotifierProvider(create: (_) => sleepProv),
        ChangeNotifierProvider(create: (_) => stressProv),
        ChangeNotifierProvider(create: (_) => ReportProvider()..init()),
        ChangeNotifierProvider(create: (_) => communityProv),
      ],
      child: const HealthTrackerApp(),
    ),
  );
}
