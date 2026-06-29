import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// 饮食记录
class DietLog extends HiveObject {
  final String id;
  String mealType;
  String foodItems; // JSON: [{"name":"鸡蛋","amount":"2个"},...]
  int waterMl;
  String notes;
  DateTime recordedAt;
  final DateTime createdAt;

  DietLog({
    String? id,
    this.mealType = 'breakfast',
    this.foodItems = '[]',
    this.waterMl = 0,
    this.notes = '',
    DateTime? recordedAt,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        recordedAt = recordedAt ?? DateTime.now(),
        createdAt = createdAt ?? DateTime.now();

  /// 餐型中文
  String get mealTypeLabel {
    switch (mealType) {
      case 'breakfast':
        return '早餐';
      case 'lunch':
        return '午餐';
      case 'dinner':
        return '晚餐';
      case 'snack':
        return '零食';
      default:
        return mealType;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'mealType': mealType,
        'foodItems': foodItems,
        'waterMl': waterMl,
        'notes': notes,
        'recordedAt': recordedAt.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  factory DietLog.fromJson(Map<String, dynamic> json) => DietLog(
        id: json['id'] as String?,
        mealType: json['mealType'] as String? ?? 'breakfast',
        foodItems: json['foodItems'] as String? ?? '[]',
        waterMl: json['waterMl'] as int? ?? 0,
        notes: json['notes'] as String? ?? '',
        recordedAt: json['recordedAt'] != null
            ? DateTime.tryParse(json['recordedAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
        createdAt: json['createdAt'] != null
            ? DateTime.tryParse(json['createdAt'].toString()) ?? DateTime.now()
            : DateTime.now(),
      );
}
