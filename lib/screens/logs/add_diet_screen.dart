import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/diet_log.dart';
import '../../providers/diet_provider.dart';
import '../../config/categories.dart';

class AddDietScreen extends StatefulWidget {
  final DietLog? existing;
  const AddDietScreen({super.key, this.existing});

  @override
  State<AddDietScreen> createState() => _AddDietScreenState();
}

class _AddDietScreenState extends State<AddDietScreen> {
  String _mealType = 'breakfast';
  int _waterMl = 0;
  final _notesCtrl = TextEditingController();
  late DateTime _recordedAt;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    if (e != null) {
      _mealType = e.mealType;
      _waterMl = e.waterMl;
      _notesCtrl.text = e.notes;
      _recordedAt = e.recordedAt;
    } else {
      _recordedAt = DateTime.now();
    }
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    final log = DietLog(
      id: widget.existing?.id,
      mealType: _mealType,
      waterMl: _waterMl,
      notes: _notesCtrl.text.trim(),
      recordedAt: _recordedAt,
      createdAt: widget.existing?.createdAt,
    );

    final provider = context.read<DietProvider>();
    if (_isEditing) {
      provider.update(log);
    } else {
      provider.add(log);
    }
    context.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑饮食' : '记录饮食'),
        actions: [
          TextButton(onPressed: _submit, child: const Text('保存')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('餐型', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: MealTypes.list
                  .map((m) => ButtonSegment(
                        value: m.id,
                        label: Text(m.label),
                        icon: Icon(m.icon),
                      ))
                  .toList(),
              selected: {_mealType},
              onSelectionChanged: (v) => setState(() => _mealType = v.first),
            ),
            const SizedBox(height: 24),

            const Text('饮水量 (ml)',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Slider(
                    value: _waterMl.toDouble(),
                    min: 0,
                    max: 1000,
                    divisions: 20,
                    label: '${_waterMl}ml',
                    onChanged: (v) =>
                        setState(() => _waterMl = v.round()),
                  ),
                ),
                SizedBox(
                  width: 80,
                  child: Text('${_waterMl}ml',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [100, 200, 300, 500].map((ml) {
                return ActionChip(
                  label: Text('${ml}ml'),
                  onPressed: () =>
                      setState(() => _waterMl = (_waterMl + ml).clamp(0, 4000)),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            const Text('记录时间',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.access_time),
              title: Text(
                '${_recordedAt.year}-${_recordedAt.month.toString().padLeft(2, '0')}-${_recordedAt.day.toString().padLeft(2, '0')} '
                '${_recordedAt.hour.toString().padLeft(2, '0')}:${_recordedAt.minute.toString().padLeft(2, '0')}',
              ),
              onTap: () async {
                final ctx = context;
                final date = await showDatePicker(
                  context: ctx,
                  initialDate: _recordedAt,
                  firstDate: DateTime(2000),
                  lastDate: DateTime.now(),
                );
                if (date == null || !mounted) return;
                final time = await showTimePicker(
                  context: ctx,
                  initialTime: TimeOfDay.fromDateTime(_recordedAt),
                );
                if (time == null) return;
                setState(() {
                  _recordedAt = DateTime(
                      date.year, date.month, date.day, time.hour, time.minute);
                });
              },
            ),
            const SizedBox(height: 24),

            const Text('备注', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '吃了什么？有什么特别的...',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
