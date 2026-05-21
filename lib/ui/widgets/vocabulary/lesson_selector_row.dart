import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import '../../../core/theme/app_colors.dart';

/// Widget hàng chọn Bài học + Cấp độ (dropdown).
class LessonSelectorRow extends StatelessWidget {
  final String selectedLesson;
  final String selectedLevel;
  final ValueChanged<String?> onLessonChanged;
  final ValueChanged<String?> onLevelChanged;

  final List<String> lessons;
  final List<String> levels;

  const LessonSelectorRow({
    super.key,
    required this.selectedLesson,
    required this.selectedLevel,
    required this.onLessonChanged,
    required this.onLevelChanged,
    required this.lessons,
    required this.levels,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(child: _buildDropdown(selectedLesson, lessons, onLessonChanged)),
          const SizedBox(width: 12),
          Expanded(child: _buildDropdown(selectedLevel, levels, onLevelChanged)),
        ],
      ),
    );
  }

  Widget _buildDropdown(
    String value,
    List<String> items,
    ValueChanged<String?> onChanged,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 0),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),  
        border: Border.all(color: AppColors.divider, width: 1.2), 
        boxShadow: const [
          BoxShadow(
            color: Color(0x05000000), // Đổ bóng siêu nhẹ
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(12), 
          dropdownColor: AppColors.surface,        
          icon: const Icon(Boxicons.bx_chevron_down, color: AppColors.textSecondary), 
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}
