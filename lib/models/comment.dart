import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class Comment extends HiveObject {
  final String id;
  String caseId;
  String content;
  bool isAnonymous;
  final DateTime createdAt;

  Comment({
    String? id,
    required this.caseId,
    required this.content,
    this.isAnonymous = true,
    DateTime? createdAt,
  })  : id = id ?? _uuid.v4(),
        createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id, 'caseId': caseId, 'content': content,
        'isAnonymous': isAnonymous,
        'createdAt': createdAt.toIso8601String(),
      };
}
