import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/constants.dart';
import '../models/symptom.dart';

class SymptomProvider extends ChangeNotifier {
  late Box<Symptom> _box;
  List<Symptom> _symptoms = [];
  bool _loaded = false;

  List<Symptom> get symptoms => List.unmodifiable(_symptoms);
  bool get loaded => _loaded;

  void init() {
    _box = Hive.box<Symptom>(AppConstants.symptomsBox);
    _symptoms = _box.values.toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    _loaded = true;
  }

  /// 按 ID 获取症状
  Symptom? getById(String id) {
    try {
      return _box.get(id);
    } catch (_) {
      return _symptoms.where((s) => s.id == id).firstOrNull;
    }
  }

  /// 添加症状
  Future<void> add(Symptom symptom) async {
    await _box.put(symptom.id, symptom);
    _symptoms.insert(0, symptom);
    notifyListeners();
  }

  /// 更新症状
  Future<void> update(Symptom symptom) async {
    await _box.put(symptom.id, symptom);
    final index = _symptoms.indexWhere((s) => s.id == symptom.id);
    if (index != -1) {
      _symptoms[index] = symptom;
      _symptoms.sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    }
    notifyListeners();
  }

  /// 删除症状
  Future<void> delete(String id) async {
    await _box.delete(id);
    _symptoms.removeWhere((s) => s.id == id);
    notifyListeners();
  }

  /// 按日期范围查询
  List<Symptom> getByDateRange(DateTime from, DateTime to) {
    return _symptoms.where((s) {
      return s.recordedAt.isAfter(from.subtract(const Duration(days: 1))) &&
          s.recordedAt.isBefore(to.add(const Duration(days: 1)));
    }).toList();
  }

  /// 按身体部位查询
  List<Symptom> getByBodyPart(String bodyPart) {
    return _symptoms.where((s) => s.bodyPart == bodyPart).toList();
  }

  /// 最近 N 天的症状趋势（每天的症状数量）
  Map<DateTime, int> dailyCounts(int days) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));
    final map = <DateTime, int>{};
    for (int i = 0; i <= days; i++) {
      final date = DateTime(start.year, start.month, start.day + i);
      map[date] = 0;
    }
    for (final s in _symptoms) {
      if (s.recordedAt.isBefore(start)) continue;
      final date =
          DateTime(s.recordedAt.year, s.recordedAt.month, s.recordedAt.day);
      map[date] = (map[date] ?? 0) + 1;
    }
    return map;
  }

  /// 平均严重度趋势
  Map<DateTime, double> avgSeverityByDay(int days) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));
    final map = <DateTime, List<int>>{};
    for (final s in _symptoms) {
      if (s.recordedAt.isBefore(start)) continue;
      final date =
          DateTime(s.recordedAt.year, s.recordedAt.month, s.recordedAt.day);
      map.putIfAbsent(date, () => []).add(s.severity);
    }
    final result = <DateTime, double>{};
    map.forEach((date, severities) {
      result[date] =
          severities.fold(0, (sum, s) => sum + s) / severities.length;
    });
    return result;
  }

  /// 导出所有数据
  List<Map<String, dynamic>> exportAll() {
    return _symptoms.map((s) => s.toJson()).toList();
  }
}
