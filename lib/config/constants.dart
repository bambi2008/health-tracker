/// 应用常量
class AppConstants {
  AppConstants._();

  static const appName = '症状追踪';
  static const appVersion = '1.0.0';

  // Hive Box 名称
  static const symptomsBox = 'symptoms';
  static const dietLogsBox = 'diet_logs';
  static const sleepLogsBox = 'sleep_logs';
  static const stressLogsBox = 'stress_logs';
  static const userSettingsBox = 'user_settings';
  static const reportsBox = 'reports';

  // 严重度范围
  static const severityMin = 1;
  static const severityMax = 10;

  // 睡眠质量范围
  static const sleepQualityMin = 1;
  static const sleepQualityMax = 5;
}
