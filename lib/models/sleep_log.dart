import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// 睡眠记录
class SleepLog extends HiveObject {
  final String id;
  DateTime sleepStart;
  DateTime sleepEnd;
  int quality; // 1-5
  int interruptions;
  String notes;
  DateTime recordedDate;
  final DateTime createdAt;

  SleepLog({
    String? id,
    DateTime? sleepStart,
    DateTime? sleepEnd,
    this.quality = 3,
    this.interruptions = 0,
    this.notes = '',
    DateTime? recordedDate,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        sleepStart = sleepStart ?? DateTime.now().subtract(const Duration(hours: 8)),
        sleepEnd = sleepEnd ?? DateTime.now(),
        recordedDate = recordedDate ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  /// 睡眠时长
  Duration get duration => sleepEnd.difference(sleepStart);

  /// 睡眠时长文本
  String get durationLabel {
    final h = duration.inHours;
    final m = duration.inMinutes % 60;
    if (h == 0) return '${m}分钟';
    if (m == 0) return '$h小时';
    return '$h小时$m分钟';
  }

  /// 睡眠质量文本
  String get qualityLabel {
    switch (quality) {
      case 1:
        return '很差';
      case 2:
        return '较差';
      case 3:
        return '一般';
      case 4:
        return '良好';
      case 5:
        return '很好';
      default:
        return '$quality';
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'sleepStart': sleepStart.toIso8601String(),
        'sleepEnd': sleepEnd.toIso8601String(),
        'quality': quality,
        'interruptions': interruptions,
        'notes': notes,
        'recordedDate': recordedDate.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory SleepLog.fromJson(Map<String, dynamic> json) => SleepLog(
        id: json['id'] as String?,
        sleepStart: json['sleepStart'] != null
            ? DateTime.tryParse(json['sleepStart'].toString()) ?? DateTime.now().subtract(const Duration(hours: 8))
            : DateTime.now().subtract(const Duration(hours: 8)),
        sleepEnd: json['sleepEnd'] != null
            ? DateTime.tryParse(json['sleepEnd'].toString()) ?? DateTime.now()
            : DateTime.now(),
        quality: json['quality'] as int? ?? 3,
        interruptions: json['interruptions'] as int? ?? 0,
        notes: json['notes'] as String? ?? '',
        recordedDate: json['recordedDate'] != null
            ? DateTime.tryParse(json['recordedDate'].toString()) ?? DateTime.now()
            : DateTime.now(),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
}
