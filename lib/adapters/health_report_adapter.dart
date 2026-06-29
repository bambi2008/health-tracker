import 'package:hive/hive.dart';
import '../models/health_report.dart';

class HealthReportAdapter extends TypeAdapter<HealthReport> {
  @override
  final int typeId = 5;

  @override
  HealthReport read(BinaryReader reader) {
    final numFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (int i = 0; i < numFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }

    return HealthReport(
      id: fields[0] as String?,
      reportType: fields[1] as String? ?? 'weekly',
      dateFrom: fields[2] is DateTime
          ? fields[2] as DateTime
          : DateTime.tryParse(fields[2]?.toString() ?? '') ??
              DateTime.now().subtract(const Duration(days: 7)),
      dateTo: fields[3] is DateTime
          ? fields[3] as DateTime
          : DateTime.tryParse(fields[3]?.toString() ?? '') ?? DateTime.now(),
      contentMarkdown: fields[4] as String? ?? '',
      pdfPath: fields[5] as String?,
      createdAt: fields[6] is DateTime
          ? fields[6] as DateTime
          : DateTime.tryParse(fields[6]?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter writer, HealthReport obj) {
    writer.writeByte(7);
    writer.writeByte(0);
    writer.write(obj.id);
    writer.writeByte(1);
    writer.write(obj.reportType);
    writer.writeByte(2);
    writer.write(obj.dateFrom);
    writer.writeByte(3);
    writer.write(obj.dateTo);
    writer.writeByte(4);
    writer.write(obj.contentMarkdown);
    writer.writeByte(5);
    writer.write(obj.pdfPath);
    writer.writeByte(6);
    writer.write(obj.createdAt);
  }
}
