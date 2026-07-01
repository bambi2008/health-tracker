import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/symptom_provider.dart';
import '../../providers/sleep_provider.dart';
import '../../providers/stress_provider.dart';
import '../../config/theme.dart';
import '../../widgets/symptom_card.dart';
import '../../widgets/empty_state.dart';

class SymptomListScreen extends StatelessWidget {
  const SymptomListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SymptomProvider>();
    final slp = context.watch<SleepProvider>();
    final stp = context.watch<StressProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('健康'),
        actions: [
          IconButton(icon: const Icon(Icons.calendar_month_outlined),
              tooltip: '报告', onPressed: () => context.push('/export')),
          IconButton(icon: const Icon(Icons.settings_outlined),
              tooltip: '设置', onPressed: () => context.push('/settings')),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {},
        child: sp.symptoms.isEmpty
            ? _buildEmpty(context)
            : ListView(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                children: [
                  _TodayHeader(sp: sp, slp: slp, stp: stp),
                  const SizedBox(height: 24),
                  _SectionTitle('最近症状'),
                  ...sp.symptoms.take(5).map((s) => SymptomCard(
                    symptom: s,
                    onTap: () => context.push('/symptoms/${s.id}'),
                  )),
                  if (sp.symptoms.length > 5)
                    Center(
                      child: TextButton(
                        onPressed: () {},
                        child: Text('查看全部 ${sp.symptoms.length} 条'),
                      ),
                    ),
                ],
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/symptoms/add'),
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 120, height: 120,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.healing, size: 56, color: AppTheme.primary),
          ),
          const SizedBox(height: 32),
          const Text('开始记录你的健康',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Text('每次记录都是在帮助自己\n发现身体的变化规律',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.grey.shade500, height: 1.6)),
          const SizedBox(height: 40),
          ElevatedButton.icon(
            onPressed: () => context.push('/symptoms/add'),
            icon: const Icon(Icons.add),
            label: const Text('记录第一条症状'),
          ),
        ]),
      ),
    );
  }
}

// ===== 今日概览头部 =====
class _TodayHeader extends StatelessWidget {
  final SymptomProvider sp;
  final SleepProvider slp;
  final StressProvider stp;

  const _TodayHeader({required this.sp, required this.slp, required this.stp});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final todaySymptoms = sp.symptoms.where((s) => s.recordedAt.isAfter(todayStart)).toList();
    final latestSleep = slp.latest;
    final todayStress = stp.todayAvg;

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const SizedBox(height: 8),
      Text('今天', style: TextStyle(fontSize: 13, color: Colors.grey.shade500, fontWeight: FontWeight.w500)),
      const SizedBox(height: 12),

      // 三大指标卡片
      Row(children: [
        // 症状
        Expanded(
          child: _MetricCard(
            icon: Icons.healing,
            color: AppTheme.primary,
            value: '${todaySymptoms.length}',
            unit: '条症状',
            subtitle: todaySymptoms.isEmpty
                ? '今天还没记录'
                : '均 ${(todaySymptoms.fold<int>(0, (a,s) => a + s.severity) / todaySymptoms.length.clamp(1, 999)).toStringAsFixed(1)} 分',
          ),
        ),
        const SizedBox(width: 10),
        // 睡眠
        Expanded(
          child: _MetricCard(
            icon: Icons.bedtime,
            color: const Color(0xFF4A7C96),
            value: latestSleep != null ? '${latestSleep.duration.inHours}h${latestSleep.duration.inMinutes % 60}m' : '--',
            unit: '睡眠',
            subtitle: latestSleep != null ? '质量 ${latestSleep.quality}/5' : '还没记录',
          ),
        ),
        const SizedBox(width: 10),
        // 压力
        Expanded(
          child: _MetricCard(
            icon: Icons.self_improvement,
            color: const Color(0xFFD4746B),
            value: todayStress > 0 ? '${todayStress.toStringAsFixed(0)}' : '--',
            unit: '压力',
            subtitle: todayStress > 0 ? (todayStress > 6 ? '偏高' : '正常') : '还没记录',
          ),
        ),
      ]),

      // 一句话洞察
      if (todaySymptoms.isNotEmpty || latestSleep != null || todayStress > 0)
        Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 16),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(children: [
            const Icon(Icons.lightbulb_outline, color: AppTheme.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(child: Text(
              _insight(todaySymptoms, latestSleep, todayStress),
              style: const TextStyle(fontSize: 14, height: 1.5),
            )),
          ]),
        ),
    ]);
  }

  String _insight(List symptoms, dynamic sleep, double stress) {
    final parts = <String>[];
    if (symptoms.isNotEmpty) {
      int sum = 0;
      for (final s in symptoms) { sum += s.severity as int; }
      final avg = symptoms.isEmpty ? 0 : sum ~/ symptoms.length;
      if (avg >= 6) parts.add('今天症状较明显');
      else if (avg <= 3) parts.add('今天症状较轻');
      else parts.add('今天症状中等');
    }
    if (sleep != null && sleep.quality <= 2) parts.add('睡眠不足可能影响恢复');
    if (stress > 7) parts.add('压力偏高，注意调节');
    if (sleep != null && sleep.quality >= 4 && stress < 5) parts.add('睡眠和压力状态不错');
    if (parts.isEmpty) parts.add('记录更多数据以获取洞察');
    return parts.join(' · ');
  }
}

class _MetricCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value, unit, subtitle;
  const _MetricCard({required this.icon, required this.color, required this.value, required this.unit, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(height: 12),
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: const Color(0xFF1A1A2E))),
        const SizedBox(height: 2),
        Text(unit, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
        const SizedBox(height: 2),
        Text(subtitle, style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
      ]),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1A1A2E))),
    );
  }
}
