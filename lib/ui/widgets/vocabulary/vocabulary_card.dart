import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/vocabulary_model.dart'; // Nạp model thật thay vì model chết
import '../../screens/Vocabulary/vocabulary_detail_screen.dart'; // Thêm import màn hình chi tiết

/// Card hiển thị một từ vựng trong danh sách (Thiết kế gọn, loại bỏ input)
class VocabularyCard extends StatelessWidget {
  final VocabularyModel word; // Đổi kiểu từ VocabularyWord -> VocabularyModel

  final VoidCallback onAudio;
  final VoidCallback onStar;
  final bool isSelectMode;
  final bool isSelected;
  final VoidCallback? onSelect;

  const VocabularyCard({
    super.key,
    required this.word,
    required this.onAudio,
    required this.onStar,
    this.isSelectMode = false,
    this.isSelected = false,
    this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: InkWell(
        onTap: () {
          // Điều hướng sang màn hình chi tiết
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => VocabularyDetailScreen(word: word),
            ),
          );
        },
        borderRadius: BorderRadius.circular(15),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primarySurface : AppColors.surface,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected ? AppColors.primary : AppColors.divider,
              width: isSelected ? 1.5 : 1,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x08000000), 
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              if (isSelectMode) ...[
                Checkbox(
                  value: isSelected,
                  activeColor: AppColors.primary,
                  onChanged: (_) => onSelect?.call(),
                  visualDensity: VisualDensity.compact,
                ),
              ],
              _AudioButton(onTap: onAudio),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          word.word,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          word.phonetic,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      word.definitionVi,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: onStar,
                child: Icon(
                  word.isStarred ? Icons.star : Icons.star_border,
                  color: word.isStarred ? AppColors.star : AppColors.textHint,
                  size: 22,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Nút phát âm hình tròn nhỏ gọn hơn ─────────────────────────────────────────
class _AudioButton extends StatelessWidget {
  final VoidCallback onTap;

  const _AudioButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.primarySurface,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.volume_up, color: AppColors.primary, size: 18),
      ),
    );
  }
}
