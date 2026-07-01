import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../models/symptom.dart';
import '../../providers/symptom_provider.dart';
import '../../config/categories.dart';
import '../../config/theme.dart';
import '../../services/voice_service.dart';

class AddSymptomScreen extends StatefulWidget {
  final Symptom? existing;
  const AddSymptomScreen({super.key, this.existing});

  @override
  State<AddSymptomScreen> createState() => _AddSymptomScreenState();
}

class _AddSymptomScreenState extends State<AddSymptomScreen> {
  // 部位
  String _bodyPart = 'head';
  String _bodyDetail = '';
  String _bodyDetailLabel = '';
  int _selectedCategoryIndex = 0;

  // 严重度
  int _severity = 5;

  // 详情（可选）
  final _descriptionCtrl = TextEditingController();
  String _onsetType = 'gradual';
  int? _durationMin;

  // 触发 & 缓解（可选）
  final List<String> _triggers = [];
  final List<String> _reliefs = [];
  final _voiceCtrl = TextEditingController();
  bool _parsing = false;
  final _triggerCtrl = TextEditingController();
  final _reliefCtrl = TextEditingController();

  late DateTime _recordedAt;

  bool get _isEditing => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final s = widget.existing ?? _routeExtra();
    if (s != null) {
      _bodyPart = s.bodyPart;
      _bodyDetail = s.bodyDetail;
      _bodyDetailLabel = BodyParts.findById(s.bodyDetail)?.label ?? '';
      _severity = s.severity;
      _onsetType = s.onsetType;
      _descriptionCtrl.text = s.description;
      _durationMin = s.durationMin;
      _triggers.addAll(s.triggers);
      _reliefs.addAll(s.reliefs);
      _recordedAt = s.recordedAt;
    } else {
      _recordedAt = DateTime.now();
    }
  }

  Symptom? _routeExtra() {
    try {
      return GoRouterState.of(context).extra as Symptom?;
    } catch (_) {
      return null;
    }
  }

  @override
  void dispose() {
    _descriptionCtrl.dispose();
    _triggerCtrl.dispose();
    _reliefCtrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_bodyDetail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选一个具体部位')),
      );
      return;
    }

    final symptom = Symptom(
      id: widget.existing?.id,
      bodyPart: _bodyPart,
      bodyDetail: _bodyDetail,
      severity: _severity,
      description: _descriptionCtrl.text.trim(),
      onsetType: _onsetType,
      durationMin: _durationMin,
      triggers: List.from(_triggers),
      reliefs: List.from(_reliefs),
      recordedAt: _recordedAt,
      createdAt: widget.existing?.createdAt,
    );

    final provider = context.read<SymptomProvider>();
    if (_isEditing) {
      provider.update(symptom);
    } else {
      provider.add(symptom);
    }
    context.pop();
  }

  List<String> get _categoryNames => BodyParts.categories.keys.toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? '编辑症状' : '记录症状'),
        actions: [
          TextButton.icon(
            onPressed: _bodyDetail.isNotEmpty ? _submit : null,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('保存'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ===== 0. 语音快记 =====
            Card(
              color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.mic, color: Colors.deepPurple, size: 20),
                    const SizedBox(width: 8),
                    const Text('语音快记', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    const Spacer(),
                    if (_parsing)
                      const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)),
                  ]),
                  const SizedBox(height: 4),
                  Text('说说你的感觉，比如"今天头痛7分，可能是熬夜了"', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(height: 8),
                  Row(children: [
                    Expanded(
                      child: TextField(
                        controller: _voiceCtrl,
                        maxLines: 2,
                        decoration: const InputDecoration(
                          hintText: '打字或点右边麦克风说出症状...', isDense: true, border: OutlineInputBorder(),
                          contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(children: [
                      IconButton.filled(
                        onPressed: _parsing ? null : _startVoice,
                        icon: const Icon(Icons.mic, size: 20),
                        style: IconButton.styleFrom(backgroundColor: Colors.deepPurple, foregroundColor: Colors.white),
                      ),
                      const Text('说出', style: TextStyle(fontSize: 9)),
                    ]),
                    const SizedBox(width: 4),
                    Column(children: [
                      IconButton(
                        onPressed: _parsing || _voiceCtrl.text.isEmpty ? null : _parseVoice,
                        icon: const Icon(Icons.auto_awesome, size: 20),
                      ),
                      const Text('解析', style: TextStyle(fontSize: 9)),
                    ]),
                  ]),
                ]),
              ),
            ),
            const SizedBox(height: 16),

            // ===== 1. 身体部位 =====
            const Text('身体部位',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            if (_bodyDetailLabel.isNotEmpty)
              Chip(
                avatar: const Icon(Icons.check_circle, size: 16),
                label: Text('已选: $_bodyDetailLabel'),
                backgroundColor:
                    Theme.of(context).colorScheme.primaryContainer,
                deleteIcon: const Icon(Icons.close, size: 16),
                onDeleted: () {
                  setState(() {
                    _bodyDetail = '';
                    _bodyDetailLabel = '';
                  });
                },
              ),
            const SizedBox(height: 8),

            // 大区选择
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: _categoryNames.asMap().entries.map((e) {
                final sel = _selectedCategoryIndex == e.key;
                return ChoiceChip(
                  label: Text(e.value, style: const TextStyle(fontSize: 13)),
                  selected: sel,
                  onSelected: (_) =>
                      setState(() => _selectedCategoryIndex = e.key),
                );
              }).toList(),
            ),
            const SizedBox(height: 8),

            // 具体部位
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: (BodyParts.categories[_categoryNames[_selectedCategoryIndex]] ?? [])
                  .map((item) {
                final sel = _bodyDetail == item.id;
                return ActionChip(
                  label: Text(item.label, style: const TextStyle(fontSize: 13)),
                  backgroundColor: sel
                      ? AppTheme.bodyPartColor(item.category).withValues(alpha: 0.2)
                      : null,
                  side: sel
                      ? BorderSide(color: AppTheme.bodyPartColor(item.category))
                      : null,
                  onPressed: () {
                    setState(() {
                      _bodyPart = item.category;
                      _bodyDetail = item.id;
                      _bodyDetailLabel = item.label;
                    });
                  },
                );
              }).toList(),
            ),

            const SizedBox(height: 24),

            // ===== 2. 严重度 =====
            const Text('严重程度',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 4),
            Text(_severityLabel,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Text('1',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
                Expanded(
                  child: Slider(
                    value: _severity.toDouble(),
                    min: 1,
                    max: 10,
                    divisions: 9,
                    label: '$_severity',
                    activeColor: AppTheme.severityColor(_severity),
                    onChanged: (v) => setState(() => _severity = v.round()),
                  ),
                ),
                Text('10',
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ],
            ),
            Center(
              child: Text(
                '$_severity / 10   $_severityLabel',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.severityColor(_severity)),
              ),
            ),

            const SizedBox(height: 24),

            // ===== 3. 发作详情（可折叠） =====
            _SectionHeader(
              title: '发作详情（可选）',
              initiallyExpanded: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 发作类型
                  const Text('发作类型',
                      style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    children: OnsetTypes.list.map((o) {
                      return ChoiceChip(
                        label: Text(o.label, style: const TextStyle(fontSize: 13)),
                        selected: _onsetType == o.id,
                        onSelected: (_) =>
                            setState(() => _onsetType = o.id),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 12),

                  // 持续时间
                  TextField(
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '持续时长（分钟）',
                      hintText: '不确定可留空',
                      suffixText: '分钟',
                      isDense: true,
                    ),
                    onChanged: (v) => _durationMin = int.tryParse(v),
                  ),
                  const SizedBox(height: 12),

                  // 时间
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    dense: true,
                    leading: const Icon(Icons.access_time, size: 20),
                    title: Text(
                      '${_recordedAt.month}月${_recordedAt.day}日 '
                      '${_recordedAt.hour.toString().padLeft(2, '0')}:${_recordedAt.minute.toString().padLeft(2, '0')}',
                      style: const TextStyle(fontSize: 14),
                    ),
                    trailing: const Icon(Icons.edit, size: 16),
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _recordedAt,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                      );
                      if (d == null || !mounted) return;
                      final t = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.fromDateTime(_recordedAt),
                      );
                      if (t == null) return;
                      setState(() {
                        _recordedAt = DateTime(
                            d.year, d.month, d.day, t.hour, t.minute);
                      });
                    },
                  ),
                  const SizedBox(height: 12),

                  // 描述
                  TextField(
                    controller: _descriptionCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: '症状描述',
                      hintText: '描述感觉、变化、对生活的影响...',
                      isDense: true,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ===== 4. 触发 & 缓解（可折叠） =====
            _SectionHeader(
              title: '触发因素 & 缓解方式（可选）',
              initiallyExpanded: false,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 已选的触发因素
                  if (_triggers.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: _triggers.map((t) {
                        return Chip(
                          label: Text(t, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.orange.shade50,
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () =>
                              setState(() => _triggers.remove(t)),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _triggerCtrl,
                          decoration: const InputDecoration(
                            hintText: '输入触发因素',
                            isDense: true,
                          ),
                          onSubmitted: _addTrigger,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _addTrigger(_triggerCtrl.text),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildQuickTags(
                    '食物:',
                    TriggerPresets.foods,
                    _triggers,
                  ),
                  _buildQuickTags(
                    '活动:',
                    TriggerPresets.activities,
                    _triggers,
                  ),
                  _buildQuickTags(
                    '情绪:',
                    TriggerPresets.emotions,
                    _triggers,
                  ),
                  const SizedBox(height: 16),

                  // 已选的缓解方式
                  if (_reliefs.isNotEmpty)
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      children: _reliefs.map((r) {
                        return Chip(
                          label: Text(r, style: const TextStyle(fontSize: 12)),
                          backgroundColor: Colors.green.shade50,
                          deleteIcon: const Icon(Icons.close, size: 14),
                          onDeleted: () =>
                              setState(() => _reliefs.remove(r)),
                        );
                      }).toList(),
                    ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _reliefCtrl,
                          decoration: const InputDecoration(
                            hintText: '输入缓解方式',
                            isDense: true,
                          ),
                          onSubmitted: _addRelief,
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        onPressed: () => _addRelief(_reliefCtrl.text),
                        icon: const Icon(Icons.add),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  _buildQuickTags(
                    '常用:',
                    ReliefPresets.list,
                    _reliefs,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ===== 提交按钮 =====
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed:
                    _bodyDetail.isNotEmpty ? _submit : null,
                icon: const Icon(Icons.check),
                label: Text(_isEditing ? '保存修改' : '完成记录'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _addTrigger(String text) {
    final t = text.trim();
    if (t.isNotEmpty && !_triggers.contains(t)) {
      setState(() {
        _triggers.add(t);
        _triggerCtrl.clear();
      });
    }
  }

  void _addRelief(String text) {
    final t = text.trim();
    if (t.isNotEmpty && !_reliefs.contains(t)) {
      setState(() {
        _reliefs.add(t);
        _reliefCtrl.clear();
      });
    }
  }

  Widget _buildQuickTags(
      String label, List<String> items, List<String> selected) {
    final available = items.where((i) => !selected.contains(i)).toList();
    if (available.isEmpty) return const SizedBox();
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 40,
            child: Text(label,
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
          ),
          Expanded(
            child: Wrap(
              spacing: 4,
              runSpacing: 2,
              children: available.take(6).map((item) {
                return InkWell(
                  onTap: () => setState(() => selected.add(item)),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    margin: const EdgeInsets.only(bottom: 2),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(item, style: const TextStyle(fontSize: 11)),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _startVoice() {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      title: const Text('💬 语音快记'),
      content: const Text('在输入框中用自然语言描述你的症状，\n比如：\n\n"今天头痛7分，昨晚熬夜了，\n左太阳穴跳痛了半小时"\n\n点击 ✨ 解析，AI会自动填好下面的表单'),
      actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('知道了'))],
    ));
  }

  Future<void> _parseVoice() async {
    setState(() => _parsing = true);
    final result = await VoiceService.parseVoice(_voiceCtrl.text);
    setState(() => _parsing = false);

    if (result == null || result.containsKey('error')) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('解析失败，试试更详细的描述')),
      );
      return;
    }

    setState(() {
      _bodyPart = result['body_part'] ?? 'general';
      _bodyDetail = result['body_detail'] ?? 'general';
      _bodyDetailLabel = result['body_detail'] ?? '';
      _severity = result['severity'] ?? 5;
      _onsetType = result['onset_type'] ?? 'gradual';
      _descriptionCtrl.text = result['description'] ?? _voiceCtrl.text;
      if (result['duration_min'] != null) _durationMin = result['duration_min'];
      if (result['triggers'] != null) {
        for (final t in (result['triggers'] as List)) {
          if (!_triggers.contains(t.toString())) _triggers.add(t.toString());
        }
      }
      if (result['reliefs'] != null) {
        for (final r in (result['reliefs'] as List)) {
          if (!_reliefs.contains(r.toString())) _reliefs.add(r.toString());
        }
      }
    });
  }

  String get _severityLabel {
    if (_severity <= 2) return '轻微 — 几乎不影响';
    if (_severity <= 4) return '轻度 — 可以忍受';
    if (_severity <= 6) return '中度 — 明显不适';
    if (_severity <= 8) return '重度 — 影响生活';
    return '剧烈 — 非常痛苦';
  }
}

/// 可折叠区块
class _SectionHeader extends StatefulWidget {
  final String title;
  final Widget child;
  final bool initiallyExpanded;

  const _SectionHeader({
    required this.title,
    required this.child,
    this.initiallyExpanded = false,
  });

  @override
  State<_SectionHeader> createState() => _SectionHeaderState();
}

class _SectionHeaderState extends State<_SectionHeader> {
  late bool _expanded;

  @override
  void initState() {
    super.initState();
    _expanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        InkWell(
          onTap: () => setState(() => _expanded = !_expanded),
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              children: [
                Icon(
                  _expanded ? Icons.expand_less : Icons.expand_more,
                  size: 20,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  widget.title,
                  style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ),
        if (_expanded) widget.child,
      ],
    );
  }
}
