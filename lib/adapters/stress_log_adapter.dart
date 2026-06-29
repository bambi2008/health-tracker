import 'package:hive/hive.dart';
import '../models/stress_log.dart';

class StressLogAdapter extends TypeAdapter<StressLog> {
  @override
  final int typeId = 3;

  @override
  StressLog read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }

    return StressLog(
      id: fields[0] as String?,
      level: fields[1] as int? ?? 5,
      source: fields[2] as String? ?? 'other',
      notes: fields[3] as String? ?? '',
      recordedAt: fields[4] is DateTime
          ? fields[4] as DateTime
          : DateTime.tryParse(fields[4]?.toString() ?? '') ?? DateTime.now(),
      createdAt: fields[5] is DateTime
          ? fields[5] as DateTime
          : DateTime.tryParse(fields[5]?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, StressLog obj) {
    writer.writeByte(6);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.level);
    writer.writeByte(2);
    writer.write(obj.source);
    writer.writeByte(3);
    writer.write(obj.notes);
    writer.writeByte(4);
    writer.write(obj.recordedAt);
    writer.writeByte(5);
    writer.write(obj.createdAt);
  }
}
