import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/sleep_log.dart';
import '../../providers/sleep_provider.dart';

class AddSleepScreen extends StatefulWidget {
  final SleepLog? existing;
  const AddSleepScreen({super.key, this.existing});

  @override
  State<AddSleepScreen> createState() => _AddSleepScreenState();
}

class _AddSleepScreenState extends State<AddSleepScreen> {
  late DateTime _sleepStart;
  late DateTime _sleepEnd;
  late DateTime _recordedDate;
  int _quality = 3;
  int _interruptions = 0;
  final _notesCtrl = TextEditingController();

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _sleepStart = e.sleepStart;
      _sleepEnd = e.sleepEnd;
      _recordedDate = e.recordedDate;
      _quality = e.quality;
      _interruptions = e.interruptions;
      _notesCtrl.text = e.notes;
    } else {
      final now = DateTime.now();
      _sleepEnd = now;
      _sleepStart = now.subtract(const Duration(hours: 8));
      _recordedDate = now;
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  Duration get _duration => _sleepEnd.difference(_sleepStart);

  void _submit() {
    if (_duration.inMinutes <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('入睡时间必须早于醒来时间')),
      );
      return;
    }

    final log = SleepLog(
      id: widget.existing?.id,
      sleepStart: _sleepStart,
      sleepEnd: _sleepEnd,
      quality: _quality,
      interruptions: _interruptions,
      notes: _notesCtrl.text.trim(),
      recordedDate: _recordedDate,
      createdAt: widget.existing?.createdAt,
    );

    final provider = context.read<SleepProvider>();
    provider.add(log);
    context.pop();
  }

  Future<void> _pickTime(bool isStart) async {
    final initial = isStart ? _sleepStart : _sleepEnd;
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );
    if (picked == null) return;
    setState(() {
      final dt = DateTime(
        initial.year,
        initial.month,
        initial.day,
        picked.hour,
        picked.minute,
      );
      if (isStart) {
        _sleepStart = dt;
        // 如果结束时间早于开始，自动调整
        if (_sleepEnd.isBefore(_sleepStart) ||
            _sleepEnd == _sleepStart) {
          _sleepEnd = _sleepStart.add(const Duration(hours: 8));
        }
      } else {
        _sleepEnd = dt;
        if (_sleepEnd.isBefore(_sleepStart)) {
          // 跨天睡眠
          _sleepEnd = _sleepEnd.add(const Duration(days: 1));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final dur = _duration;
    final h = dur.inHours;
    final m = dur.inMinutes % 60;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑睡眠' : '记录睡眠'),
        actions: [
          TextButton(onPressed: _submit, child: const Text('保存')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 时间选择
            const Text('睡眠时间', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _TimeTile(
                    label: '入睡',
                    time: _sleepStart,
                    onTap: () => _pickTime(true),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.arrow_forward),
                ),
                Expanded(
                  child: _TimeTile(
                    label: '醒来',
                    time: _sleepEnd,
                    onTap: () => _pickTime(false),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Center(
              child: Text(
                '睡眠时长: ${h > 0 ? "$h小时" : ""}${m}分钟',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 24),

            // 睡眠质量
            const Text('睡眠质量', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: List.generate(5, (i) {
                final v = i + 1;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => setState(() => _quality = v),
                    child: Column(
                      children: [
                        Icon(
                          v <= _quality ? Icons.star : Icons.star_border,
                          color: v <= _quality
                              ? Colors.amber
                              : Colors.grey.shade400,
                          size: 36,
                        ),
                        Text(_qualityLabel(v),
                            style: TextStyle(fontSize: 11, color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 24),

            // 中断次数
            const Text('夜间醒来次数',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                IconButton(
                  onPressed: _interruptions > 0
                      ? () => setState(() => _interruptions--)
                      : null,
                  icon: const Icon(Icons.remove_circle_outline),
                ),
                Text('$_interruptions 次',
                    style: const TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold)),
                IconButton(
                  onPressed: () => setState(() => _interruptions++),
                  icon: const Icon(Icons.add_circle_outline),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 备注
            const Text('备注', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '梦境、睡眠感受...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _qualityLabel(int v) {
    switch (v) {
      case 1: return '很差';
      case 2: return '较差';
      case 3: return '一般';
      case 4: return '良好';
      case 5: return '很好';
      default: return '';
    }
  }
}

class _TimeTile extends StatelessWidget {
  final String label;
  final DateTime time;
  final VoidCallback onTap;

  const _TimeTile({
    required this.label,
    required this.time,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label, style: TextStyle(color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                  fontSize: 28, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
