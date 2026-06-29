import 'package:flutter/material.dart';
import '../config/theme.dart';

class SeverityPicker extends StatelessWidget {
  final int value;
  final ValueChanged<int> onChanged;

  const SeverityPicker({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppTheme.severityColor(value);
    return Column(
      children: [
        // 大数字
        Text(
          '$value',
          style: TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.w900,
            color: color,
            height: 1,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '/ 10',
          style: TextStyle(
            fontSize: 24,
            color: Colors.grey.shade500,
          ),
        ),
        const SizedBox(height: 24),
        // 滑块
        SliderTheme(
          data: SliderThemeData(
            trackHeight: 8,
            thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 14),
            activeTrackColor: color,
            inactiveTrackColor: color.withValues(alpha: 0.2),
            thumbColor: color,
            overlayColor: color.withValues(alpha: 0.2),
          ),
          child: Slider(
            value: value.toDouble(),
            min: 1,
            max: 10,
            divisions: 9,
            onChanged: (v) => onChanged(v.round()),
          ),
        ),
        // 标签
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('轻微',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500)),
              Text('剧烈',
                  style: TextStyle(
                      fontSize: 12, color: Colors.grey.shade500)),
            ],
          ),
        ),
      ],
    );
  }
}
