import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../providers/symptom_provider.dart';
import '../../providers/sleep_provider.dart';
import '../../providers/stress_provider.dart';
import '../../providers/user_settings_provider.dart';
import '../../providers/diet_provider.dart';
import '../../services/api_client.dart';
import '../../models/ai_analysis.dart';
import '../../config/theme.dart';
import '../../widgets/empty_state.dart';

class AnalysisScreen extends StatefulWidget {
  const AnalysisScreen({super.key});

  @override
  State<AnalysisScreen> createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  int _days = 7;
  bool _analyzing = false;
  AiAnalysisResult? _aiResult;
  String? _error;

  Future<void> _runAiAnalysis() async {
    setState(() {
      _analyzing = true;
      _error = null;
    });

    final sp = context.read<SymptomProvider>();
    final dp = context.read<DietProvider>();
    final slp = context.read<SleepProvider>();
    final stp = context.read<StressProvider>();
    final usp = context.read<UserSettingsProvider>();
    final user = usp.settings;

    final now = DateTime.now();
    final start = now.subtract(Duration(days: _days));

    String? userInfo;
    if (user.nickname.isNotEmpty || user.birthDate != null) {
      final parts = <String>[];
      if (user.nickname.isNotEmpty) parts.add('昵称: ${user.nickname}');
      if (user.age != null) parts.add('年龄: ${user.age}岁');
      if (user.gender != 'other') {
        parts.add('性别: ${user.gender == "male" ? "男" : "女"}');
      }
      userInfo = parts.join(', ');
    }

    final result = await ApiClient.analyze(
      symptoms: sp.getByDateRange(start, now),
      diets: dp.getByDateRange(start, now),
      sleeps: slp.getByDateRange(start, now),
      stresses: stp.getByDateRange(start, now),
      userInfo: userInfo,
    );

    if (!mounted) return;
    setState(() {
      _analyzing = false;
      if (result.modelUsed.startsWith('error:')) {
        _error = result.modelUsed.substring(7).trim();
      } else {
        _aiResult = result;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SymptomProvider>();
    final slp = context.watch<SleepProvider>();
    final stp = context.watch<StressProvider>();
    final hasData = sp.symptoms.isNotEmpty ||
        slp.logs.isNotEmpty ||
        stp.logs.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: const Text('健康分析'),
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.date_range),
            onSelected: (v) => setState(() { _days = v; _aiResult = null; }),
            itemBuilder: (_) => const [
              PopupMenuItem(value: 7, child: Text('近 7 天')),
              PopupMenuItem(value: 14, child: Text('近 14 天')),
              PopupMenuItem(value: 30, child: Text('近 30 天')),
            ],
          ),
        ],
      ),
      body: !hasData
          ? EmptyState(
              icon: Icons.insights,
              title: '数据不足',
              subtitle: '记录更多症状和日志后\n这里将展示你的健康趋势分析',
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== AI 分析按钮 =====
                  _buildAiSection(),
                  const SizedBox(height: 16),

                  // ===== 概览 =====
                  _buildSummaryCards(sp, slp, stp),
                  const SizedBox(height: 16),

                  // ===== 症状频率 =====
                  _buildSymptomChart(sp),
                  if (slp.logs.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildSleepChart(slp),
                  ],
                  if (stp.logs.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    _buildStressChart(stp),
                  ],
                  const SizedBox(height: 16),
                  _buildInsights(sp, slp, stp),
                ],
              ),
            ),
    );
  }

  // ===== AI 分析区块 =====
  Widget _buildAiSection() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: _days));
    final sc = context.read<SymptomProvider>().getByDateRange(start, now).length +
        context.read<SleepProvider>().getByDateRange(start, now).length +
        context.read<StressProvider>().getByDateRange(start, now).length;

    return Card(
      color: Theme.of(context).colorScheme.tertiaryContainer.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: Colors.deepPurple),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text('AI 智能分析',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
                if (_analyzing)
                  const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2)),
              ],
            ),
            const SizedBox(height: 4),
            Text('基于 $_days 天共 $sc 条数据，DeepSeek AI 帮你发现规律',
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),
            const SizedBox(height: 12),

            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text('⚠️ $_error',
                    style: const TextStyle(color: Colors.red, fontSize: 13)),
              ),

            // AI 结果
            if (_aiResult != null) ...[
              if (_aiResult!.isEmpty)
                const Text('暂无足够数据产生有效分析，请尝试更长时间范围。')
              else
                _buildAiResults(),
            ],

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _analyzing || sc < 2 ? null : _runAiAnalysis,
                icon: const Icon(Icons.auto_awesome),
                label: Text(_aiResult != null ? '重新分析' : '开始 AI 分析'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAiResults() {
    final r = _aiResult!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(),
        // 关联 — 带循证等级
        if (r.correlations.isNotEmpty) ...[
          Row(children: [
            const Icon(Icons.link, size: 18, color: Colors.deepPurple),
            const SizedBox(width: 6),
            const Text('关联发现（循证医学）', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
          const SizedBox(height: 8),
          ...r.correlations.map((c) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.strength == 'strong' ? Colors.red.shade50 : Colors.orange.shade50,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text('${c.strengthLabel} ', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                    color: c.strength == 'strong' ? Colors.red.shade700 : Colors.orange.shade700)),
                Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(color: Colors.white70, borderRadius: BorderRadius.circular(4)),
                  child: Text(c.evidenceLabel, style: const TextStyle(fontSize: 10))),
                const Spacer(),
                Text('${c.factor} → ${c.symptom}', style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
              ]),
              const SizedBox(height: 6),
              Text(c.description, style: const TextStyle(fontSize: 13)),
              if (c.mechanism.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('机制: ${c.mechanism}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic)),
              ],
            ]),
          )),
        ],
        // 模式
        if (r.patterns.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.pattern, size: 18, color: Colors.indigo),
            const SizedBox(width: 6),
            const Text('临床模式识别', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
          ...r.patterns.map((p) => Container(
            width: double.infinity,
            margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.indigo.shade50, borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(p.pattern, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                const Spacer(),
                Text('置信度: ${p.confidenceLabel}', style: TextStyle(fontSize: 11, color: Colors.indigo.shade700)),
              ]),
              const SizedBox(height: 4),
              Text(p.description, style: const TextStyle(fontSize: 13)),
              if (p.clinicalContext.isNotEmpty)
                Text('临床背景: ${p.clinicalContext}', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            ]),
          )),
        ],
        // 风险
        if (r.risk != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.warning_amber, size: 18, color: Colors.deepOrange),
            const SizedBox(width: 6),
            const Text('风险评估与建议', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
          Container(
            width: double.infinity, margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.deepOrange.shade50, borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('综合风险: ${r.risk!.level == "high" ? "高风险 ⚠️" : r.risk!.level == "medium" ? "中等风险" : "低风险"}',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              if (r.risk!.summary.isNotEmpty) ...[
                const SizedBox(height: 4), Text(r.risk!.summary, style: const TextStyle(fontSize: 13)),
              ],
              if (r.risk!.suggestedDepartment.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('建议科室: ${r.risk!.suggestedDepartment}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
              ],
              if (r.risk!.suggestedTests.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text('建议检查: ${r.risk!.suggestedTests}', style: TextStyle(fontSize: 12, color: Colors.grey.shade700)),
              ],
            ]),
          ),
        ],
        // 就医摘要
        if (r.doctorSummary != null) ...[
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.local_hospital, size: 18, color: Colors.teal),
            const SizedBox(width: 6),
            const Text('就医沟通要点', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          ]),
          Container(
            width: double.infinity, margin: const EdgeInsets.only(top: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(8)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('📋 ${r.doctorSummary!.brief}', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
              if (r.doctorSummary!.timeline.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text('时间线: ${r.doctorSummary!.timeline}', style: const TextStyle(fontSize: 12)),
              ],
              if (r.doctorSummary!.keyPoints.isNotEmpty) ...[
                const SizedBox(height: 6),
                const Text('关键信息:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                ...r.doctorSummary!.keyPoints.map((p) => Padding(padding: const EdgeInsets.only(top: 2), child: Text('• $p', style: const TextStyle(fontSize: 12)))),
              ],
              if (r.doctorSummary!.differentialDiagnosis.isNotEmpty) ...[
                const SizedBox(height: 6),
                const Text('鉴别诊断:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                ...r.doctorSummary!.differentialDiagnosis.map((d) => Padding(padding: const EdgeInsets.only(top: 2), child: Text('• $d', style: const TextStyle(fontSize: 12)))),
              ],
              if (r.doctorSummary!.questionsToAsk.isNotEmpty) ...[
                const SizedBox(height: 6),
                const Text('建议问医生:', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
                ...r.doctorSummary!.questionsToAsk.map((q) => Padding(padding: const EdgeInsets.only(top: 2), child: Text('❓ $q', style: const TextStyle(fontSize: 12)))),
              ],
            ]),
          ),
        ],
      ],
    );
  }

  // ===== 概览卡片 =====
  Widget _buildSummaryCards(SymptomProvider sp, SleepProvider slp, StressProvider stp) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: _days));
    final s = sp.getByDateRange(start, now);
    final sl = slp.getByDateRange(start, now);
    final st = stp.getByDateRange(start, now);

    return Row(children: [
      _card(Icons.healing, '症状', '${s.length}条',
          s.isNotEmpty ? '均${(s.fold<int>(0,(a,b)=>a+b.severity)/s.length).toStringAsFixed(1)}分' : '--',
          AppTheme.primary),
      const SizedBox(width: 8),
      _card(Icons.bed, '睡眠', '${sl.length}晚',
          sl.isNotEmpty ? '均${(sl.fold<int>(0,(a,b)=>a+b.quality)/sl.length).toStringAsFixed(1)}分' : '--',
          Colors.indigo),
      const SizedBox(width: 8),
      _card(Icons.psychology, '压力', '${st.length}次',
          st.isNotEmpty ? '均${(st.fold<int>(0,(a,b)=>a+b.level)/st.length).toStringAsFixed(1)}分' : '--',
          Colors.red),
    ]);
  }

  Widget _card(IconData icon, String label, String val, String sub, Color c) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(children: [
            Icon(icon, color: c, size: 20),
            Text(val, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: c)),
            Text(label, style: const TextStyle(fontSize: 11, color: Colors.grey)),
            Text(sub, style: const TextStyle(fontSize: 10, color: Colors.grey)),
          ]),
        ),
      ),
    );
  }

  // ===== 图表 =====
  Widget _buildSymptomChart(SymptomProvider sp) {
    final data = sp.dailyCounts(_days);
    final dates = data.keys.toList()..sort();
    if (dates.isEmpty || data.values.every((v) => v == 0)) return const SizedBox();
    final maxY = (data.values.reduce((a, b) => a > b ? a : b) + 1).toDouble();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('每日症状数', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(
              height: 160,
              child: BarChart(BarChartData(
                maxY: maxY,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(
                    showTitles: true, reservedSize: 22,
                    getTitlesWidget: (v,_) {
                      final i = v.toInt();
                      return i >= 0 && i < dates.length
                          ? Text(DateFormat('d').format(dates[i]), style: const TextStyle(fontSize: 9))
                          : const SizedBox();
                    })),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 20,
                    getTitlesWidget: (v,_) => Text('${v.toInt()}', style: const TextStyle(fontSize: 9)))),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                barGroups: dates.asMap().entries.map((e) => BarChartGroupData(x: e.key, barRods: [
                  BarChartRodData(toY: (data[e.value]??0).toDouble(), color: AppTheme.primary,
                    width: _days > 14 ? 7 : 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(3))),
                ])).toList(),
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSleepChart(SleepProvider slp) {
    final now = DateTime.now();
    final logs = slp.getByDateRange(now.subtract(Duration(days: _days)), now);
    if (logs.isEmpty) return const SizedBox();
    logs.sort((a,b) => a.recordedDate.compareTo(b.recordedDate));
    final spots = logs.asMap().entries.map((e) => FlSpot(e.key.toDouble(), e.value.duration.inHours.toDouble())).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('睡眠时长 (小时)', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(height: 160,
              child: LineChart(LineChartData(
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
                    getTitlesWidget: (v,_) { final i=v.toInt(); return i>=0&&i<logs.length ? Text(DateFormat('d').format(logs[i].recordedDate), style: const TextStyle(fontSize: 9)) : const SizedBox(); })),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22, getTitlesWidget: (v,_) => Text('${v.toInt()}h', style: const TextStyle(fontSize: 9)))),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: Colors.indigo, barWidth: 2.5,
                  dotData: FlDotData(show: true, getDotPainter: (_,__,___,____)=>FlDotCirclePainter(radius: 2.5, color: Colors.indigo, strokeWidth: 0)),
                  belowBarData: BarAreaData(show: true, color: Colors.indigo.withValues(alpha: 0.08)))],
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStressChart(StressProvider stp) {
    final data = stp.avgByDay(_days);
    final dates = data.keys.toList()..sort();
    if (dates.isEmpty) return const SizedBox();
    final spots = dates.asMap().entries.map((e) => FlSpot(e.key.toDouble(), data[e.value]??0)).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('压力趋势', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            SizedBox(height: 160,
              child: LineChart(LineChartData(minY: 0, maxY: 10,
                titlesData: FlTitlesData(
                  bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 22,
                    getTitlesWidget: (v,_) { final i=v.toInt(); return i>=0&&i<dates.length ? Text(DateFormat('d').format(dates[i]), style: const TextStyle(fontSize: 9)) : const SizedBox(); })),
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 20, getTitlesWidget: (v,_) => Text('${v.toInt()}', style: const TextStyle(fontSize: 9)))),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [LineChartBarData(spots: spots, isCurved: true, color: Colors.red, barWidth: 2.5,
                  dotData: FlDotData(show: _days<=14),
                  belowBarData: BarAreaData(show: true, color: Colors.red.withValues(alpha: 0.08)))],
              )),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInsights(SymptomProvider sp, SleepProvider slp, StressProvider stp) {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: _days));
    final s = sp.getByDateRange(start, now);
    final insights = <String>[];
    if (s.isNotEmpty) {
      final map = <String,int>{};
      for (final x in s) { map[x.bodyDetail] = (map[x.bodyDetail]??0)+1; }
      final top = map.entries.reduce((a,b)=>a.value>b.value?a:b);
      if (top.value >= 2) insights.add('最常见症状: ${top.key} (${top.value}次)');
    }
    if (insights.isEmpty) insights.add('更多数据将带来更丰富的洞察');
    return Card(
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.2),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('💡 数据洞察', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            ...insights.map((t) => Padding(padding: const EdgeInsets.only(top: 8), child: Text('• $t'))),
          ],
        ),
      ),
    );
  }
}

