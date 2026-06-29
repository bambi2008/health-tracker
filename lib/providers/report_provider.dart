import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../config/constants.dart';
import '../models/health_report.dart';

class ReportProvider extends ChangeNotifier {
  late Box<HealthReport> _box;
  List<HealthReport> _reports = [];
  bool _loaded = false;

  List<HealthReport> get reports => List.unmodifiable(_reports);
  bool get loaded => _loaded;

  void init() {
    _box = Hive.box<HealthReport>(AppConstants.reportsBox);
    _reports = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    _loaded = true;
  }

  HealthReport? getById(String id) {
    try {
      return _box.get(id);
    } catch (_) {
      return _reports.where((r) => r.id == id).firstOrNull;
    }
  }

  Future<void> add(HealthReport report) async {
    await _box.put(report.id, report);
    _reports.insert(0, report);
    notifyListeners();
  }

  Future<void> update(HealthReport report) async {
    await _box.put(report.id, report);
    final index = _reports.indexWhere((r) => r.id == report.id);
    if (index != -1) _reports[index] = report;
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    _reports.removeWhere((r) => r.id == id);
    notifyListeners();
  }

  List<Map<String, dynamic>> exportAll() =>
      _reports.map((r) => r.toJson()).toList();
}
