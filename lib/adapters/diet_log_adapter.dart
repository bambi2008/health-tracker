import 'package:hive/hive.dart';
import '../models/diet_log.dart';

class DietLogAdapter extends TypeAdapter<DietLog> {
  @override
  final int typeId = 1;

  @override
  DietLog read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }

    return DietLog(
      id: fields[0] as String?,
      mealType: fields[1] as String? ?? 'breakfast',
      foodItems: fields[2] as String? ?? '[]',
      waterMl: fields[3] as int? ?? 0,
      notes: fields[4] as String? ?? '',
      recordedAt: fields[5] is DateTime
          ? fields[5] as DateTime
          : DateTime.tryParse(fields[5]?.toString() ?? '') ?? DateTime.now(),
      createdAt: fields[6] is DateTime
          ? fields[6] as DateTime
          : DateTime.tryParse(fields[6]?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, DietLog obj) {
    writer.writeByte(7);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.mealType);
    writer.writeByte(2);
    writer.write(obj.foodItems);
    writer.writeByte(3);
    writer.write(obj.waterMl);
    writer.writeByte(4);
    writer.write(obj.notes);
    writer.writeByte(5);
    writer.write(obj.recordedAt);
    writer.writeByte(6);
    writer.write(obj.createdAt);
  }
}
