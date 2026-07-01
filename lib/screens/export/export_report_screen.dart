import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../../providers/symptom_provider.dart';
import '../../providers/diet_provider.dart';
import '../../providers/sleep_provider.dart';
import '../../providers/stress_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/user_settings_provider.dart';
import '../../models/health_report.dart';
import '../../widgets/chart_card.dart';
import '../../config/theme.dart';

class ExportReportScreen extends StatefulWidget {
  const ExportReportScreen({super.key});

  @override
  State<ExportReportScreen> createState() => _ExportReportScreenState();
}

class _ExportReportScreenState extends State<ExportReportScreen> {
  String _reportType = 'weekly';
  late DateTime _dateFrom;
  late DateTime _dateTo;
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _dateTo = DateTime(now.year, now.month, now.day).add(const Duration(days: 1, seconds: -1));
    _dateFrom = _dateTo.subtract(const Duration(days: 7));
  }

  void _updateRange(String type) {
    setState(() {
      _reportType = type;
      final now = DateTime.now();
      _dateTo = DateTime(now.year, now.month, now.day).add(const Duration(days: 1, seconds: -1));
      switch (type) {
        case 'weekly':
          _dateFrom = _dateTo.subtract(const Duration(days: 7));
        case 'monthly':
          _dateFrom = _dateTo.subtract(const Duration(days: 30));
      }
    });
  }

  Future<void> _generateAndPreview() async {
    setState(() => _generating = true);

    try {
      final pdf = await _buildPdf();
      final report = HealthReport(
        reportType: _reportType,
        dateFrom: _dateFrom,
        dateTo: _dateTo,
        contentMarkdown: _buildMarkdown(),
      );
      if (mounted) {
        context.read<ReportProvider>().add(report);
      }

      await Printing.layoutPdf(
        onLayout: (_) => pdf.save(),
        name: '健康报告_${DateFormat('yyyyMMdd').format(DateTime.now())}.pdf',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('生成失败: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  String _buildMarkdown() {
    final sp = context.read<SymptomProvider>();
    final dp = context.read<DietProvider>();
    final slp = context.read<SleepProvider>();
    final stp = context.read<StressProvider>();
    final fmt = DateFormat('MM/dd');

    final symptoms = sp.getByDateRange(_dateFrom, _dateTo);
    final diets = dp.getByDateRange(_dateFrom, _dateTo);
    final sleeps = slp.getByDateRange(_dateFrom, _dateTo);
    final stresses = stp.getByDateRange(_dateFrom, _dateTo);

    final buf = StringBuffer();
    buf.writeln('# 健康状况报告');
    buf.writeln();
    buf.writeln('**周期**: ${fmt.format(_dateFrom)} — ${fmt.format(_dateTo)}');
    buf.writeln('**生成**: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}');
    buf.writeln();
    buf.writeln('## 📊 数据概览');
    buf.writeln();
    buf.writeln('| 项目 | 数量 | 备注 |');
    buf.writeln('|------|------|------|');
    buf.writeln('| 症状记录 | ${symptoms.length} | ' +
        (symptoms.isNotEmpty
            ? '均严重度 ${(symptoms.fold<int>(0, (s, sy) => s + sy.severity) / symptoms.length).toStringAsFixed(1)}'
            : '-') +
        ' |');
    buf.writeln('| 饮食记录 | ${diets.length} | ' +
        (diets.isNotEmpty
            ? '总饮水 ${diets.fold<int>(0, (s, d) => s + d.waterMl)}ml'
            : '-') +
        ' |');
    buf.writeln('| 睡眠记录 | ${sleeps.length} | ' +
        (sleeps.isNotEmpty
            ? '均质量 ${(sleeps.fold<int>(0, (s, sl) => s + sl.quality) / sleeps.length).toStringAsFixed(1)}/5'
            : '-') +
        ' |');
    buf.writeln('| 压力记录 | ${stresses.length} | ' +
        (stresses.isNotEmpty
            ? '均水平 ${(stresses.fold<int>(0, (s, st) => s + st.level) / stresses.length).toStringAsFixed(1)}/10'
            : '-') +
        ' |');
    buf.writeln();
    if (symptoms.isNotEmpty) {
      buf.writeln('## 🔴 症状详情');
      buf.writeln();
      buf.writeln('| 日期 | 部位 | 严重度 | 描述 |');
      buf.writeln('|------|------|--------|------|');
      for (final s in symptoms) {
        final desc =
            s.description.length > 40 ? '${s.description.substring(0, 40)}...' : s.description;
        buf.writeln(
            '| ${fmt.format(s.recordedAt)} | ${s.bodyDetailLabel} | ${s.severity}/10 | ${desc.isNotEmpty ? desc : '-'} |');
      }
      buf.writeln();
    }
    buf.writeln('---');
    buf.writeln();
    buf.writeln('> ⚠️ 本报告由健康症状追踪 App 生成，仅供参考，不能替代专业医疗诊断。');

    return buf.toString();
  }

  Future<pw.Document> _buildPdf() async {
    final pdf = pw.Document();
    final sp = context.read<SymptomProvider>();
    final dp = context.read<DietProvider>();
    final slp = context.read<SleepProvider>();
    final stp = context.read<StressProvider>();
    final usp = context.read<UserSettingsProvider>();
    final fmt = DateFormat('yyyy/MM/dd');

    final symptoms = sp.getByDateRange(_dateFrom, _dateTo);
    final diets = dp.getByDateRange(_dateFrom, _dateTo);
    final sleeps = slp.getByDateRange(_dateFrom, _dateTo);
    final stresses = stp.getByDateRange(_dateFrom, _dateTo);

    final user = usp.settings;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (ctx) => [
          // Header
          pw.Header(
            level: 0,
            child: pw.Text('健康状况报告',
                style: pw.TextStyle(
                    fontSize: 24, fontWeight: pw.FontWeight.bold)),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '${fmt.format(_dateFrom)} — ${fmt.format(_dateTo)}',
            style: pw.TextStyle(fontSize: 12, color: PdfColors.grey600),
          ),
          pw.SizedBox(height: 8),
          if (user.nickname.isNotEmpty)
            pw.Text('用户: ${user.nickname}',
                style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
          if (user.birthDate != null)
            pw.Text('年龄: ${user.age}岁',
                style: pw.TextStyle(fontSize: 11, color: PdfColors.grey600)),
          pw.SizedBox(height: 16),
          pw.Divider(),

          // 概览
          pw.Header(level: 1, text: '数据概览'),
          pw.Table(
            columnWidths: {0: pw.FlexColumnWidth(1), 1: pw.FlexColumnWidth(2)},
            children: [
              pw.TableRow(children: [
                _pdfCell('症状记录', bold: true),
                _pdfCell('${symptoms.length} 条' +
                    (symptoms.isNotEmpty
                        ? '（均严重度 ${(symptoms.fold<int>(0, (s, sy) => s + sy.severity) / symptoms.length).toStringAsFixed(1)}/10）'
                        : '')),
              ]),
              pw.TableRow(children: [
                _pdfCell('饮食记录', bold: true),
                _pdfCell('${diets.length} 次' +
                    (diets.isNotEmpty
                        ? '（总饮水 ${diets.fold<int>(0, (s, d) => s + d.waterMl)}ml）'
                        : '')),
              ]),
              pw.TableRow(children: [
                _pdfCell('睡眠记录', bold: true),
                _pdfCell('${sleeps.length} 晚' +
                    (sleeps.isNotEmpty
                        ? '（均质量 ${(sleeps.fold<int>(0, (s, sl) => s + sl.quality) / sleeps.length).toStringAsFixed(1)}/5）'
                        : '')),
              ]),
              pw.TableRow(children: [
                _pdfCell('压力记录', bold: true),
                _pdfCell('${stresses.length} 次' +
                    (stresses.isNotEmpty
                        ? '（均水平 ${(stresses.fold<int>(0, (s, st) => s + st.level) / stresses.length).toStringAsFixed(1)}/10）'
                        : '')),
              ]),
            ],
          ),
          pw.SizedBox(height: 24),

          // 症状详情
          if (symptoms.isNotEmpty) ...[
            pw.Header(level: 1, text: '症状记录详情'),
            pw.Table(
              columnWidths: {
                0: const pw.FixedColumnWidth(80),
                1: const pw.FixedColumnWidth(60),
                2: const pw.FixedColumnWidth(40),
                3: pw.FlexColumnWidth(1),
              },
              children: [
                pw.TableRow(
                  decoration: const pw.BoxDecoration(
                      color: PdfColors.grey200),
                  children: [
                    _pdfCell('日期', bold: true),
                    _pdfCell('部位', bold: true),
                    _pdfCell('严重度', bold: true),
                    _pdfCell('描述', bold: true),
                  ],
                ),
                ...symptoms.map((s) => pw.TableRow(children: [
                      _pdfCell(fmt.format(s.recordedAt)),
                      _pdfCell(s.bodyDetailLabel),
                      _pdfCell('${s.severity}/10'),
                      _pdfCell(s.description.length > 50
                          ? '${s.description.substring(0, 50)}...'
                          : s.description),
                    ])),
              ],
            ),
          ],
          pw.SizedBox(height: 24),

          // 免责
          pw.Divider(),
          pw.SizedBox(height: 8),
          pw.Text(
            '免责声明：本报告由"健康症状追踪"App 自动生成，仅供记录和参考用途，不能替代专业医疗诊断。如需就诊，建议将本报告提供给医生作为参考。',
            style: pw.TextStyle(fontSize: 9, color: PdfColors.grey500),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '生成时间: ${DateFormat('yyyy-MM-dd HH:mm').format(DateTime.now())}',
            style: pw.TextStyle(fontSize: 8, color: PdfColors.grey400),
          ),
        ],
      ),
    );

    return pdf;
  }

  pw.Widget _pdfCell(String text, {bool bold = false}) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(vertical: 4, horizontal: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('生成报告')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('报告类型',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(value: 'weekly', label: Text('周报')),
                ButtonSegment(value: 'monthly', label: Text('月报')),
                ButtonSegment(value: 'custom', label: Text('自定义')),
              ],
              selected: {_reportType},
              onSelectionChanged: (v) => _updateRange(v.first),
            ),
            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: _DateTile(
                    label: '开始日期',
                    date: _dateFrom,
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _dateFrom,
                        firstDate: DateTime(2020),
                        lastDate: _dateTo,
                      );
                      if (d != null) {
                        setState(() {
                          _dateFrom = d;
                          _reportType = 'custom';
                        });
                      }
                    },
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text('—'),
                ),
                Expanded(
                  child: _DateTile(
                    label: '结束日期',
                    date: _dateTo,
                    onTap: () async {
                      final d = await showDatePicker(
                        context: context,
                        initialDate: _dateTo,
                        firstDate: _dateFrom,
                        lastDate: DateTime.now(),
                      );
                      if (d != null) {
                        setState(() {
                          _dateTo = DateTime(d.year, d.month, d.day)
                              .add(const Duration(days: 1, seconds: -1));
                          _reportType = 'custom';
                        });
                      }
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 数据预览
            _DataPreview(
              dateFrom: _dateFrom,
              dateTo: _dateTo,
            ),
            const SizedBox(height: 16),

            // 趋势图
            ChartCard(
              symptomProvider: context.read<SymptomProvider>(),
              dateFrom: _dateFrom,
              dateTo: _dateTo,
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _generating ? null : _generateAndPreview,
                icon: _generating
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.picture_as_pdf),
                label: Text(_generating ? '生成中...' : '生成 PDF 报告'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateTile extends StatelessWidget {
  final String label;
  final DateTime date;
  final VoidCallback onTap;

  const _DateTile({
    required this.label,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(label,
                style:
                    TextStyle(fontSize: 12, color: Colors.grey.shade600)),
            const SizedBox(height: 4),
            Text(
              DateFormat('yyyy/MM/dd').format(date),
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

class _DataPreview extends StatelessWidget {
  final DateTime dateFrom;
  final DateTime dateTo;

  const _DataPreview({required this.dateFrom, required this.dateTo});

  @override
  Widget build(BuildContext context) {
    final sp = context.watch<SymptomProvider>();
    final dp = context.watch<DietProvider>();
    final slp = context.watch<SleepProvider>();
    final stp = context.watch<StressProvider>();

    final sc = sp.getByDateRange(dateFrom, dateTo).length;
    final dc = dp.getByDateRange(dateFrom, dateTo).length;
    final slc = slp.getByDateRange(dateFrom, dateTo).length;
    final stc = stp.getByDateRange(dateFrom, dateTo).length;
    final total = sc + dc + slc + stc;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('数据预览',
                style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _count('症状', sc, AppTheme.primary),
                _count('饮食', dc, Colors.orange),
                _count('睡眠', slc, Colors.indigo),
                _count('压力', stc, Colors.red),
                _count('合计', total, Colors.grey.shade700),
              ],
            ),
            if (total == 0)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text('该时间段暂无数据',
                    style: TextStyle(color: Colors.grey.shade500)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _count(String label, int count, Color color) {
    return Column(
      children: [
        Text('$count',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: count > 0 ? color : Colors.grey.shade400)),
        Text(label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
      ],
    );
  }
}
