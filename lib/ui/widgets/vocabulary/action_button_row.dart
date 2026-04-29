import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Hàng nút hành động: Chọn, Flashcards, Chọn từ, Định nghĩa, Đặt câu, Luyện nói 
class ActionButtonRow extends StatelessWidget {
  final bool isSelectMode;
  final VoidCallback onToggleSelect;
  final VoidCallback onFlashcards;
  final VoidCallback onDefinition;
  final VoidCallback onChooseWord;
  final VoidCallback onMakeSentence;
  final VoidCallback onSpeaking;

  const ActionButtonRow({
    super.key,
    required this.isSelectMode,
    required this.onToggleSelect,
    required this.onFlashcards,
    required this.onDefinition,
    required this.onChooseWord,
    required this.onMakeSentence,
    required this.onSpeaking,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        alignment: WrapAlignment.center, // Dồn các nút vào giữa
        spacing: 6,                     
        runSpacing: 8,                   // Khoảng cách giữa 2 dòng
        children: [
          _SelectToggle(active: isSelectMode, onTap: onToggleSelect),
          _OutlinedActionBtn(label: 'Flashcards', onTap: onFlashcards),
          _OutlinedActionBtn(label: 'Chọn từ', onTap: onChooseWord),
          _OutlinedActionBtn(label: 'Định nghĩa', onTap: onDefinition),
          _OutlinedActionBtn(label: 'Đặt câu', onTap: onMakeSentence),
          _OutlinedActionBtn(label: 'Luyện nói', onTap: onSpeaking),
        ],
      ),
    );
  }
}

// ── Nút "Chọn" ────────────
class _SelectToggle extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const _SelectToggle({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppColors.primarySurface : AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: active ? AppColors.primary : AppColors.divider,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              active ? Icons.check_box : Icons.check_box_outline_blank,
              size: 16,
              color: active ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 4),
            Text(
              'Chọn',
              style: TextStyle(
                color: active ? AppColors.primary : AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Nút viền ─────
class _OutlinedActionBtn extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _OutlinedActionBtn({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), 
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.divider),
        ),
        child: Text(
          label,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
