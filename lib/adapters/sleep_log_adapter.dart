import 'package:hive/hive.dart';
import '../models/sleep_log.dart';

class SleepLogAdapter extends TypeAdapter<SleepLog> {
  @override
  final int typeId = 2;

  @override
  SleepLog read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }

    final now = DateTime.now();
    return SleepLog(
      id: fields[0] as String?,
      sleepStart: fields[1] is DateTime
          ? fields[1] as DateTime
          : DateTime.tryParse(fields[1]?.toString() ?? '') ??
              now.subtract(const Duration(hours: 8)),
      sleepEnd: fields[2] is DateTime
          ? fields[2] as DateTime
          : DateTime.tryParse(fields[2]?.toString() ?? '') ?? now,
      quality: fields[3] as int? ?? 3,
      interruptions: fields[4] as int? ?? 0,
      notes: fields[5] as String? ?? '',
      recordedDate: fields[6] is DateTime
          ? fields[6] as DateTime
          : DateTime.tryParse(fields[6]?.toString() ?? '') ?? now,
      createdAt: fields[7] is DateTime
          ? fields[7] as DateTime
          : DateTime.tryParse(fields[7]?.toString() ?? '') ?? now,
    );
  }

  @override
  void write(BinaryWriter writer, SleepLog obj) {
    writer.writeByte(8);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.sleepStart);
    writer.writeByte(2);
    writer.write(obj.sleepEnd);
    writer.writeByte(3);
    writer.write(obj.quality);
    writer.writeByte(4);
    writer.write(obj.interruptions);
    writer.writeByte(5);
    writer.write(obj.notes);
    writer.writeByte(6);
    writer.write(obj.recordedDate);
    writer.writeByte(7);
    writer.write(obj.createdAt);
  }
}
