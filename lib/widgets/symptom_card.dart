import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/symptom.dart';
import '../config/theme.dart';
import '../config/categories.dart';

class SymptomCard extends StatelessWidget {
  final Symptom symptom;
  final VoidCallback? onTap;

  const SymptomCard({
    super.key,
    required this.symptom,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.severityColor(symptom.severity);
    final dateFmt = DateFormat('MM/dd HH:mm');
    final item = BodyParts.findById(symptom.bodyDetail);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // 部位图标
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.bodyPartColor(symptom.bodyPart)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.healing,
                      size: 20,
                      color: AppTheme.bodyPartColor(symptom.bodyPart),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item?.label ?? symptom.bodyDetail,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        if (item != null)
                          Text(
                            item.categoryLabel,
                            style: TextStyle(
                                color: Colors.grey.shade600, fontSize: 12),
                          ),
                      ],
                    ),
                  ),
                  // 严重度标签
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      symptom.severityLabel,
                      style: TextStyle(
                          color: color,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ),
                ],
              ),
              if (symptom.description.isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(
                  symptom.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey.shade700, height: 1.4),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                  const SizedBox(width: 4),
                  Text(dateFmt.format(symptom.recordedAt),
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey.shade500)),
                  const Spacer(),
                  if (symptom.triggers.isNotEmpty) ...[
                    Icon(Icons.warning_amber,
                        size: 14, color: Colors.orange.shade300),
                    const SizedBox(width: 4),
                    Text('${symptom.triggers.length}个触发因素',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade500)),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// BodyPartItem 扩展
extension BodyPartItemExt on BodyPartItem {
  String get categoryLabel {
    switch (category) {
      case 'head':
        return '头部';
      case 'neck':
        return '颈肩';
      case 'chest':
        return '胸部';
      case 'abdomen':
        return '腹部';
      case 'back':
        return '背部';
      case 'limb':
        return '四肢';
      case 'skin':
        return '皮肤';
      case 'general':
        return '全身';
      default:
        return category;
    }
  }
}
