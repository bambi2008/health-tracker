import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/constants.dart';
import '../models/sleep_log.dart';

class SleepProvider extends ChangeNotifier {
  late Box<SleepLog> _box;
  List<SleepLog> _logs = [];
  bool _loaded = false;

  List<SleepLog> get logs => List.unmodifiable(_logs);
  bool get loaded => _loaded;

  void init() {
    _box = Hive.box<SleepLog>(AppConstants.sleepLogsBox);
    _logs = _box.values.toList()
      ..sort((a, b) => b.recordedDate.compareTo(a.recordedDate));
    _loaded = true;
  }

  /// 最近一条睡眠记录
  SleepLog? get latest => _logs.isNotEmpty ? _logs.first : null;

  /// 按日期获取
  SleepLog? getByDate(DateTime date) {
    return _logs.where((l) =>
        l.recordedDate.year == date.year &&
        l.recordedDate.month == date.month &&
        l.recordedDate.day == date.day).firstOrNull;
  }

  Future<void> add(SleepLog log) async {
    // 同一天只保留一条
    final existing = getByDate(log.recordedDate);
    if (existing != null) await _box.delete(existing.id);
    await _box.put(log.id, log);
    _logs.removeWhere((l) =>
        l.recordedDate.year == log.recordedDate.year &&
        l.recordedDate.month == log.recordedDate.month &&
        l.recordedDate.day == log.recordedDate.day);
    _logs.insert(0, log);
    _logs.sort((a, b) => b.recordedDate.compareTo(a.recordedDate));
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    _logs.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  /// 日期范围查询
  List<SleepLog> getByDateRange(DateTime from, DateTime to) {
    return _logs.where((l) {
      return l.recordedDate.isAfter(from.subtract(const Duration(days: 1))) &&
          l.recordedDate.isBefore(to.add(const Duration(days: 1)));
    }).toList();
  }

  /// 平均睡眠时长（分钟）
  double avgDuration(int days) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));
    final recent = _logs.where((l) => l.recordedDate.isAfter(start));
    if (recent.isEmpty) return 0;
    return recent.fold<int>(0, (sum, l) => sum + l.duration.inMinutes) /
        recent.length;
  }

  /// 平均质量
  double avgQuality(int days) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));
    final recent = _logs.where((l) => l.recordedDate.isAfter(start));
    if (recent.isEmpty) return 0;
    return recent.fold<int>(0, (sum, l) => sum + l.quality) / recent.length;
  }

  List<Map<String, dynamic>> exportAll() =>
      _logs.map((l) => l.toJson()).toList();
}
