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
  List<MedicalCase> _similarCases = [];

  @override
  void initState() {
    super.initState();
    _checkSimilar();
  }

  void _checkSimilar() {
    final sp = context.read<SymptomProvider>();
    final cp = context.read<CommunityProvider>();
    final userTags = sp.symptoms.map((s) => s.bodyDetailLabel).toSet().toList();
    if (userTags.isNotEmpty) {
      _similarCases = cp.findSimilar(userTags);
    }
  }

  @override
  void dispose() { _searchCtrl.dispose(); super.dispose(); }

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
          // 相似匹配提示
          if (_similarCases.isNotEmpty && prov.searchQuery.isEmpty && prov.filterTag.isEmpty)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green.shade50, borderRadius: BorderRadius.circular(12),
              ),
              child: Row(children: [
                const Icon(Icons.people_outline, color: Colors.green, size: 20),
                const SizedBox(width: 8),
                Expanded(child: Text(
                  '有 ${_similarCases.length} 个病例和你的症状相似',
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                )),
              ]),
            ),
          // 列表
          Expanded(
            child: prov.cases.isEmpty
                ? EmptyState(icon: Icons.people_outline, title: '还没有病例',
                    subtitle: '记录足够症状后，AI会自动匹配相似病例')
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: prov.cases.length,
                    itemBuilder: (_, i) => _CaseCard(
                      medicalCase: prov.cases[i],
                      personaIndex: i,
                      isSimilar: _similarCases.any((c) => c.id == prov.cases[i].id),
                      onTap: () => _openDetail(context, prov.cases[i], i),
                    ),
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _createCase(context),
        icon: const Icon(Icons.edit),
        label: const Text('分享我的经历'),
      ),
    );
  }

  void _openDetail(BuildContext context, MedicalCase c, int personaIndex) {
    c.viewCount++;
    context.read<CommunityProvider>().refresh();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => _ForumDetailScreen(medicalCase: c, personaIndex: personaIndex)),
    );
  }

  void _createCase(BuildContext context) {
    final sp = context.read<SymptomProvider>();
    if (sp.symptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('先记录一些症状，才能分享经历')),
      );
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => _CreateCaseScreen()));
  }
}

// ===== 病例卡片 =====
class _CaseCard extends StatelessWidget {
  final MedicalCase medicalCase;
  final int personaIndex;
  final bool isSimilar;
  final VoidCallback onTap;
  const _CaseCard({required this.medicalCase, required this.personaIndex, required this.isSimilar, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final prov = context.read<CommunityProvider>();
    final name = medicalCase.isAnonymous ? '匿名用户' : prov.personaName(personaIndex);
    final avatar = prov.personaAvatar(personaIndex);
    final desc = prov.personaDesc(personaIndex);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap, borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              CircleAvatar(radius: 16, backgroundColor: Colors.teal.shade100,
                  child: Text(avatar, style: const TextStyle(fontSize: 16))),
              const SizedBox(width: 8),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                Text(desc, style: TextStyle(fontSize: 11, color: Colors.grey.shade500)),
              ])),
              if (isSimilar)
                Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: Colors.green.shade50, borderRadius: BorderRadius.circular(8)),
                    child: const Text('相似', style: TextStyle(fontSize: 10, color: Colors.green))),
              const SizedBox(width: 8),
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

// ===== 详情页 =====
class _ForumDetailScreen extends StatefulWidget {
  final MedicalCase medicalCase;
  final int personaIndex;
  const _ForumDetailScreen({required this.medicalCase, required this.personaIndex});
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
    final name = widget.medicalCase.isAnonymous ? '匿名用户' : prov.personaName(widget.personaIndex);
    final avatar = prov.personaAvatar(widget.personaIndex);
    final desc = prov.personaDesc(widget.personaIndex);

    return Scaffold(
      appBar: AppBar(title: const Text('病例详情'), actions: [
        IconButton(icon: const Icon(Icons.thumb_up_outlined), tooltip: '点赞',
            onPressed: () => prov.upvote(widget.medicalCase.id)),
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // 作者
          Row(children: [
            CircleAvatar(radius: 20, backgroundColor: Colors.teal.shade100,
                child: Text(avatar, style: const TextStyle(fontSize: 20))),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Text(desc, style: TextStyle(fontSize: 12, color: Colors.grey.shade500)),
            ]),
          ]),
          const SizedBox(height: 12),
          Text(widget.medicalCase.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          Wrap(spacing: 6, runSpacing: 4,
            children: widget.medicalCase.symptomTags.map((t) => Chip(
              label: Text(t, style: const TextStyle(fontSize: 12)),
              backgroundColor: Colors.teal.shade50, visualDensity: VisualDensity.compact,
            )).toList()),
          const SizedBox(height: 8),
          Row(children: [
            Icon(Icons.calendar_today, size: 14, color: Colors.grey),
            const SizedBox(width: 4),
            Text('${widget.medicalCase.durationLabel} · ${widget.medicalCase.diagnosisLabel}',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
            const Spacer(),
            Text('${widget.medicalCase.upvoteCount} 赞 · ${comments.length} 讨论',
                style: TextStyle(fontSize: 12, color: Colors.grey)),
          ]),
          const Divider(height: 24),
          SelectableText(widget.medicalCase.content, style: const TextStyle(fontSize: 15, height: 1.8)),
          const Divider(height: 32),

          // 评论区
          Row(children: [
            const Text('讨论', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            Text('${comments.length}条', style: TextStyle(fontSize: 14, color: Colors.grey.shade500)),
          ]),
          const SizedBox(height: 12),
          if (comments.isEmpty)
            Padding(
              padding: const EdgeInsets.all(24),
              child: Center(child: Text('还没有人评论，来分享你的经验吧', style: TextStyle(color: Colors.grey.shade500))),
            ),
          ...comments.map((c) => _buildCommentTile(c)),
          const SizedBox(height: 80),
        ]),
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)]),
        child: Row(children: [
          Expanded(
            child: TextField(
              controller: _commentCtrl,
              decoration: InputDecoration(
                hintText: '分享你的经验或建议...', isDense: true,
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

  Widget _buildCommentTile(Comment comment) {
    // 检测是否是AI助手评论
    final isAI = comment.content.contains('AI健康助手');
    final isExpert = comment.content.contains('循证点评');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isExpert ? Colors.amber.shade50.withValues(alpha: 0.5) : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: isExpert ? Border.all(color: Colors.amber.shade200) : null,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (isExpert)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(color: Colors.amber.shade100, borderRadius: BorderRadius.circular(6)),
            child: const Text('🤖 AI 循证分析', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.brown)),
          ),
        Text(comment.content, style: const TextStyle(fontSize: 14, height: 1.6)),
        const SizedBox(height: 6),
        Text(DateFormat('MM/dd HH:mm').format(comment.createdAt),
            style: TextStyle(fontSize: 11, color: Colors.grey.shade400)),
      ]),
    );
  }
}

// ===== 创建病例 =====
class _CreateCaseScreen extends StatefulWidget {
  @override
  State<_CreateCaseScreen> createState() => _CreateCaseScreenState();
}

class _CreateCaseScreenState extends State<_CreateCaseScreen> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();
  final List<String> _tags = [];
  bool _isAnonymous = false;

  @override
  void initState() {
    super.initState();
    final sp = context.read<SymptomProvider>();
    final tagSet = <String>{};
    final buf = StringBuffer();
    buf.writeln('## 我的情况\n');
    final now = DateTime.now();
    final recent = sp.symptoms.where((s) =>
        s.recordedAt.isAfter(now.subtract(const Duration(days: 14)))).toList();
    for (final s in recent) {
      buf.writeln('- ${s.bodyDetailLabel} 严重度 ${s.severity}/10');
      tagSet.add(s.bodyDetailLabel);
    }
    if (recent.isEmpty) buf.writeln('暂无近期记录');
    buf.writeln('\n## 我想问\n\n');
    _contentCtrl.text = buf.toString();
    _tags.addAll(tagSet.take(5));
  }

  @override
  void dispose() { _titleCtrl.dispose(); _contentCtrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('分享经历'), actions: [
        TextButton(onPressed: _submit, child: const Text('发布')),
      ]),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          TextField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: '标题', hintText: '一句话描述你的情况'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _contentCtrl,
            maxLines: 10,
            decoration: const InputDecoration(labelText: '详细描述', hintText: '你的症状、做过的检查、想获得什么帮助...', alignLabelWithHint: true),
          ),
          const SizedBox(height: 12),
          Row(children: [
            const Text('症状标签', style: TextStyle(fontWeight: FontWeight.w500)),
            const Spacer(),
            Switch(value: _isAnonymous, onChanged: (v) => setState(() => _isAnonymous = v)),
            const Text('匿名', style: TextStyle(fontSize: 12)),
          ]),
          Wrap(spacing: 6, runSpacing: 4, children: _tags.map((t) => Chip(
            label: Text(t, style: const TextStyle(fontSize: 12)),
            deleteIcon: const Icon(Icons.close, size: 14),
            onDeleted: () => setState(() => _tags.remove(t)),
          )).toList()),
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
      title: _titleCtrl.text.trim(), content: _contentCtrl.text.trim(),
      symptomTags: List.from(_tags), bodyParts: ['general'],
      durationTag: 'months', diagnosisStatus: 'undiagnosed',
      isAnonymous: _isAnonymous,
    );
    context.read<CommunityProvider>().add(c);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('发布成功！')));
  }
}
