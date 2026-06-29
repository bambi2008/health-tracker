import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class KnowledgeListScreen extends StatelessWidget {
  const KnowledgeListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('健康知识')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const CircleAvatar(
                backgroundColor: Colors.teal,
                child: Icon(Icons.assignment, color: Colors.white),
              ),
              title: const Text('症状自检问卷'),
              subtitle: const Text('通过问卷初步了解健康状况'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/knowledge/self-check/general'),
            ),
          ),
          const SizedBox(height: 16),
          // 占位知识文章
          ...List.generate(4, (i) {
            final articles = [
              {
                'title': '常见头痛的自我识别',
                'category': '神经系统',
                'icon': Icons.psychology,
              },
              {
                'title': '慢性疲劳：不只是"累"',
                'category': '全身性',
                'icon': Icons.energy_savings_leaf,
              },
              {
                'title': '消化不良的饮食调整',
                'category': '消化系统',
                'icon': Icons.restaurant,
              },
              {
                'title': '睡眠质量与健康的关系',
                'category': '睡眠',
                'icon': Icons.bedtime,
              },
            ];
            final a = articles[i];
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: Colors.grey.shade100,
                  child: Icon(a['icon'] as IconData, color: Colors.teal),
                ),
                title: Text(a['title'] as String),
                subtitle: Text(a['category'] as String),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('文章内容将在后续版本中添加')),
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
