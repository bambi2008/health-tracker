import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/constants.dart';
import '../models/user_settings.dart';

class UserSettingsProvider extends ChangeNotifier {
  late Box<UserSettings> _box;
  UserSettings _settings = UserSettings();
  bool _loaded = false;

  UserSettings get settings => _settings;
  bool get loaded => _loaded;

  void init() {
    _box = Hive.box<UserSettings>(AppConstants.userSettingsBox);
    if (_box.isNotEmpty) {
      _settings = _box.values.first;
    } else {
      _box.put('default', _settings);
    }
    _loaded = true;
  }

  Future<void> save() async {
    await _box.put('default', _settings);
    notifyListeners();
  }

  // === 便捷方法 ===

  void setThemeMode(String mode) {
    _settings.themeMode = mode;
    save();
  }

  void setNickname(String name) {
    _settings.nickname = name;
    save();
  }

  void setGender(String gender) {
    _settings.gender = gender;
    save();
  }

  void setBirthDate(DateTime? date) {
    _settings.birthDate = date;
    save();
  }

  void setHeight(double? cm) {
    _settings.heightCm = cm;
    save();
  }

  void setWeight(double? kg) {
    _settings.weightKg = kg;
    save();
  }

  void setChronicDiseases(List<String> diseases) {
    _settings.chronicDiseases = diseases;
    save();
  }

  void setRemindSymptom(bool value) {
    _settings.remindSymptom = value;
    save();
  }

  void setRemindTime(String time) {
    _settings.remindTime = time;
    save();
  }

  void setRemindSleep(bool value) {
    _settings.remindSleep = value;
    save();
  }

  // === 数据导出/导入 ===

  Map<String, dynamic> exportJson() => _settings.toJson();

  Future<void> importJson(Map<String, dynamic> json) async {
    _settings = UserSettings.fromJson(json);
    await save();
  }

  /// 清除所有设置（恢复默认）
  Future<void> reset() async {
    _settings = UserSettings();
    await save();
  }
}
