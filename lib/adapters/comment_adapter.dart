import 'package:hive/hive.dart';
import '../models/comment.dart';

class CommentAdapter extends TypeAdapter<Comment> {
  @override
  final int typeId = 7;

  @override
  Comment read(BinaryReader r) {
    final n = r.readByte();
    final f = <int, dynamic>{};
    for (var i = 0; i < n; i++) { f[r.readByte()] = r.read(); }
    return Comment(
      id: f[0] as String?, caseId: f[1] as String? ?? '',
      content: f[2] as String? ?? '', isAnonymous: f[3] as bool? ?? true,
      createdAt: f[4] is DateTime ? f[4] : DateTime.now(),
    );
  }

  @override
  void write(BinaryWriter w, Comment o) {
    w.writeByte(5);
    w.writeByte(0); w.write(o.id);
    w.writeByte(1); w.write(o.caseId);
    w.writeByte(2); w.write(o.content);
    w.writeByte(3); w.write(o.isAnonymous);
    w.writeByte(4); w.write(o.createdAt);
  }
}
