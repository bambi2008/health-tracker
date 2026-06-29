import 'package:hive/hive.dart';
import '../models/medical_case.dart';

class MedicalCaseAdapter extends TypeAdapter<MedicalCase> {
  @override
  final int typeId = 6;

  @override
  MedicalCase read(BinaryReader reader) {
    final n = reader.readByte();
    final f = <int, dynamic>{};
    for (var i = 0; i < n; i++) { f[reader.readByte()] = reader.read(); }
    return MedicalCase(
      id: f[0] as String?, title: f[1] as String? ?? '',
      content: f[2] as String? ?? '',
      symptomTags: (f[3] as List<dynamic>?)?.cast<String>() ?? [],
      bodyParts: (f[4] as List<dynamic>?)?.cast<String>() ?? [],
      durationTag: f[5] as String? ?? 'months',
      diagnosisStatus: f[6] as String? ?? 'undiagnosed',
      doctorVisits: f[7] as int? ?? 0,
      upvoteCount: f[8] as int? ?? 0,
      commentCount: f[9] as int? ?? 0,
      viewCount: f[10] as int? ?? 0,
      isAnonymous: f[11] as bool? ?? true,
      status: f[12] as String? ?? 'published',
      createdAt: f[13] is DateTime ? f[13] : DateTime.now(),
      updatedAt: f[14] is DateTime ? f[14] : DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter w, MedicalCase o) {
    w.writeByte(15);
    w.writeByte(0); w.write(o.id);
    w.writeByte(1); w.write(o.title);
    w.writeByte(2); w.write(o.content);
    w.writeByte(3); w.write(o.symptomTags);
    w.writeByte(4); w.write(o.bodyParts);
    w.writeByte(5); w.write(o.durationTag);
    w.writeByte(6); w.write(o.diagnosisStatus);
    w.writeByte(7); w.write(o.doctorVisits);
    w.writeByte(8); w.write(o.upvoteCount);
    w.writeByte(9); w.write(o.commentCount);
    w.writeByte(10); w.write(o.viewCount);
    w.writeByte(11); w.write(o.isAnonymous);
    w.writeByte(12); w.write(o.status);
    w.writeByte(13); w.write(o.createdAt);
    w.writeByte(14); w.write(o.updatedAt);
  }
}
