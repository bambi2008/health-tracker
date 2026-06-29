import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_settings_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nicknameCtrl = TextEditingController();
  final _heightCtrl = TextEditingController();
  final _weightCtrl = TextEditingController();
  final _diseaseCtrl = TextEditingController();
  String _gender = 'other';
  DateTime? _birthDate;
  List<String> _chronicDiseases = [];

  @override
  void initState() {
    super.initState();
    final s = context.read<UserSettingsProvider>().settings;
    _nicknameCtrl.text = s.nickname;
    _gender = s.gender;
    _birthDate = s.birthDate;
    _heightCtrl.text = s.heightCm?.toString() ?? '';
    _weightCtrl.text = s.weightKg?.toString() ?? '';
    _chronicDiseases = List.from(s.chronicDiseases);
  }

  @override
  void dispose() {
    _nicknameCtrl.dispose();
    _heightCtrl.dispose();
    _weightCtrl.dispose();
    _diseaseCtrl.dispose();
    super.dispose();
  }

  void _save() {
    final prov = context.read<UserSettingsProvider>();
    prov.setNickname(_nicknameCtrl.text.trim());
    prov.setGender(_gender);
    prov.setBirthDate(_birthDate);
    prov.setHeight(double.tryParse(_heightCtrl.text.trim()));
    prov.setWeight(double.tryParse(_weightCtrl.text.trim()));
    prov.setChronicDiseases(_chronicDiseases);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('已保存')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('个人健康档案'),
        actions: [
          TextButton(onPressed: _save, child: const Text('保存')),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 基本信息
            const Text('基本信息',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextField(
              controller: _nicknameCtrl,
              decoration: const InputDecoration(
                labelText: '昵称',
                hintText: '给自己起个名字',
              ),
            ),
            const SizedBox(height: 16),

            // 性别
            const Text('性别',
                style: TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'male', label: Text('男')),
                ButtonSegment(value: 'female', label: Text('女')),
                ButtonSegment(value: 'other', label: Text('其他')),
              ],
              selected: {_gender},
              onSelectionChanged: (v) =>
                  setState(() => _gender = v.first),
            ),
            const SizedBox(height: 16),

            // 出生日期
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cake),
              title: const Text('出生日期'),
              trailing: Text(
                _birthDate != null
                    ? '${_birthDate!.year}-${_birthDate!.month.toString().padLeft(2, '0')}-${_birthDate!.day.toString().padLeft(2, '0')}'
                    : '未设置',
              ),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _birthDate ?? DateTime(1990),
                  firstDate: DateTime(1920),
                  lastDate: DateTime.now(),
                );
                if (d != null) setState(() => _birthDate = d);
              },
            ),
            const SizedBox(height: 16),

            // 身高体重
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _heightCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '身高 (cm)',
                      hintText: '170',
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextField(
                    controller: _weightCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: '体重 (kg)',
                      hintText: '65',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // BMI 实时计算
            Consumer<UserSettingsProvider>(
              builder: (context, prov, _) {
                final bmi = prov.settings.bmi;
                final bmiLabel = prov.settings.bmiLabel;
                if (bmi == null) return const SizedBox();
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        const Text('BMI: ',
                            style: TextStyle(fontWeight: FontWeight.bold)),
                        Text(bmi.toStringAsFixed(1),
                            style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        if (bmiLabel != null)
                          Chip(label: Text(bmiLabel)),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // 慢性病
            const Text('慢性病/基础疾病',
                style: TextStyle(
                    fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _diseaseCtrl,
                    decoration: const InputDecoration(
                      hintText: '输入疾病名称',
                    ),
                    onSubmitted: (v) {
                      if (v.trim().isNotEmpty &&
                          !_chronicDiseases.contains(v.trim())) {
                        setState(() {
                          _chronicDiseases.add(v.trim());
                          _diseaseCtrl.clear();
                        });
                      }
                    },
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: () {
                    final v = _diseaseCtrl.text.trim();
                    if (v.isNotEmpty && !_chronicDiseases.contains(v)) {
                      setState(() {
                        _chronicDiseases.add(v);
                        _diseaseCtrl.clear();
                      });
                    }
                  },
                  icon: const Icon(Icons.add),
                ),
              ],
            ),
            if (_chronicDiseases.isNotEmpty) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _chronicDiseases.map((d) {
                  return Chip(
                    label: Text(d),
                    deleteIcon: const Icon(Icons.close, size: 16),
                    onDeleted: () => setState(
                        () => _chronicDiseases.remove(d)),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
