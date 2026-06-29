import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// 压力记录
class StressLog extends HiveObject {
  final String id;
  int level; // 1-10
  String source; // work/family/health/financial/other
  String notes;
  DateTime recordedAt;
  final DateTime createdAt;

  StressLog({
    String? id,
    this.level = 5,
    this.source = 'other',
    this.notes = '',
    DateTime? recordedAt,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        recordedAt = recordedAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  /// 压力等级文本
  String get levelLabel {
    if (level <= 2) return '很低';
    if (level <= 4) return '较低';
    if (level <= 6) return '中等';
    if (level <= 8) return '较高';
    return '很高';
  }

  /// 压力来源中文
  String get sourceLabel {
    switch (source) {
      case 'work':
        return '工作';
      case 'family':
        return '家庭';
      case 'health':
        return '健康';
      case 'financial':
        return '财务';
      case 'other':
        return '其他';
      default:
        return source;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'level': level,
        'source': source,
        'notes': notes,
        'recordedAt': recordedAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory StressLog.fromJson(Map<String, dynamic> json) => StressLog(
        id: json['id'] as String?,
        level: json['level'] as int? ?? 5,
        source: json['source'] as String? ?? 'other',
        notes: json['notes'] as String? ?? '',
        recordedAt: json['recordedAt'] != null
            ? DateTime.tryParse(json['recordedAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
}
