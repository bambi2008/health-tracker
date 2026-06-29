import 'package:hive/hive.dart';

/// 用户设置
class UserSettings extends HiveObject {
  // 主题
  String themeMode; // system/light/dark

  // 提醒
  bool remindSymptom;
  String remindTime; // "20:00"
  bool remindSleep;

  // 隐私
  bool useAnonymous;

  // 健康档案
  String nickname;
  String gender; // male/female/other
  DateTime? birthDate;
  double? heightCm;
  double? weightKg;
  List<String> chronicDiseases;

  UserSettings({
    this.themeMode = 'system',
    this.remindSymptom = true,
    this.remindTime = '20:00',
    this.remindSleep = false,
    this.useAnonymous = true,
    this.nickname = '',
    this.gender = 'other',
    this.birthDate,
    this.heightCm,
    this.weightKg,
    List<String>? chronicDiseases,
  }) : chronicDiseases = chronicDiseases ?? [];

  /// 年龄
  int? get age {
    if (birthDate == null) return null;
    final now = DateTime.now();
    int age = now.year - birthDate!.year;
    if (now.month < birthDate!.month ||
        (now.month == birthDate!.month && now.day < birthDate!.day)) {
      age--;
    }
    return age;
  }

  /// BMI
  double? get bmi {
    if (heightCm == null || weightKg == null || heightCm == 0) return null;
    final h = heightCm! / 100;
    return weightKg! / (h * h);
  }

  /// BMI 分类
  String? get bmiLabel {
    final b = bmi;
    if (b == null) return null;
    if (b < 18.5) return '偏瘦';
    if (b < 24) return '正常';
    if (b < 28) return '偏胖';
    return '肥胖';
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode,
        'remindSymptom': remindSymptom,
        'remindTime': remindTime,
        'remindSleep': remindSleep,
        'useAnonymous': useAnonymous,
        'nickname': nickname,
        'gender': gender,
        'birthDate': birthDate?.toIso8601String(),
        'heightCm': heightCm,
        'weightKg': weightKg,
        'chronicDiseases': chronicDiseases,
      };

  factory UserSettings.fromJson(Map<String, dynamic> json) => UserSettings(
        themeMode: json['themeMode'] as String? ?? 'system',
        remindSymptom: json['remindSymptom'] as bool? ?? true,
        remindTime: json['remindTime'] as String? ?? '20:00',
        remindSleep: json['remindSleep'] as bool? ?? false,
        useAnonymous: json['useAnonymous'] as bool? ?? true,
        nickname: json['nickname'] as String? ?? '',
        gender: json['gender'] as String? ?? 'other',
        birthDate: json['birthDate'] != null
            ? DateTime.tryParse(json['birthDate'].toString())
            : null,
        heightCm: (json['heightCm'] as num?)?.toDouble(),
        weightKg: (json['weightKg'] as num?)?.toDouble(),
        chronicDiseases: (json['chronicDiseases'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
}
