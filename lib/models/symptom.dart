import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../config/categories.dart';

const _uuid = Uuid();

/// 症状记录
class Symptom extends HiveObject {
  final String id;
  String bodyPart;
  String bodyDetail;
  int severity;
  String description;
  String onsetType;
  int? durationMin;
  List<String> triggers;
  List<String> reliefs;
  List<String> imagePaths;
  DateTime recordedAt;
  final DateTime createdAt;

  Symptom({
    String? id,
    this.bodyPart = 'head',
    this.bodyDetail = '',
    this.severity = 5,
    this.description = '',
    this.onsetType = 'gradual',
    this.durationMin,
    List<String>? triggers,
    List<String>? reliefs,
    List<String>? imagePaths,
    DateTime? recordedAt,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        triggers = triggers ?? [],
        reliefs = reliefs ?? [],
        imagePaths = imagePaths ?? [],
        recordedAt = recordedAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  /// 部位名称
  String get bodyDetailLabel =>
      BodyParts.findById(bodyDetail)?.label ?? bodyDetail;

  /// 严重程度文本
  String get severityLabel {
    if (severity <= 2) return '轻微';
    if (severity <= 4) return '轻度';
    if (severity <= 6) return '中度';
    if (severity <= 8) return '重度';
    return '剧烈';
  }

  /// 发作类型中文
  String get onsetLabel {
    switch (onsetType) {
      case 'sudden':
        return '突然发作';
      case 'gradual':
        return '逐渐出现';
      case 'persistent':
        return '持续存在';
      case 'intermittent':
        return '间歇性';
      default:
        return onsetType;
    }
  }

  /// 持续时间文本
  String get durationLabel {
    if (durationMin == null) return '未知';
    if (durationMin! < 60) return '${durationMin!}分钟';
    final hours = durationMin! ~/ 60;
    final mins = durationMin! % 60;
    if (mins == 0) return '$hours小时';
    return '$hours小时$mins分钟';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'bodyPart': bodyPart,
        'bodyDetail': bodyDetail,
        'severity': severity,
        'description': description,
        'onsetType': onsetType,
        'durationMin': durationMin,
        'triggers': triggers,
        'reliefs': reliefs,
        'imagePaths': imagePaths,
        'recordedAt': recordedAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory Symptom.fromJson(Map<String, dynamic> json) => Symptom(
        id: json['id'] as String?,
        bodyPart: json['bodyPart'] as String? ?? 'head',
        bodyDetail: json['bodyDetail'] as String? ?? '',
        severity: json['severity'] as int? ?? 5,
        description: json['description'] as String? ?? '',
        onsetType: json['onsetType'] as String? ?? 'gradual',
        durationMin: json['durationMin'] as int?,
        triggers: (json['triggers'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        reliefs: (json['reliefs'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        imagePaths: (json['imagePaths'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
        recordedAt: json['recordedAt'] != null
            ? DateTime.tryParse(json['recordedAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
}
