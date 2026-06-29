import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../providers/community_provider.dart';
import '../../providers/symptom_provider.dart';
import '../../models/medical_case.dart';
import '../../models/comment.dart';
import '../../widgets/empty_state.dart';

class CommunityListScreen extends StatefulWidget {
  const CommunityListScreen({super.key});

  @override
  State<CommunityListScreen> createState() => _CommunityListScreenState();
}

class _CommunityListScreenState extends State<CommunityListScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CommunityProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('病例论坛')),
      body: Column(
        children: [
          // 搜索栏
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: '搜索症状、病名...',
                prefixIcon: const Icon(Icons.search, size: 20),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(icon: const Icon(Icons.clear, size: 18),
                        onPressed: () { _searchCtrl.clear(); prov.setSearch(''); })
                    : null,
                isDense: true, contentPadding: const EdgeInsets.symmetric(vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onChanged: prov.setSearch,
            ),
          ),
          // 标签过滤
          if (prov.allTags.isNotEmpty)
            SizedBox(
              height: 36,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: prov.allTags.length + 1,
                separatorBuilder: (_, __) => const SizedBox(width: 6),
                itemBuilder: (_, i) {
                  final tag = i == 0 ? null : prov.allTags[i - 1];
                  final sel = i == 0 ? prov.filterTag.isEmpty : tag == prov.filterTag;
                  return FilterChip(
                    label: Text(i == 0 ? '全部' : tag!, style: const TextStyle(fontSize: 12)),
                    selected: sel, visualDensity: VisualDensity.compact,
                    onSelected: (_) => prov.setFilter(tag ?? ''),
                  );
                },
              ),
            ),
          // 列表
          Expanded(
            child: prov.cases.isEmpty
                ? EmptyState(icon: Icons.people_outline, title: '没有匹配的病例',
                    subtitle: '去「设置」→「导入示例案例」')
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: prov.cases.length,
                    itemBuilder: (_, i) => _CaseCard(
                      medicalCase: prov.cases[i],
                      onTap: () => _openDetail(context, prov.cases[i]),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createCase(context),
        icon: const Icon(Icons.edit),
        label: const Text('分享我的病例'),
      ),
    );
  }

  void _openDetail(BuildContext context, MedicalCase c) {
    c.viewCount++;
    context.read<CommunityProvider>().refresh();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _ForumDetailScreen(medicalCase: c)),
    );
  }

  void _createCase(BuildContext context) {
    final sp = context.read<SymptomProvider>();
    if (sp.symptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('先记录一些症状，才能分享病例')),
      );
      return;
    }
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _CreateCaseScreen()),
    );
  }
}

// ===== 病例卡片 =====
class _CaseCard extends StatelessWidget {
  final MedicalCase medicalCase;
  final VoidCallback onTap;
  const _CaseCard({required this.medicalCase, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(radius: 14, backgroundColor: Colors.teal.shade100,
                  child: const Icon(Icons.person, size: 16, color: Colors.teal)),
              const SizedBox(width: 6),
              Text('匿名用户', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
              const Spacer(),
              Text(DateFormat('MM/dd').format(medicalCase.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
            ]),
            const SizedBox(height: 10),
            Text(medicalCase.title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(medicalCase.content.length > 100 ? '${medicalCase.content.substring(0, 100)}...' : medicalCase.content,
                style: TextStyle(fontSize: 13, color: Colors.grey.shade600), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 10),
            Wrap(spacing: 6, runSpacing: 4,
              children: medicalCase.symptomTags.map((t) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: Colors.teal.shade50, borderRadius: BorderRadius.circular(10)),
                child: Text(t, style: TextStyle(fontSize: 11, color: Colors.teal.shade700)),
              )).toList()),
            const SizedBox(height: 8),
            Row(children: [
              _meta(Icons.timer, medicalCase.durationLabel),
              const SizedBox(width: 12),
              _meta(Icons.thumb_up, '${medicalCase.upvoteCount}'),
              const SizedBox(width: 12),
              _meta(Icons.chat_bubble_outline, '${medicalCase.commentCount}'),
              const SizedBox(width: 12),
              _meta(Icons.visibility, '${medicalCase.viewCount}'),
              const Spacer(),
              Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(4)),
                  child: Text(medicalCase.diagnosisLabel, style: TextStyle(fontSize: 10, color: Colors.grey.shade700))),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _meta(IconData icon, String text) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, size: 12, color: Colors.grey), const SizedBox(width: 2),
    Text(text, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
  ]);
}

// ===== 论坛详情页 =====
class _ForumDetailScreen extends StatefulWidget {
  final MedicalCase medicalCase;
  const _ForumDetailScreen({required this.medicalCase});
  @override
  State<_ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<_ForumDetailScreen> {
  final _commentCtrl = TextEditingController();

  @override
  void dispose() { _commentCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<CommunityProvider>();
    final comments = prov.commentsFor(widget.medicalCase.id);

    return Scaffold(
      appBar: AppBar(title: const Text('病例详情'), actions: [
        IconButton(icon: const Icon(Icons.thumb_up_outlined), tooltip: '点赞',
            onPressed: () => prov.upvote(widget.medicalCase.id)),
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 标题+标签
          Text(widget.medicalCase.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 4,
            children: widget.medicalCase.symptomTags.map((t) => Chip(
              label: Text(t, style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.teal.shade50, visualDensity: VisualDensity.compact,
            )).toList()),
          const SizedBox(height: 8),
          Row(children: [
            Text('${widget.medicalCase.updatedAt.year}年${widget.medicalCase.updatedAt.month}月', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(width: 16),
            Text('${widget.medicalCase.durationLabel}', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const Spacer(),
            Text('${widget.medicalCase.upvoteCount} 赞 · ${comments.length} 评论', style: TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
          const Divider(height: 24),
          // 正文
          SelectableText(widget.medicalCase.content, style: const TextStyle(fontSize: 15, height: 1.8)),
          const Divider(height: 32),

          // 评论区
          const Text('讨论', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (comments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text('还没有人评论，来说两句吧', style: TextStyle(color: Colors.grey.shade500))),
            ),
          ...comments.map((c) => _CommentTile(comment: c)),
          const SizedBox(height: 80),
        ]),
      ),
      // 底部评论输入
      bottomSheet: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _commentCtrl,
              decoration: InputDecoration(
                hintText: '写下你的评论...', isDense: true,
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            onPressed: () {
              if (_commentCtrl.text.trim().isEmpty) return;
              prov.addComment(widget.medicalCase.id, _commentCtrl.text.trim());
              _commentCtrl.clear();
            },
            icon: const Icon(Icons.send, size: 20),
          ),
        ]),
      ),
    );
  }
}

class _CommentTile extends StatelessWidget {
  final Comment comment;
  const _CommentTile({required this.comment});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const CircleAvatar(radius: 14, child: Icon(Icons.person, size: 16)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('匿名用户', style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13)),
              const SizedBox(width: 8),
              Text(DateFormat('MM/dd HH:mm').format(comment.createdAt),
                  style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
            ]),
            const SizedBox(height: 4),
            Text(comment.content, style: const TextStyle(fontSize: 14, height: 1.5)),
          ]),
        ),
      ]),
    );
  }
}

// ===== 创建病例页 =====
class _CreateCaseScreen extends StatefulWidget {
  @override
  State<_CreateCaseScreen> createState() => _CreateCaseScreenState();
}

class _CreateCaseScreenState extends State<_CreateCaseScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final List<String> _tags = [];

  @override
  void initState() {
    super.initState();
    // 从用户数据自动生成摘要
    final sp = context.read<SymptomProvider>();
    final tagSet = <String>{};
    final buf = StringBuffer();
    buf.writeln('## 我的症状记录\n');
    final now = DateTime.now();
    final recent = sp.symptoms.where((s) =>
        s.recordedAt.isAfter(now.subtract(const Duration(days: 14)))).toList();
    for (final s in recent) {
      buf.writeln('- ${s.bodyDetailLabel} 严重度 ${s.severity}/10');
      tagSet.add(s.bodyDetailLabel);
    }
    if (recent.isEmpty) buf.writeln('暂无近期记录');
    _contentCtrl.text = buf.toString();
    _tags.addAll(tagSet.take(5));
  }

  @override
  void dispose() { _titleCtrl.dispose(); _contentCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('分享病例'), actions: [
        TextButton(onPressed: _submit, child: const Text('发布')),
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: '标题', hintText: '简单描述你的情况'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentCtrl,
            maxLines: 10,
            decoration: const InputDecoration(labelText: '详细描述', hintText: '症状、检查结果、就医经历、希望获得什么帮助...', alignLabelWithHint: true),
          ),
          const SizedBox(height: 12),
          const Text('症状标签', style: TextStyle(fontWeight: FontWeight.w500)),
          Wrap(spacing: 6, runSpacing: 4, children: _tags.map((t) => Chip(
            label: Text(t, style: const TextStyle(fontSize: 12)),
            deleteIcon: const Icon(Icons.close, size: 14),
            onDeleted: () => setState(() => _tags.remove(t)),
          )).toList()),
          const SizedBox(height: 8),
          Row(children: [
            Expanded(
              child: TextField(
                decoration: const InputDecoration(hintText: '添加标签', isDense: true),
                onSubmitted: (v) { if (v.trim().isNotEmpty && !_tags.contains(v.trim())) setState(() => _tags.add(v.trim())); },
              ),
            ),
            IconButton(icon: const Icon(Icons.add), onPressed: () {}),
          ]),
        ]),
      ),
    );
  }

  void _submit() {
    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('请输入标题')));
      return;
    }
    final c = MedicalCase(
      title: _titleCtrl.text.trim(),
      content: _contentCtrl.text.trim(),
      symptomTags: List.from(_tags),
      bodyParts: ['general'],
      durationTag: 'months', diagnosisStatus: 'undiagnosed',
      isAnonymous: true,
    );
    context.read<CommunityProvider>().add(c);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('病例发布成功！')));
  }
}
