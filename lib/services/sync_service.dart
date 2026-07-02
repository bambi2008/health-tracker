import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/symptom.dart';
import '../models/diet_log.dart';
import '../models/sleep_log.dart';
import '../models/stress_log.dart';

class SyncService {
  static const String baseUrl = 'http://10.0.55.17:9000/api/v1/sync';
  static const String deviceId = 'health_tracker_device_001';

  /// 上传本地所有数据到服务器
  static Future<Map<String, int>> upload({
    required List<Symptom> symptoms,
    required List<DietLog> diets,
    required List<SleepLog> sleeps,
    required List<StressLog> stresses,
  }) async {
    final body = {
      'device_id': deviceId,
      'symptoms': symptoms.map(_symptom).toList(),
      'diets': diets.map(_diet).toList(),
      'sleeps': sleeps.map(_sleep).toList(),
      'stresses': stresses.map(_stress).toList(),
      'synced_at': DateTime.now().toIso8601String(),
    };

    final resp = await http.post(
      Uri.parse('$baseUrl/upload'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    if (resp.statusCode != 200) throw Exception('上传失败');
    final data = jsonDecode(resp.body);
    return {
      'symptoms': data['count']['symptoms'] ?? 0,
      'diets': data['count']['diets'] ?? 0,
      'sleeps': data['count']['sleeps'] ?? 0,
      'stresses': data['count']['stresses'] ?? 0,
    };
  }

  /// 检查服务器上的数据量
  static Future<Map<String, dynamic>> status() async {
    final resp = await http.get(Uri.parse('$baseUrl/status/$deviceId'));
    if (resp.statusCode != 200) throw Exception('查询失败');
    return jsonDecode(resp.body);
  }

  static Map<String, dynamic> _symptom(Symptom s) => {
        'id': s.id, 'body_part': s.bodyPart, 'body_detail': s.bodyDetail,
        'severity': s.severity, 'description': s.description,
        'onset_type': s.onsetType, 'duration_min': s.durationMin,
        'triggers': s.triggers, 'reliefs': s.reliefs,
        'recorded_at': s.recordedAt.toIso8601String(),
        'created_at': s.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> _diet(DietLog d) => {
        'id': d.id, 'meal_type': d.mealType, 'water_ml': d.waterMl,
        'notes': d.notes,
        'recorded_at': d.recordedAt.toIso8601String(),
        'created_at': d.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> _sleep(SleepLog s) => {
        'id': s.id,
        'sleep_start': s.sleepStart.toIso8601String(),
        'sleep_end': s.sleepEnd.toIso8601String(),
        'quality': s.quality, 'interruptions': s.interruptions,
        'notes': s.notes,
        'recorded_date': s.recordedDate.toIso8601String().substring(0, 10),
        'created_at': s.createdAt.toIso8601String(),
      };

  static Map<String, dynamic> _stress(StressLog s) => {
        'id': s.id, 'level': s.level, 'source': s.source,
        'notes': s.notes,
        'recorded_at': s.recordedAt.toIso8601String(),
        'created_at': s.createdAt.toIso8601String(),
      };
}
