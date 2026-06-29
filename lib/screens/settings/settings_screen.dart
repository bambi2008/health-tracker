import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../providers/user_settings_provider.dart';
import '../../providers/symptom_provider.dart';
import '../../providers/diet_provider.dart';
import '../../providers/sleep_provider.dart';
import '../../providers/stress_provider.dart';
import '../../providers/report_provider.dart';
import '../../providers/community_provider.dart';
import '../../services/sample_data.dart';
import '../../services/sync_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('设置')),
      body: Consumer<UserSettingsProvider>(
        builder: (context, prov, _) {
          final s = prov.settings;
          return ListView(
            children: [
              // 个人资料入口
              ListTile(
                leading: const CircleAvatar(child: Icon(Icons.person)),
                title: Text(s.nickname.isNotEmpty ? s.nickname : '设置个人资料'),
                subtitle: const Text('身高、体重、慢性病等'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => context.push('/settings/profile'),
              ),
              const Divider(),

              // 主题
              ListTile(
                leading: const Icon(Icons.brightness_6),
                title: const Text('主题模式'),
                subtitle: Text(_themeLabel(s.themeMode)),
                onTap: () => _showThemePicker(context, prov),
              ),
              const Divider(),

              // 提醒设置
              SwitchListTile(
                secondary: const Icon(Icons.notifications),
                title: const Text('症状记录提醒'),
                subtitle: const Text('每天提醒记录症状'),
                value: s.remindSymptom,
                onChanged: prov.setRemindSymptom,
              ),
              if (s.remindSymptom)
                ListTile(
                  leading: const Icon(Icons.schedule),
                  title: const Text('提醒时间'),
                  trailing: Text(s.remindTime),
                  onTap: () async {
                    final parts = s.remindTime.split(':');
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay(
                        hour: int.tryParse(parts[0]) ?? 20,
                        minute: int.tryParse(parts[1]) ?? 0,
                      ),
                    );
                    if (time != null) {
                      prov.setRemindTime(
                        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
                      );
                    }
                  },
                ),
              const Divider(),

              // 数据管理
              const Padding(
                padding: EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: Text('数据管理',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey)),
              ),
              ListTile(
                leading: const Icon(Icons.cloud_upload, color: Colors.blue),
                title: const Text('备份数据到服务器'),
                subtitle: const Text('将本地数据上传到云端保存'),
                onTap: () => _syncUpload(context),
              ),
              ListTile(
                leading: const Icon(Icons.cloud_download, color: Colors.teal),
                title: const Text('查看云端备份'),
                subtitle: const Text('检查服务器上的数据概览'),
                onTap: () => _syncStatus(context),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.file_download),
                title: const Text('导出全部数据'),
                subtitle: const Text('导出为 JSON 格式'),
                onTap: () => _exportAll(context),
              ),
              ListTile(
                leading: const Icon(Icons.delete_outline, color: Colors.red),
                title: const Text('清除所有数据',
                    style: TextStyle(color: Colors.red)),
                subtitle: const Text('不可恢复'),
                onTap: () => _confirmClearData(context),
              ),

              const Divider(),

              // 导入案例
              ListTile(
                leading: const Icon(Icons.download, color: Colors.teal),
                title: const Text('导入示例案例'),
                subtitle: const Text('乳腺癌术后18个月复查 — 5条症状+5晚睡眠+3条压力+6条饮食'),
                onTap: () => _importSample(context),
              ),

              const Divider(),
              // 关于
              const ListTile(
                leading: Icon(Icons.info_outline),
                title: Text('症状追踪'),
                subtitle: Text('v1.0.0 — 关注你的身体健康'),
              ),
            ],
          );
        },
      ),
    );
  }

  String _themeLabel(String mode) {
    switch (mode) {
      case 'light':
        return '浅色';
      case 'dark':
        return '深色';
      default:
        return '跟随系统';
    }
  }

  void _showThemePicker(BuildContext context, UserSettingsProvider prov) {
    showDialog(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('选择主题'),
        children: [
          SimpleDialogOption(
            onPressed: () {
              prov.setThemeMode('system');
              Navigator.pop(ctx);
            },
            child: const Text('跟随系统'),
          ),
          SimpleDialogOption(
            onPressed: () {
              prov.setThemeMode('light');
              Navigator.pop(ctx);
            },
            child: const Text('浅色模式'),
          ),
          SimpleDialogOption(
            onPressed: () {
              prov.setThemeMode('dark');
              Navigator.pop(ctx);
            },
            child: const Text('深色模式'),
          ),
        ],
      ),
    );
  }

  void _exportAll(BuildContext context) {
    final data = {
      'symptoms': context.read<SymptomProvider>().exportAll(),
      'dietLogs': context.read<DietProvider>().exportAll(),
      'sleepLogs': context.read<SleepProvider>().exportAll(),
      'stressLogs': context.read<StressProvider>().exportAll(),
      'reports': context.read<ReportProvider>().exportAll(),
      'settings':
          context.read<UserSettingsProvider>().settings.toJson(),
      'exportedAt': DateTime.now().toIso8601String(),
    };
    // TODO: 写入文件并分享
    final symptomCount = (data['symptoms'] as List).length;
    final dietCount = (data['dietLogs'] as List).length;
    final sleepCount = (data['sleepLogs'] as List).length;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('已准备 $symptomCount 条症状、'
            '$dietCount 条饮食、'
            '$sleepCount 条睡眠等数据（分享功能待完善）'),
      ),
    );
  }

  void _importSample(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('导入示例案例'),
        content: const Text(
          '将导入乳腺癌术后18个月复查数据：\n\n'
          '• 5 条症状（贫血/乏力/足底筋膜炎/消化）\n'
          '• 5 晚睡眠记录\n'
          '• 3 条压力记录\n'
          '• 6 条饮食记录\n\n'
          '导入后可立即使用 AI 分析。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('取消')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('导入')),
        ],
      ),
    );
    if (confirm != true || !context.mounted) return;

    await SampleData.importAll(
      symptomProv: context.read<SymptomProvider>(),
      dietProv: context.read<DietProvider>(),
      sleepProv: context.read<SleepProvider>(),
      stressProv: context.read<StressProvider>(),
      communityProv: context.read<CommunityProvider>(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ 案例数据导入成功！去「分析」Tab 跑 AI 分析吧')),
    );
  }

  void _syncUpload(BuildContext context) async {
    try {
      final counts = await SyncService.upload(
        symptoms: context.read<SymptomProvider>().symptoms,
        diets: context.read<DietProvider>().logs,
        sleeps: context.read<SleepProvider>().logs,
        stresses: context.read<StressProvider>().logs,
      );
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(
          '✅ 备份成功！症状${counts['symptoms']}条 饮食${counts['diets']}条 '
          '睡眠${counts['sleeps']}条 压力${counts['stresses']}条')),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('备份失败: $e')),
      );
    }
  }

  void _syncStatus(BuildContext context) async {
    try {
      final s = await SyncService.status();
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('云端备份概况'),
          content: Text(
            '症状: ${s['symptom_count']} 条\n'
            '饮食: ${s['diet_count']} 条\n'
            '睡眠: ${s['sleep_count']} 条\n'
            '压力: ${s['stress_count']} 条\n\n'
            '上次同步: ${s['last_synced_at'] ?? '从未'}',
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('关闭'))],
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('查询失败: $e')),
      );
    }
  }

  void _confirmClearData(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认清除'),
        content: const Text('将删除所有症状、日志、报告数据，不可恢复。确定继续？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () {
              context.read<SymptomProvider>().exportAll().clear();
              context.read<DietProvider>().exportAll().clear();
              context.read<SleepProvider>().exportAll().clear();
              context.read<StressProvider>().exportAll().clear();
              context.read<ReportProvider>().exportAll().clear();
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('数据已清除')),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('确认清除'),
          ),
        ],
      ),
    );
  }
}
