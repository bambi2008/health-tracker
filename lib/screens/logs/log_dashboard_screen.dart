import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../providers/diet_provider.dart';
import '../../providers/sleep_provider.dart';
import '../../providers/stress_provider.dart';

class LogDashboardScreen extends StatelessWidget {
  const LogDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('今日日志')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 饮食卡片
            _DietSummaryCard(),
            const SizedBox(height: 16),
            // 睡眠卡片
            _SleepSummaryCard(),
            const SizedBox(height: 16),
            // 压力卡片
            _StressSummaryCard(),
          ],
        ),
      ),
    );
  }
}

class _DietSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DietProvider>(
      builder: (context, provider, _) {
        final today = provider.today;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.restaurant, color: Colors.orange),
                    const SizedBox(width: 8),
                    const Text('饮食记录',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => context.push('/logs/diet/add'),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('添加'),
                    ),
                  ],
                ),
                const Divider(),
                // 饮水量
                Row(
                  children: [
                    const Icon(Icons.water_drop, size: 20, color: Colors.blue),
                    const SizedBox(width: 8),
                    Text(
                      '今日饮水 ${provider.todayWaterMl}ml',
                      style: const TextStyle(fontSize: 16),
                    ),
                    const Spacer(),
                    Text(
                      '${(provider.todayWaterMl / 2000 * 100).round()}%',
                      style: TextStyle(
                          color: provider.todayWaterMl >= 2000
                              ? Colors.green
                              : Colors.orange,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (provider.todayWaterMl / 2000).clamp(0.0, 1.0),
                    minHeight: 8,
                    backgroundColor: Colors.grey.shade200,
                    color: provider.todayWaterMl >= 2000
                        ? Colors.green
                        : Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                Text('建议每日饮水 2000ml',
                    style: TextStyle(
                        fontSize: 11, color: Colors.grey.shade500)),
                if (today.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  ...today.map((l) => ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.circle, size: 8),
                        title: Text(l.mealTypeLabel),
                        trailing:
                            Text(DateFormat('HH:mm').format(l.recordedAt)),
                      )),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SleepSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<SleepProvider>(
      builder: (context, provider, _) {
        final latest = provider.latest;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.bed, color: Colors.indigo),
                    const SizedBox(width: 8),
                    const Text('睡眠记录',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => context.push('/logs/sleep/add'),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('添加'),
                    ),
                  ],
                ),
                const Divider(),
                if (latest != null) ...[
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('睡眠时长',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 13)),
                          Text(latest.durationLabel,
                              style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('质量',
                              style: TextStyle(
                                  color: Colors.grey.shade600, fontSize: 13)),
                          Text(latest.qualityLabel,
                              style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.indigo)),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${DateFormat('HH:mm').format(latest.sleepStart)} 入睡 — '
                    '${DateFormat('HH:mm').format(latest.sleepEnd)} 醒来',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text('还没有睡眠记录',
                          style: TextStyle(color: Colors.grey.shade500)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _StressSummaryCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<StressProvider>(
      builder: (context, provider, _) {
        final avg = provider.todayAvg;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, color: Colors.red),
                    const SizedBox(width: 8),
                    const Text('压力记录',
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: () => context.push('/logs/stress/add'),
                      icon: const Icon(Icons.add, size: 18),
                      label: const Text('添加'),
                    ),
                  ],
                ),
                const Divider(),
                if (avg > 0) ...[
                  Row(
                    children: [
                      Text('今日平均压力',
                          style: TextStyle(
                              color: Colors.grey.shade600, fontSize: 13)),
                      const Spacer(),
                      Text('${avg.toStringAsFixed(1)} / 10',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ] else
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text('今天还没有记录压力',
                          style: TextStyle(color: Colors.grey.shade500)),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
