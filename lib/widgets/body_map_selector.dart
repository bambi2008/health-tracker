import 'package:flutter/material.dart';
import '../config/categories.dart';

class BodyMapSelector extends StatefulWidget {
  final String selectedBodyPart;
  final String selectedBodyDetail;
  final void Function(String bodyPart, String detail, String detailLabel) onPartSelected;

  const BodyMapSelector({
    super.key,
    required this.selectedBodyPart,
    required this.selectedBodyDetail,
    required this.onPartSelected,
  });

  @override
  State<BodyMapSelector> createState() => _BodyMapSelectorState();
}

class _BodyMapSelectorState extends State<BodyMapSelector> {
  int _selectedCategoryIndex = 0;

  List<String> get _categoryNames => BodyParts.categories.keys.toList();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 人体简图 + 大区选择
        Expanded(
          child: Column(
            children: [
              const SizedBox(height: 8),
              // 大区选择
              Expanded(
                child: _buildBodyMap(),
              ),
              const SizedBox(height: 12),
              // 部位列表
              _buildDetailSelector(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildBodyMap() {
    // 用彩色卡片表示身体大区
    final regions = [
      _Region('头部', 'head', Colors.red.shade200, Icons.face),
      _Region('颈肩', 'neck', Colors.pink.shade200, Icons.accessibility_new),
      _Region('胸部', 'chest', Colors.purple.shade200, Icons.favorite),
      _Region('腹部', 'abdomen', Colors.deepPurple.shade200, Icons.straighten),
      _Region('背部', 'back', Colors.indigo.shade200, Icons.airline_seat_flat),
      _Region('四肢', 'limb', Colors.blue.shade200, Icons.pan_tool),
      _Region('皮肤', 'skin', Colors.green.shade200, Icons.texture),
      _Region('全身', 'general', Colors.grey.shade300, Icons.person),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.builder(
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.1,
        ),
        itemCount: regions.length,
        itemBuilder: (context, index) {
          final r = regions[index];
          final selected = widget.selectedBodyPart == r.category;
          return GestureDetector(
            onTap: () {
              // 切换到对应分类
              final catIndex = _categoryNames.indexWhere(
                  (name) => BodyParts.categories[name]?.first.category == r.category);
              if (catIndex >= 0) {
                setState(() => _selectedCategoryIndex = catIndex);
              }
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: selected
                    ? r.color
                    : r.color.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(16),
                border: selected
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary, width: 2.5)
                    : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    r.icon,
                    size: 32,
                    color: selected ? Colors.white : r.color.withValues(alpha: 0.8),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    r.label,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                      color: selected ? Colors.white : Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailSelector() {
    final category = _categoryNames[_selectedCategoryIndex];
    final items = BodyParts.categories[category] ?? [];

    return Column(
      children: [
        // 分类切换
        SizedBox(
          height: 36,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _categoryNames.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final isSelected = idx == _selectedCategoryIndex;
              return FilterChip(
                label: Text(_categoryNames[idx]),
                selected: isSelected,
                onSelected: (_) =>
                    setState(() => _selectedCategoryIndex = idx),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        // 具体部位列表
        SizedBox(
          height: 48,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, idx) {
              final item = items[idx];
              final isSelected = widget.selectedBodyDetail == item.id;
              return ChoiceChip(
                label: Text(item.label, style: const TextStyle(fontSize: 13)),
                selected: isSelected,
                onSelected: (_) => widget.onPartSelected(
                  item.category,
                  item.id,
                  item.label,
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _Region {
  final String label;
  final String category;
  final Color color;
  final IconData icon;
  const _Region(this.label, this.category, this.color, this.icon);
}
