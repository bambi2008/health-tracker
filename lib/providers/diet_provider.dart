import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/constants.dart';
import '../models/diet_log.dart';

class DietProvider extends ChangeNotifier {
  late Box<DietLog> _box;
  List<DietLog> _logs = [];
  bool _loaded = false;

  List<DietLog> get logs => List.unmodifiable(_logs);
  bool get loaded => _loaded;

  void init() {
    _box = Hive.box<DietLog>(AppConstants.dietLogsBox);
    _logs = _box.values.toList()
      ..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    _loaded = true;
  }

  /// 今日饮食
  List<DietLog> get today {
    final now = DateTime.now();
    return _logs.where((l) =>
        l.recordedAt.year == now.year &&
        l.recordedAt.month == now.month &&
        l.recordedAt.day == now.day).toList();
  }

  /// 今日饮水量
  int get todayWaterMl =>
      today.fold(0, (sum, l) => sum + l.waterMl);

  Future<void> add(DietLog log) async {
    await _box.put(log.id, log);
    _logs.insert(0, log);
    notifyListeners();
  }

  Future<void> update(DietLog log) async {
    await _box.put(log.id, log);
    final index = _logs.indexWhere((l) => l.id == log.id);
    if (index != -1) _logs[index] = log;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    _logs.removeWhere((l) => l.id == id);
    notifyListeners();
  }

  /// 日期范围查询
  List<DietLog> getByDateRange(DateTime from, DateTime to) {
    return _logs.where((l) {
      return l.recordedAt.isAfter(from.subtract(const Duration(days: 1))) &&
          l.recordedAt.isBefore(to.add(const Duration(days: 1)));
    }).toList();
  }

  List<Map<String, dynamic>> exportAll() =>
      _logs.map((l) => l.toJson()).toList();
}
