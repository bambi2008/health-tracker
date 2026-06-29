import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../models/symptom.dart';
import '../../providers/symptom_provider.dart';
import '../../config/theme.dart';

class SymptomDetailScreen extends StatelessWidget {
  final String symptomId;
  const SymptomDetailScreen({super.key, required this.symptomId});

  @override
  Widget build(BuildContext context) {
    return Consumer<SymptomProvider>(
      builder: (context, provider, _) {
        final symptom = provider.getById(symptomId);
        if (symptom == null) {
          return Scaffold(
            appBar: AppBar(),
            body: const Center(child: Text('症状未找到')),
          );
        }
        return _SymptomDetailView(symptom: symptom);
      },
    );
  }
}

class _SymptomDetailView extends StatelessWidget {
  final Symptom symptom;
  const _SymptomDetailView({required this.symptom});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat('MM/dd HH:mm');
    return Scaffold(
      appBar: AppBar(
        title: Text(symptom.bodyDetailLabel),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: '编辑',
            onPressed: () async {
              await context.push('/symptoms/add', extra: symptom);
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outlined),
            tooltip: '删除',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 严重度指示条
            _buildSeverityBar(context),
            const SizedBox(height: 24),

            // 基本信息卡片
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _DetailRow(
                        icon: Icons.access_time,
                        label: '发生时间',
                        value: fmt.format(symptom.recordedAt)),
                    const Divider(),
                    _DetailRow(
                        icon: Icons.speed,
                        label: '发作类型',
                        value: symptom.onsetLabel),
                    const Divider(),
                    _DetailRow(
                        icon: Icons.timer,
                        label: '持续时间',
                        value: symptom.durationLabel),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 描述
            if (symptom.description.isNotEmpty) ...[
              const Text('症状描述',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(symptom.description,
                      style: const TextStyle(fontSize: 15, height: 1.6)),
                ),
              ),
              const SizedBox(height: 16),
            ],

            // 触发因素
            if (symptom.triggers.isNotEmpty) ...[
              const Text('可能触发因素',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: symptom.triggers
                    .map((t) => Chip(
                          label: Text(t),
                          backgroundColor:
                              Colors.orange.shade50,
                        ))
                    .toList(),
              ),
              const SizedBox(height: 16),
            ],

            // 缓解方式
            if (symptom.reliefs.isNotEmpty) ...[
              const Text('缓解方式',
                  style:
                      TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: symptom.reliefs
                    .map((r) => Chip(
                          label: Text(r),
                          backgroundColor:
                              Colors.green.shade50,
                        ))
                    .toList(),
              ),
            ],

            const SizedBox(height: 24),
            Text('记录时间: ${fmt.format(symptom.createdAt)}',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildSeverityBar(BuildContext context) {
    final color = AppTheme.severityColor(symptom.severity);
    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('严重程度',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(symptom.severityLabel,
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: color)),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: symptom.severity / 10,
                minHeight: 12,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation(color),
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('1 轻微',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                Text('10 剧烈',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('删除这条症状记录？'),
        content: const Text('删除后不可恢复'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              context.read<SymptomProvider>().delete(symptom.id);
              Navigator.pop(ctx);
              if (context.mounted) context.pop();
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('删除'),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(color: Colors.grey.shade600)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
      ],
    );
  }
}
