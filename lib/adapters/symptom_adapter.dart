import 'package:hive/hive.dart';
import '../models/symptom.dart';

class SymptomAdapter extends TypeAdapter<Symptom> {
  @override
  final int typeId = 0;

  @override
  Symptom read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }

    return Symptom(
      id: fields[0] as String?,
      bodyPart: fields[1] as String? ?? 'head',
      bodyDetail: fields[2] as String? ?? '',
      severity: fields[3] as int? ?? 5,
      description: fields[4] as String? ?? '',
      onsetType: fields[5] as String? ?? 'gradual',
      durationMin: fields[6] as int?,
      triggers: (fields[7] as List<dynamic>?)?.cast<String>() ?? [],
      reliefs: (fields[8] as List<dynamic>?)?.cast<String>() ?? [],
      imagePaths: (fields[9] as List<dynamic>?)?.cast<String>() ?? [],
      recordedAt: fields[10] is DateTime
          ? fields[10] as DateTime
          : DateTime.tryParse(fields[10]?.toString() ?? '') ?? DateTime.now(),
      createdAt: fields[11] is DateTime
          ? fields[11] as DateTime
          : DateTime.tryParse(fields[11]?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, Symptom obj) {
    writer.writeByte(12); // field count
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.bodyPart);
    writer.writeByte(2);
    writer.write(obj.bodyDetail);
    writer.writeByte(3);
    writer.write(obj.severity);
    writer.writeByte(4);
    writer.write(obj.description);
    writer.writeByte(5);
    writer.write(obj.onsetType);
    writer.writeByte(6);
    writer.write(obj.durationMin);
    writer.writeByte(7);
    writer.write(obj.triggers);
    writer.writeByte(8);
    writer.write(obj.reliefs);
    writer.writeByte(9);
    writer.write(obj.imagePaths);
    writer.writeByte(10);
    writer.write(obj.recordedAt);
    writer.writeByte(11);
    writer.write(obj.createdAt);
  }
}
