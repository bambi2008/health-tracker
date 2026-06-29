import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/symptom_provider.dart';
import '../../config/theme.dart';
import '../../widgets/symptom_card.dart';
import '../../widgets/empty_state.dart';

class SymptomListScreen extends StatelessWidget {
  const SymptomListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('症状记录'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month_outlined),
            tooltip: '导出报告',
            onPressed: () => context.push('/export'),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: '设置',
            onPressed: () => context.push('/settings'),
          ),
        ],
      ),
      body: Consumer<SymptomProvider>(
        builder: (context, provider, _) {
          if (provider.symptoms.isEmpty) {
            return EmptyState(
              icon: Icons.healing_outlined,
              title: '还没有症状记录',
              subtitle: '开始记录你的第一条症状\n帮助自己发现身体规律',
              actionLabel: '记录症状',
              onAction: () => context.push('/symptoms/add'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.symptoms.length + 1, // +1 for header card
            itemBuilder: (context, index) {
              if (index == 0) return _buildSummaryCard(context, provider);
              return SymptomCard(
                symptom: provider.symptoms[index - 1],
                onTap: () =>
                    context.push('/symptoms/${provider.symptoms[index - 1].id}'),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/symptoms/add'),
        icon: const Icon(Icons.add),
        label: const Text('记录症状'),
      ),
    );
  }

  Widget _buildSummaryCard(BuildContext context, SymptomProvider provider) {
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);
    final todaySymptoms = provider.symptoms
        .where((s) => s.recordedAt.isAfter(todayStart))
        .toList();
    final weekSymptoms = provider.symptoms
        .where((s) => s.recordedAt
            .isAfter(today.subtract(const Duration(days: 7))))
        .toList();

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _StatItem(
                  label: '今日',
                  value: '${todaySymptoms.length}',
                  unit: '条',
                  color: AppTheme.primaryColor,
                ),
                _StatItem(
                  label: '本周',
                  value: '${weekSymptoms.length}',
                  unit: '条',
                  color: AppTheme.secondaryColor,
                ),
                _StatItem(
                  label: '总计',
                  value: '${provider.symptoms.length}',
                  unit: '条',
                  color: AppTheme.accentColor,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label, value, unit;
  final Color color;
  const _StatItem({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: Colors.grey)),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(value,
                style: Theme.of(context)
                    .textTheme
                    .headlineMedium
                    ?.copyWith(color: color, fontWeight: FontWeight.bold)),
            const SizedBox(width: 2),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(unit,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey)),
            ),
          ],
        ),
      ],
    );
  }
}
