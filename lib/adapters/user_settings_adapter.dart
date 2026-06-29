import 'package:hive/hive.dart';
import '../models/user_settings.dart';

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 4;

  @override
  UserSettings read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }

    return UserSettings(
      themeMode: fields[0] as String? ?? 'system',
      remindSymptom: fields[1] as bool? ?? true,
      remindTime: fields[2] as String? ?? '20:00',
      remindSleep: fields[3] as bool? ?? false,
      useAnonymous: fields[4] as bool? ?? true,
      nickname: fields[5] as String? ?? '',
      gender: fields[6] as String? ?? 'other',
      birthDate: fields[7] is DateTime ? fields[7] as DateTime : null,
      heightCm: (fields[8] as num?)?.toDouble(),
      weightKg: (fields[9] as num?)?.toDouble(),
      chronicDiseases:
          (fields[10] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer.writeByte(11);
    writer.writeByte(0);
    writer.write(obj.themeMode);
    writer.writeByte(1);
    writer.write(obj.remindSymptom);
    writer.writeByte(2);
    writer.write(obj.remindTime);
    writer.writeByte(3);
    writer.write(obj.remindSleep);
    writer.writeByte(4);
    writer.write(obj.useAnonymous);
    writer.writeByte(5);
    writer.write(obj.nickname);
    writer.writeByte(6);
    writer.write(obj.gender);
    writer.writeByte(7);
    writer.write(obj.birthDate);
    writer.writeByte(8);
    writer.write(obj.heightCm);
    writer.writeByte(9);
    writer.write(obj.weightKg);
    writer.writeByte(10);
    writer.write(obj.chronicDiseases);
  }
}
