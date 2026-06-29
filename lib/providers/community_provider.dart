import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/medical_case.dart';
import '../models/comment.dart';

class CommunityProvider extends ChangeNotifier {
  late Box<MedicalCase> _box;
  late Box<Comment> _commentBox;
  List<MedicalCase> _cases = [];
  String _searchQuery = '';
  String _filterTag = '';

  List<MedicalCase> get cases => _filteredCases;
  List<MedicalCase> get _filteredCases {
    var result = List<MedicalCase>.from(_cases);
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      result = result.where((c) =>
          c.title.toLowerCase().contains(q) ||
          c.content.toLowerCase().contains(q) ||
          c.symptomTags.any((t) => t.toLowerCase().contains(q))).toList();
    }
    if (_filterTag.isNotEmpty) {
      result = result.where((c) => c.symptomTags.contains(_filterTag)).toList();
    }
    return result;
  }

  String get searchQuery => _searchQuery;
  String get filterTag => _filterTag;
  List<String> get allTags {
    final tags = <String>{};
    for (final c in _cases) { tags.addAll(c.symptomTags); }
    return tags.toList()..sort();
  }

  void init() {
    _box = Hive.box<MedicalCase>('medical_cases');
    _commentBox = Hive.box<Comment>('comments');
    _cases = _box.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  // === 病例 CRUD ===
  Future<void> add(MedicalCase c) async {
    await _box.put(c.id, c);
    _cases.insert(0, c);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    _cases.removeWhere((c) => c.id == id);
    // also delete comments
    final toDel = _commentBox.values.where((c) => c.caseId == id).map((c) => c.id).toList();
    await _commentBox.deleteAll(toDel);
    notifyListeners();
  }

  MedicalCase? getById(String id) {
    try { return _box.get(id); } catch (_) {
      return _cases.where((c) => c.id == id).firstOrNull;
    }
  }

  // === 搜索 & 过滤 ===
  void setSearch(String q) { _searchQuery = q; notifyListeners(); }
  void setFilter(String tag) { _filterTag = tag; notifyListeners(); }
  void refresh() => notifyListeners();

  // === 评论 ===
  List<Comment> commentsFor(String caseId) {
    return _commentBox.values
        .where((c) => c.caseId == caseId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addComment(String caseId, String content) async {
    final c = Comment(caseId: caseId, content: content);
    await _commentBox.put(c.id, c);
    // update case comment count
    final mc = getById(caseId);
    if (mc != null) { mc.commentCount++; await _box.put(mc.id, mc); }
    notifyListeners();
  }

  Future<void> upvote(String caseId) async {
    final mc = getById(caseId);
    if (mc != null) { mc.upvoteCount++; await _box.put(mc.id, mc); notifyListeners(); }
  }

  // === 种子案例 ===
  Future<void> seedSampleIfEmpty() async {
    if (_cases.isNotEmpty) return;

    final cases = [
      MedicalCase(
        title: '乳腺癌术后18个月，持续贫血乏力，足底筋膜炎困扰',
        content: '''## 基本情况\n女性，乳腺癌术后18个月。\n\n## 主要症状\n- **贫血**：严重度 6/10\n- **乏力**：严重度 8/10\n- **足底筋膜炎**：严重度 8/10，晨起第一步最痛\n- **睡眠**：入睡困难+难醒，质量 2/5\n- **消化**：一般，吃得不多\n\n## 就医\n定期复查，补铁剂效果一般。\n\n## 求助\n类似经历的朋友怎么改善贫血？足底筋膜炎有什么好方法？''',
        symptomTags: ['贫血', '乏力', '足底筋膜炎', '失眠', '食欲不振'],
        bodyParts: ['foot', 'general'], durationTag: 'months', diagnosisStatus: 'confirmed',
        doctorVisits: 10, upvoteCount: 3, commentCount: 2,
      ),
      MedicalCase(
        title: '长期失眠+偏头痛，查不出原因',
        content: '''## 基本情况\n男性，32岁，程序员。\n\n## 主要症状\n- **失眠**：入睡困难，每天凌晨2-3点才能睡着\n- **偏头痛**：左侧太阳穴跳痛，严重度 7/10\n- **颈肩僵硬**：长时间看屏幕后加重\n\n## 已做检查\n头部CT、颈椎X光均正常。\n\n## 求助\n有没有人和我一样？头痛和失眠有关系吗？''',
        symptomTags: ['失眠', '头痛', '颈肩僵硬', '长期看屏幕'],
        bodyParts: ['head', 'neck'], durationTag: 'months', diagnosisStatus: 'undiagnosed',
        doctorVisits: 5, upvoteCount: 5, commentCount: 3,
      ),
      MedicalCase(
        title: '肠胃功能紊乱，反复腹胀腹泻，做完胃肠镜正常',
        content: '''## 基本情况\n女性，28岁。\n\n## 主要症状\n- **腹胀**：饭后明显，严重度 5/10\n- **间歇性腹泻**：每周2-3次，无规律\n- **焦虑**：担心身体出问题\n\n## 检查\n胃肠镜正常，血常规正常。医生说是肠易激综合征。\n\n## 求助\nIBS 怎么调理？饮食上有什么建议？''',
        symptomTags: ['腹胀', '腹泻', '焦虑', '食欲不振'],
        bodyParts: ['abdomen'], durationTag: 'months', diagnosisStatus: 'confirmed',
        doctorVisits: 3, upvoteCount: 8, commentCount: 5,
      ),
    ];

    for (final c in cases) { await _box.put(c.id, c); }
    _cases = cases.reversed.toList();

    // 种子评论
    final seedComments = [
      Comment(caseId: cases[0].id, content: '我也是乳腺癌术后，贫血持续了两年。试过力蜚能+维C一起服用，吸收好很多。另外红枣枸杞茶每天喝，血红蛋白从80涨到120。加油！', createdAt: DateTime(2026, 6, 28)),
      Comment(caseId: cases[0].id, content: '足底筋膜炎我深有体会！强烈推荐踩网球按摩足底，每天10分钟。另外换一双支撑好的鞋，HOKA 和 Brooks 都不错。', createdAt: DateTime(2026, 6, 27)),
      Comment(caseId: cases[1].id, content: '程序员+1，我也是偏头痛+失眠。试过调整屏幕色温（f.lux），晚上10点后不用电子设备，一周就见效了。', createdAt: DateTime(2026, 6, 26)),
      Comment(caseId: cases[1].id, content: '建议查一下颈椎核磁，CT看不出软组织问题。我之前也是CT正常，核磁发现C4-C5突出压迫神经。', createdAt: DateTime(2026, 6, 25)),
      Comment(caseId: cases[2].id, content: 'IBS 饮食推荐低FODMAP，我自己坚持了两个月明显改善。洋葱、大蒜、豆类先戒掉试试', createdAt: DateTime(2026, 6, 24)),
    ];
    for (final c in seedComments) { await _commentBox.put(c.id, c); }
    notifyListeners();
  }
}
