import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

class MedicalCase extends HiveObject {
  final String id;
  String title;
  String content;
  List<String> symptomTags;
  List<String> bodyParts;
  String durationTag;
  String diagnosisStatus;
  int doctorVisits;
  int upvoteCount;
  int commentCount;
  int viewCount;
  bool isAnonymous;
  String status;
  final DateTime createdAt;
  DateTime updatedAt;

  MedicalCase({
    String? id,
    this.title = '',
    this.content = '',
    List<String>? symptomTags,
    List<String>? bodyParts,
    this.durationTag = 'months',
    this.diagnosisStatus = 'undiagnosed',
    this.doctorVisits = 0,
    this.upvoteCount = 0,
    this.commentCount = 0,
    this.viewCount = 0,
    this.isAnonymous = true,
    this.status = 'published',
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : id = id ?? _uuid.v4(),
        symptomTags = symptomTags ?? [],
        bodyParts = bodyParts ?? [],
        createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  String get durationLabel {
    switch (durationTag) {
      case 'days': return '数天';
      case 'weeks': return '数周';
      case 'months': return '数月';
      case 'years': return '数年';
      default: return durationTag;
    }
  }

  String get diagnosisLabel {
    switch (diagnosisStatus) {
      case 'undiagnosed': return '未确诊';
      case 'tentative': return '初步诊断';
      case 'confirmed': return '已确诊';
      default: return diagnosisStatus;
    }
  }

  Map<String, dynamic> toJson() => {
        'id': id, 'title': title, 'content': content,
        'symptomTags': symptomTags, 'bodyParts': bodyParts,
        'durationTag': durationTag, 'diagnosisStatus': diagnosisStatus,
        'doctorVisits': doctorVisits, 'upvoteCount': upvoteCount,
        'commentCount': commentCount, 'viewCount': viewCount,
        'isAnonymous': isAnonymous, 'status': status,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };
}
