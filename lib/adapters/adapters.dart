import 'package:hive/hive.dart';

import 'symptom_adapter.dart';
import 'diet_log_adapter.dart';
import 'sleep_log_adapter.dart';
import 'stress_log_adapter.dart';
import 'user_settings_adapter.dart';
import 'health_report_adapter.dart';
import 'medical_case_adapter.dart';
import 'comment_adapter.dart';

/// 注册所有手动 Hive TypeAdapter
/// 必须在 Hive.initFlutter() 之后、openBox() 之前调用
void registerAdapters() {
  if (!Hive.isAdapterRegistered(0)) Hive.registerAdapter(SymptomAdapter());
  if (!Hive.isAdapterRegistered(1)) Hive.registerAdapter(DietLogAdapter());
  if (!Hive.isAdapterRegistered(2)) Hive.registerAdapter(SleepLogAdapter());
  if (!Hive.isAdapterRegistered(3)) Hive.registerAdapter(StressLogAdapter());
  if (!Hive.isAdapterRegistered(4)) Hive.registerAdapter(UserSettingsAdapter());
  if (!Hive.isAdapterRegistered(5)) Hive.registerAdapter(HealthReportAdapter());
  if (!Hive.isAdapterRegistered(6)) Hive.registerAdapter(MedicalCaseAdapter());
  if (!Hive.isAdapterRegistered(7)) Hive.registerAdapter(CommentAdapter());
}
