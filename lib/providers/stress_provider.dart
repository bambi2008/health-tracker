import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/constants.dart';
import '../models/stress_log.dart';

class StressProvider extends ChangeNotifier {
  late Box<StressLog> _box;
  List<StressLog> _logs = [];
  bool _loaded = false;

  List<StressLog> get logs => List.unmodifiable(_logs);
  bool get loaded => _loaded;

  void init() {
    _box = Hive.box<StressLog>(AppConstants.stressLogsBox);
    _logs = _box.values.toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    _loaded = true;
  }

  /// 今天所有记录
  List<StressLog> get today {
    final now = DateTime.now();
    return _logs.where((l) =>
        l.recordedAt.year == now.year &&
        l.recordedAt.month == now.month &&
        l.recordedAt.day == now.day).toList();
  }

  /// 今日平均压力
  double get todayAvg {
    if (today.isEmpty) return 0;
    return today.fold<int>(0, (sum, l) => sum + l.level) / today.length;
  }

  Future<void> add(StressLog log) async {
    await _box.put(log.id, log);
    _logs.insert(0, log);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    _logs.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  /// 日期范围查询
  List<StressLog> getByDateRange(DateTime from, DateTime to) {
    return _logs.where((l) {
      return l.recordedAt.isAfter(from.subtract(const Duration(days: 1))) &&
          l.recordedAt.isBefore(to.add(const Duration(days: 1)));
    }).toList();
  }

  /// 每日平均压力趋势
  Map<DateTime, double> avgByDay(int days) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: days));
    final map = <DateTime, List<int>>{};
    for (final l in _logs) {
      if (l.recordedAt.isBefore(start)) continue;
      final date =
          DateTime(l.recordedAt.year, l.recordedAt.month, l.recordedAt.day);
      map.putIfAbsent(date, () => []).add(l.level);
    }
    final result = <DateTime, double>{};
    map.forEach((date, levels) {
      result[date] = levels.fold(0, (s, v) => s + v) / levels.length;
    });
    return result;
  }

  List<Map<String, dynamic>> exportAll() =>
      _logs.map((l) => l.toJson()).toList();
}
