import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/symptom.dart';
import '../models/diet_log.dart';
import '../models/sleep_log.dart';
import '../models/stress_log.dart';
import '../models/ai_analysis.dart';

/// 后端 API 客户端
class ApiClient {
  // 后端地址 — 本地调试用 localhost，真机/模拟器用 10.0.2.2 (Android) 或实际 IP
  static const String baseUrl = 'http://10.0.55.17:9000/api/v1';

  /// 发送数据到 AI 分析接口
  static Future<AiAnalysisResult> analyze({
    required List<Symptom> symptoms,
    required List<DietLog> diets,
    required List<SleepLog> sleeps,
    required List<StressLog> stresses,
    String? userInfo,
  }) async {
    final body = {
      'symptoms': symptoms.map(_toSymptomJson).toList(),
      'diets': diets.map(_toDietJson).toList(),
      'sleeps': sleeps.map(_toSleepJson).toList(),
      'stresses': stresses.map(_toStressJson).toList(),
      if (userInfo != null) 'user_info': userInfo,
    };

    try {
      final resp = await http
          .post(
            Uri.parse('$baseUrl/ai/analyze'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 30));

      if (resp.statusCode == 200) {
        final data = jsonDecode(resp.body);
        return AiAnalysisResult.fromJson(data);
      } else {
        return AiAnalysisResult(
            modelUsed: 'error: HTTP ${resp.statusCode}');
      }
    } catch (e) {
      return AiAnalysisResult(modelUsed: 'error: ${e.toString()}');
    }
  }

  static Map<String, dynamic> _toSymptomJson(Symptom s) => {
        'body_part': s.bodyPart,
        'body_detail': s.bodyDetail,
        'severity': s.severity,
        'description': s.description,
        'onset_type': s.onsetType,
        'duration_min': s.durationMin,
        'triggers': s.triggers,
        'reliefs': s.reliefs,
        'recorded_at': s.recordedAt.toIso8601String(),
      };

  static Map<String, dynamic> _toDietJson(DietLog d) => {
        'meal_type': d.mealType,
        'water_ml': d.waterMl,
        'notes': d.notes,
        'recorded_at': d.recordedAt.toIso8601String(),
      };

  static Map<String, dynamic> _toSleepJson(SleepLog s) => {
        'sleep_start': s.sleepStart.toIso8601String(),
        'sleep_end': s.sleepEnd.toIso8601String(),
        'quality': s.quality,
        'interruptions': s.interruptions,
        'recorded_date': s.recordedDate.toIso8601String().substring(0, 10),
      };

  static Map<String, dynamic> _toStressJson(StressLog s) => {
        'level': s.level,
        'source': s.source,
        'notes': s.notes,
        'recorded_at': s.recordedAt.toIso8601String(),
      };
}
