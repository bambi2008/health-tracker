import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/stress_log.dart';
import '../../providers/stress_provider.dart';
import '../../config/categories.dart';
import '../../config/theme.dart';

class AddStressScreen extends StatefulWidget {
  const AddStressScreen({super.key});

  @override
  State<AddStressScreen> createState() => _AddStressScreenState();
}

class _AddStressScreenState extends State<AddStressScreen> {
  int _level = 5;
  String _source = 'other';
  final _notesCtrl = TextEditingController();

  void _submit() {
    final log = StressLog(
      level: _level,
      source: _source,
      notes: _notesCtrl.text.trim(),
    );
    context.read<StressProvider>().add(log);
    context.pop();
  }

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.severityColor(_level);
    return Scaffold(
      appBar: AppBar(
        title: const Text('记录压力'),
        actions: [
          TextButton(onPressed: _submit, child: const Text('保存')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 压力等级
            Center(
              child: Column(
                children: [
                  Text('当前压力等级',
                      style: TextStyle(fontSize: 16, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Text('$_level / 10',
                      style: TextStyle(
                          fontSize: 48, fontWeight: FontWeight.bold, color: color)),
                  Text(_levelLabel,
                      style: TextStyle(fontSize: 16, color: color)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Slider(
              value: _level.toDouble(),
              min: 1, max: 10, divisions: 9,
              label: '$_level',
              activeColor: color,
              onChanged: (v) => setState(() => _level = v.round()),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1 很轻松', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text('10 压力爆表', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
            const SizedBox(height: 32),

            // 压力来源
            const Text('压力来源', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: StressSources.list
                  .map((s) => ButtonSegment(
                        value: s.id,
                        label: Text(s.label),
                        icon: Icon(s.icon),
                      ))
                  .toList(),
              selected: {_source},
              onSelectionChanged: (v) => setState(() => _source = v.first),
            ),
            const SizedBox(height: 24),

            const Text('备注', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              controller: _notesCtrl,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: '发生了什么...',
              ),
            ),
          ],
        ),
      ),
    );
  }

  String get _levelLabel {
    if (_level <= 2) return '很轻松';
    if (_level <= 4) return '有点压力';
    if (_level <= 6) return '中等压力';
    if (_level <= 8) return '压力较大';
    return '压力非常大';
  }
}
