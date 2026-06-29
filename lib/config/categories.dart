import 'package:flutter/material.dart';

/// 身体部位分类
class BodyParts {
  BodyParts._();

  static const categories = <String, List<BodyPartItem>>{
    '头部': [
      BodyPartItem('head', '头部整体', 'head'),
      BodyPartItem('left_temple', '左侧太阳穴', 'head'),
      BodyPartItem('right_temple', '右侧太阳穴', 'head'),
      BodyPartItem('forehead', '前额', 'head'),
      BodyPartItem('back_head', '后脑', 'head'),
      BodyPartItem('eye_left', '左眼', 'head'),
      BodyPartItem('eye_right', '右眼', 'head'),
      BodyPartItem('ear_left', '左耳', 'head'),
      BodyPartItem('ear_right', '右耳', 'head'),
      BodyPartItem('nose', '鼻子', 'head'),
      BodyPartItem('jaw', '下颌', 'head'),
    ],
    '颈肩': [
      BodyPartItem('neck', '颈部', 'neck'),
      BodyPartItem('left_shoulder', '左肩', 'neck'),
      BodyPartItem('right_shoulder', '右肩', 'neck'),
    ],
    '胸部': [
      BodyPartItem('chest_center', '胸骨/中央', 'chest'),
      BodyPartItem('chest_left', '左侧胸部', 'chest'),
      BodyPartItem('chest_right', '右侧胸部', 'chest'),
      BodyPartItem('heart_area', '心区', 'chest'),
    ],
    '腹部': [
      BodyPartItem('upper_abdomen', '上腹部', 'abdomen'),
      BodyPartItem('lower_abdomen', '下腹部', 'abdomen'),
      BodyPartItem('left_abdomen', '左侧腹部', 'abdomen'),
      BodyPartItem('right_abdomen', '右侧腹部', 'abdomen'),
      BodyPartItem('stomach', '胃区', 'abdomen'),
    ],
    '背部': [
      BodyPartItem('upper_back', '上背部', 'back'),
      BodyPartItem('lower_back', '下背部/腰部', 'back'),
      BodyPartItem('spine', '脊柱', 'back'),
    ],
    '四肢': [
      BodyPartItem('left_arm', '左臂', 'limb'),
      BodyPartItem('right_arm', '右臂', 'limb'),
      BodyPartItem('left_hand', '左手', 'limb'),
      BodyPartItem('right_hand', '右手', 'limb'),
      BodyPartItem('left_leg', '左腿', 'limb'),
      BodyPartItem('right_leg', '右腿', 'limb'),
      BodyPartItem('left_foot', '左脚', 'limb'),
      BodyPartItem('right_foot', '右脚', 'limb'),
      BodyPartItem('left_knee', '左膝', 'limb'),
      BodyPartItem('right_knee', '右膝', 'limb'),
    ],
    '皮肤': [
      BodyPartItem('face_skin', '面部', 'skin'),
      BodyPartItem('scalp', '头皮', 'skin'),
      BodyPartItem('torso_skin', '躯干皮肤', 'skin'),
      BodyPartItem('limb_skin', '四肢皮肤', 'skin'),
    ],
    '全身': [
      BodyPartItem('general', '全身性', 'general'),
      BodyPartItem('fatigue', '乏力/疲劳', 'general'),
      BodyPartItem('fever', '发热', 'general'),
      BodyPartItem('dizzy', '头晕/眩晕', 'general'),
    ],
  };

  static List<BodyPartItem> get allItems =>
      categories.values.expand((list) => list).toList();

  static BodyPartItem? findById(String id) {
    for (final item in allItems) {
      if (item.id == id) return item;
    }
    return null;
  }
}

class BodyPartItem {
  final String id;
  final String label;
  final String category;

  const BodyPartItem(this.id, this.label, this.category);
}

/// 发作类型
class OnsetTypes {
  OnsetTypes._();

  static const list = [
    OnsetTypeItem('gradual', '逐渐出现'),
    OnsetTypeItem('sudden', '突然发作'),
    OnsetTypeItem('persistent', '持续存在'),
    OnsetTypeItem('intermittent', '间歇性'),
  ];
}

class OnsetTypeItem {
  final String id;
  final String label;
  const OnsetTypeItem(this.id, this.label);
}

/// 触发因素预设
class TriggerPresets {
  TriggerPresets._();

  static const foods = [
    '辛辣食物', '油腻食物', '乳制品', '海鲜', '酒精',
    '咖啡', '甜食', '冷饮', '坚果', '面食',
  ];

  static const activities = [
    '剧烈运动', '长时间站立', '长时间坐着', '弯腰', '爬楼梯',
    '长时间看屏幕', '熬夜', '旅行', '性活动',
  ];

  static const emotions = [
    '压力大', '焦虑', '愤怒', '悲伤', '紧张',
  ];

  static const environments = [
    '天气变化', '高温', '寒冷', '潮湿', '花粉', '灰尘',
    '烟雾', '空调', '噪音',
  ];
}

/// 缓解方式预设
class ReliefPresets {
  ReliefPresets._();

  static const list = [
    '休息', '睡眠', '热敷', '冷敷', '按摩',
    '止痛药', '中药', '针灸', '推拿', '运动',
    '热水澡', '喝水', '调整饮食', '放松/冥想', '改变姿势',
  ];
}

/// 餐型
class MealTypes {
  MealTypes._();

  static const list = [
    MealTypeItem('breakfast', '早餐', Icons.wb_sunny_outlined),
    MealTypeItem('lunch', '午餐', Icons.wb_sunny),
    MealTypeItem('dinner', '晚餐', Icons.nights_stay),
    MealTypeItem('snack', '零食', Icons.cookie),
  ];
}

class MealTypeItem {
  final String id;
  final String label;
  final IconData icon;
  const MealTypeItem(this.id, this.label, this.icon);
}

/// 压力来源
class StressSources {
  StressSources._();

  static const list = [
    StressSourceItem('work', '工作', Icons.work),
    StressSourceItem('family', '家庭', Icons.family_restroom),
    StressSourceItem('health', '健康', Icons.favorite),
    StressSourceItem('financial', '财务', Icons.attach_money),
    StressSourceItem('other', '其他', Icons.more_horiz),
  ];
}

class StressSourceItem {
  final String id;
  final String label;
  final IconData icon;
  const StressSourceItem(this.id, this.label, this.icon);
}
