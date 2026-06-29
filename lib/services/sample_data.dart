import '../models/symptom.dart';
import '../models/sleep_log.dart';
import '../models/stress_log.dart';
import '../models/diet_log.dart';

/// 乳腺癌术后 18 个月复查案例数据
class SampleData {
  static const String caseName = '乳腺癌术后18个月复查';

  /// 生成症状数据
  static List<Symptom> symptoms() {
    final now = DateTime(2026, 6, 29);
    return [
      // 贫血相关
      Symptom(
        bodyPart: 'general',
        bodyDetail: 'general',
        severity: 6,
        description: '贫血，化验单多项指标异常。术后持续存在，面色苍白',
        onsetType: 'persistent',
        triggers: ['术后恢复期'],
        reliefs: ['补铁剂'],
        recordedAt: now.subtract(const Duration(days: 1)),
      ),
      // 乏力
      Symptom(
        bodyPart: 'general',
        bodyDetail: 'fatigue',
        severity: 8,
        description: '严重乏力，整天没精神，影响日常活动。术后一直存在，近期加重',
        onsetType: 'persistent',
        triggers: ['贫血', '睡眠不足'],
        reliefs: ['休息'],
        recordedAt: now.subtract(const Duration(days: 1)),
      ),
      // 足底筋膜炎
      Symptom(
        bodyPart: 'limb',
        bodyDetail: 'right_foot',
        severity: 8,
        description: '足底筋膜炎，站立和行走时疼痛剧烈，晨起第一步最痛',
        onsetType: 'persistent',
        triggers: ['长时间站立', '走路'],
        reliefs: ['拉伸', '按摩', '休息'],
        recordedAt: now.subtract(const Duration(days: 2)),
      ),
      Symptom(
        bodyPart: 'limb',
        bodyDetail: 'right_foot',
        severity: 7,
        description: '足底疼痛持续，下午加重',
        onsetType: 'persistent',
        triggers: ['走路'],
        reliefs: ['休息', '热敷'],
        recordedAt: now.subtract(const Duration(days: 1)),
      ),
      // 消化
      Symptom(
        bodyPart: 'abdomen',
        bodyDetail: 'stomach',
        severity: 4,
        description: '消化能力一般，胃口不好，吃得不多',
        onsetType: 'persistent',
        triggers: ['油腻食物'],
        reliefs: ['少食多餐'],
        recordedAt: now.subtract(const Duration(days: 1)),
      ),
    ];
  }

  /// 睡眠数据
  static List<SleepLog> sleeps() {
    final now = DateTime(2026, 6, 29);
    return [
      // 近一周睡眠
      SleepLog(
        sleepStart: DateTime(2026, 6, 28, 1, 30, 0),
        sleepEnd: DateTime(2026, 6, 28, 10, 0, 0),
        quality: 2,
        interruptions: 2,
        notes: '难入睡，辗转反侧到凌晨才睡着。早上起不来，醒了也很累',
        recordedDate: DateTime(2026, 6, 28),
      ),
      SleepLog(
        sleepStart: DateTime(2026, 6, 27, 2, 0, 0),
        sleepEnd: DateTime(2026, 6, 27, 9, 30, 0),
        quality: 2,
        interruptions: 3,
        notes: '入睡困难，半夜醒了几次',
        recordedDate: DateTime(2026, 6, 27),
      ),
      SleepLog(
        sleepStart: DateTime(2026, 6, 26, 1, 0, 0),
        sleepEnd: DateTime(2026, 6, 26, 11, 0, 0),
        quality: 3,
        interruptions: 1,
        notes: '周末稍微好一点，但还是难入睡',
        recordedDate: DateTime(2026, 6, 26),
      ),
      SleepLog(
        sleepStart: DateTime(2026, 6, 25, 0, 30, 0),
        sleepEnd: DateTime(2026, 6, 25, 9, 0, 0),
        quality: 2,
        interruptions: 2,
        notes: '足底疼影响入睡',
        recordedDate: DateTime(2026, 6, 25),
      ),
      SleepLog(
        sleepStart: DateTime(2026, 6, 24, 2, 0, 0),
        sleepEnd: DateTime(2026, 6, 24, 10, 30, 0),
        quality: 3,
        interruptions: 1,
        notes: '',
        recordedDate: DateTime(2026, 6, 24),
      ),
    ];
  }

  /// 压力数据
  static List<StressLog> stresses() {
    final now = DateTime(2026, 6, 29);
    return [
      StressLog(
        level: 7,
        source: 'health',
        notes: '复查焦虑，担心检查结果',
        recordedAt: now.subtract(const Duration(days: 1)),
      ),
      StressLog(
        level: 6,
        source: 'health',
        notes: '术后恢复时间长，心理压力大',
        recordedAt: now.subtract(const Duration(days: 3)),
      ),
      StressLog(
        level: 5,
        source: 'health',
        notes: '身体不适影响心情',
        recordedAt: now.subtract(const Duration(days: 5)),
      ),
    ];
  }

  /// 饮食数据
  static List<DietLog> diets() {
    return [
      DietLog(
        mealType: 'breakfast',
        waterMl: 200,
        notes: '胃口差，只喝了一碗粥',
        recordedAt: DateTime(2026, 6, 29, 8, 0),
      ),
      DietLog(
        mealType: 'lunch',
        waterMl: 150,
        notes: '半碗米饭，少量蔬菜，鱼肉两三口',
        recordedAt: DateTime(2026, 6, 29, 12, 0),
      ),
      DietLog(
        mealType: 'dinner',
        waterMl: 100,
        notes: '半碗面条，吃不太下',
        recordedAt: DateTime(2026, 6, 29, 18, 0),
      ),
      DietLog(
        mealType: 'breakfast',
        waterMl: 200,
        notes: '豆浆一杯，鸡蛋一个',
        recordedAt: DateTime(2026, 6, 28, 8, 30),
      ),
      DietLog(
        mealType: 'lunch',
        waterMl: 150,
        notes: '馄饨，吃了半碗',
        recordedAt: DateTime(2026, 6, 28, 12, 0),
      ),
      DietLog(
        mealType: 'dinner',
        waterMl: 100,
        notes: '粥一碗，小菜少许',
        recordedAt: DateTime(2026, 6, 28, 18, 30),
      ),
    ];
  }

  /// 导入全部数据到 Providers（含社区病例）
  static Future<void> importAll({
    required dynamic symptomProv,
    required dynamic dietProv,
    required dynamic sleepProv,
    required dynamic stressProv,
    required dynamic communityProv,
  }) async {
    for (final s in symptoms()) {
      await symptomProv.add(s);
    }
    for (final d in diets()) {
      await dietProv.add(d);
    }
    for (final s in sleeps()) {
      await sleepProv.add(s);
    }
    for (final s in stresses()) {
      await stressProv.add(s);
    }
    await communityProv.seedSampleIfEmpty();
  }
}
