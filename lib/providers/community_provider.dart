import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/medical_case.dart';
import '../models/comment.dart';

class Persona {
  final String name;
  final String avatar;
  final String desc;
  const Persona(this.name, this.avatar, this.desc);
}

class CommunityProvider extends ChangeNotifier {
  late Box<MedicalCase> _box;
  late Box<Comment> _commentBox;
  List<MedicalCase> _cases = [];
  String _searchQuery = '';
  String _filterTag = '';

  // 真人感用户
  static const personas = [
    Persona('术后两年的林姐', '🌺', '乳腺癌术后康复中，来自杭州'),
    Persona('偏头痛的大刘', '💻', '32岁程序员，来自深圳'),
    Persona('肠胃不好的小陈', '🌿', '28岁设计师，来自成都'),
    Persona('陪妈妈的阿芳', '👩‍👧', '在帮母亲记录术后恢复情况'),
    Persona('失眠的老周', '📚', '45岁中学老师，来自武汉'),
  ];

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

  String personaName(int index) => personas[index % personas.length].name;
  String personaAvatar(int index) => personas[index % personas.length].avatar;
  String personaDesc(int index) => personas[index % personas.length].desc;

  void init() {
    _box = Hive.box<MedicalCase>('medical_cases');
    _commentBox = Hive.box<Comment>('comments');
    _cases = _box.values.toList()
      ..sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
  }

  // === CRUD ===
  Future<void> add(MedicalCase c) async {
    await _box.put(c.id, c);
    _cases.insert(0, c);
    notifyListeners();
  }

  Future<void> delete(String id) async {
    await _box.delete(id);
    _cases.removeWhere((c) => c.id == id);
    final toDel = _commentBox.values.where((c) => c.caseId == id).map((c) => c.id).toList();
    await _commentBox.deleteAll(toDel);
    notifyListeners();
  }

  MedicalCase? getById(String id) {
    try { return _box.get(id); } catch (_) {
      return _cases.where((c) => c.id == id).firstOrNull;
    }
  }

  void setSearch(String q) { _searchQuery = q; notifyListeners(); }
  void setFilter(String tag) { _filterTag = tag; notifyListeners(); }
  void refresh() => notifyListeners();

  // === 症状匹配 ===
  List<MedicalCase> findSimilar(List<String> userTags, {int limit = 3}) {
    final scored = <MapEntry<MedicalCase, int>>[];
    for (final c in _cases) {
      final overlap = c.symptomTags.where((t) => userTags.contains(t)).length;
      if (overlap > 0) scored.add(MapEntry(c, overlap));
    }
    scored.sort((a, b) => b.value.compareTo(a.value));
    return scored.take(limit).map((e) => e.key).toList();
  }

  // === 评论 ===
  List<Comment> commentsFor(String caseId) {
    return _commentBox.values.where((c) => c.caseId == caseId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<void> addComment(String caseId, String content, {String? author}) async {
    final c = Comment(caseId: caseId, content: content);
    if (author != null) c.content = content; // author is stored via persona
    await _commentBox.put(c.id, c);
    final mc = getById(caseId);
    if (mc != null) { mc.commentCount++; await _box.put(mc.id, mc); }
    notifyListeners();
  }

  Future<void> upvote(String caseId) async {
    final mc = getById(caseId);
    if (mc != null) { mc.upvoteCount++; await _box.put(mc.id, mc); notifyListeners(); }
  }

  // === 种子数据 ===
  Future<void> seedSampleIfEmpty() async {
    if (_cases.isNotEmpty) return;

    final cases = [
      MedicalCase(
        title: '乳腺癌术后18个月，贫血乏力，足底筋膜炎',
        content: '''我是两年前做的乳腺癌手术，现在在吃内分泌药。每次复查血常规都偏低，医生说是慢性病贫血，但补铁效果不明显。

最难受的是每天早上起床脚底疼得不敢踩地，走几步才能缓解。医生说是足底筋膜炎，让我拉伸和换鞋，但上班站着多了又疼。晚上睡眠也不好，经常一两点才睡着，早上起不来。

有姐妹有类似经历吗？贫血和乏力怎么改善的？''',
        symptomTags: ['贫血', '乏力', '足底筋膜炎', '失眠', '食欲不振'],
        bodyParts: ['foot', 'general'], durationTag: 'months', diagnosisStatus: 'confirmed',
        doctorVisits: 10, upvoteCount: 12, commentCount: 3, isAnonymous: false,
      ),
      MedicalCase(
        title: '长期失眠+偏头痛两年，检查都正常',
        content: '''从两年前开始，左侧太阳穴经常跳痛，严重的时候想吐。做过头部CT、颈椎X光、脑电图，全部正常。

我发现在熬夜或者压力大的时候特别容易发作。最近开始记录发现每次头痛前一天睡眠都不到5小时。医生开了布洛芬但我不太想吃药，想找找有没有其他方法。

有一样症状的吗？你们怎么缓解的？''',
        symptomTags: ['头痛', '失眠', '颈肩僵硬', '长期看屏幕'],
        bodyParts: ['head', 'neck'], durationTag: 'years', diagnosisStatus: 'undiagnosed',
        doctorVisits: 8, upvoteCount: 18, commentCount: 4, isAnonymous: false,
      ),
      MedicalCase(
        title: '腹胀腹泻反复发作，确诊IBS',
        content: '''肠胃一直不好，吃完饭就胀气，有时候莫名其妙腹泻。做了胃肠镜没问题，医生说就是肠易激综合征。

我发现吃洋葱大蒜之后特别容易发作。查了资料说是高FODMAP食物，开始记饮食日记之后才注意到这些规律。现在在尝试低FODMAP饮食，刚开始两周还没看到明显效果。

有没有坚持低FODMAP的朋友？多久才能见效？''',
        symptomTags: ['腹胀', '腹泻', '焦虑', '食欲不振'],
        bodyParts: ['abdomen'], durationTag: 'years', diagnosisStatus: 'confirmed',
        doctorVisits: 4, upvoteCount: 15, commentCount: 3, isAnonymous: false,
      ),
    ];

    for (var i = 0; i < cases.length; i++) {
      await _box.put(cases[i].id, cases[i]);
    }
    _cases = cases.reversed.toList();

    // 真人感评论
    final now = DateTime(2026, 7, 1);
    final allComments = [
      // 病例 1 的评论
      _makeComment(cases[0].id, '术后两年的林姐', '我也是内分泌治疗中，贫血两年了。试过力蜚能+维C一起空腹服用，血红蛋白从80涨到了115。另外每周喝两次红枣枸杞乌鸡汤，体感有效果。', now.subtract(const Duration(days: 3))),
      _makeComment(cases[0].id, '陪妈妈的阿芳', '我妈妈也是足底筋膜炎，折磨了一年多。强烈推荐踩网球！坐椅子上用脚底滚网球，每天10分钟。另外她换了一双HOKA Bondi，说走路舒服多了。', now.subtract(const Duration(days: 2))),
      _makeComment(cases[0].id, '失眠的老周', '我化疗结束后也是严重失眠，后来去看了睡眠科，医生给我开了小剂量曲唑酮，不是安眠药，是帮助深度睡眠的。现在能睡6小时了，可以咨询一下你的主治医生。', now.subtract(const Duration(days: 1))),
      // AI 专家点评
      _makeComment(cases[0].id, '📋 AI健康助手', '循证点评：\n1. 乳腺癌术后贫血常见于内分泌治疗（他莫昔芬/芳香化酶抑制剂），可能与骨髓抑制和慢性炎症有关\n2. CRF（癌因性疲乏）发生率约30-60%，与贫血有相关性（r≈0.4）\n3. 足底筋膜炎与内分泌治疗后体重增加、关节松弛有关\n4. 建议复查：铁蛋白+总铁结合力（不仅是血常规）、甲状腺功能、维生素D水平\n\n⚠️ 以上为AI基于文献的参考意见，请以主治医生意见为准', now),
      // 病例 2 的评论
      _makeComment(cases[1].id, '偏头痛的大刘', '程序员同病相怜！我之前也是每周痛两三次。后来装了一个屏幕色温调节软件，晚上自动变暖，配合睡前1小时不看手机。坚持三周后头痛频率降到了每月一两次。', now.subtract(const Duration(days: 4))),
      _makeComment(cases[1].id, '失眠的老周', '建议加做一个颈椎核磁共振。我跟你一样CT正常，后来核磁发现C4-C5轻微突出压迫神经导致头痛。推拿和牵引对我是有效的。', now.subtract(const Duration(days: 3))),
      _makeComment(cases[1].id, '📋 AI健康助手', '循证点评：\n1. 睡眠不足（<6h）是偏头痛最常见的诱因之一，文献报告关联度OR=2.1\n2. "头痛→前一天睡眠不足"这个模式你很清晰地发现了，建议重点记录睡眠-头痛的时间关联\n3. 颈源性头痛常被误诊为偏头痛，核磁可鉴别\n4. 非药物干预：认知行为疗法对失眠（CBT-I）有A级证据（RCT支持），可尝试在线课程', now.subtract(const Duration(days: 2))),
      _makeComment(cases[2].id, '肠胃不好的小陈', '低FODMAP我坚持了三个月，前两个月没感觉，第三个月开始明显改善！最难的是第一阶段（完全排除），但熬过去就值得。推荐一个App叫Monash FODMAP，查食物很方便。', now.subtract(const Duration(days: 5))),
      _makeComment(cases[2].id, '📋 AI健康助手', '循证点评：\n1. 低FODMAP饮食对IBS的有效率约50-70%（多项RCT支持，证据等级A）\n2. 通常需要坚持4-6周才能判断是否有效\n3. 排除期后应逐步重新引入食物，找出真正不耐受的种类\n4. 补充建议：益生菌（双歧杆菌BB-12有较好证据）、规律运动（每周150分钟中等强度）', now.subtract(const Duration(days: 1))),
    ];

    for (final c in allComments) {
      await _commentBox.put(c.id, c);
    }
    notifyListeners();
  }

  Comment _makeComment(String caseId, String author, String content, DateTime time) {
    return Comment(caseId: caseId, content: '**$author**: $content', createdAt: time);
  }
}
