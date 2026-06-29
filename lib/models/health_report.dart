import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// 健康报告
class HealthReport extends HiveObject {
  final String id;
  String reportType; // weekly/monthly/custom
  DateTime dateFrom;
  DateTime dateTo;
  String contentMarkdown;
  String? pdfPath; // 导出的 PDF 本地路径
  final DateTime createdAt;

  HealthReport({
    String? id,
    this.reportType = 'weekly',
    DateTime? dateFrom,
    DateTime? dateTo,
    this.contentMarkdown = '',
    this.pdfPath,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        dateFrom = dateFrom ?? DateTime.now().subtract(const Duration(days: 7)),
        dateTo = dateTo ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  /// 报告类型中文
  String get reportTypeLabel {
    switch (reportType) {
      case 'weekly':
        return '周报';
      case 'monthly':
        return '月报';
      case 'custom':
        return '自定义';
      default:
        return reportType;
    }
  }

  /// 时间范围文本
  String get dateRangeLabel {
    final fmt = (DateTime d) =>
        '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
    return '${fmt(dateFrom)} ~ ${fmt(dateTo)}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'reportType': reportType,
        'dateFrom': dateFrom.toIso8601String(),
        'dateTo': dateTo.toIso8601String(),
        'contentMarkdown': contentMarkdown,
        'pdfPath': pdfPath,
        'createdAt': createdAt.toIso8601String(),
      };

  factory HealthReport.fromJson(Map<String, dynamic> json) => HealthReport(
        id: json['id'] as String?,
        reportType: json['reportType'] as String? ?? 'weekly',
        dateFrom: json['dateFrom'] != null
            ? DateTime.tryParse(json['dateFrom'].toString()) ??
                DateTime.now().subtract(const Duration(days: 7))
            : DateTime.now().subtract(const Duration(days: 7)),
        dateTo: json['dateTo'] != null
            ? DateTime.tryParse(json['dateTo'].toString()) ?? DateTime.now()
            : DateTime.now(),
        contentMarkdown: json['contentMarkdown'] as String? ?? '',
        pdfPath: json['pdfPath'] as String?,
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
}
