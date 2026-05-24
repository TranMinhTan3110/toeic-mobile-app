import 'package:flutter/material.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/vocabulary_model.dart';
import '../../screens/Vocabulary/vocabulary_detail_screen.dart';

/// Card hiển thị một từ vựng trong danh sách
class VocabularyCard extends StatelessWidget {
  final VocabularyModel word;
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
                        const SizedBox(width: 8),
                        _WordTypeBadge(type: word.wordType),
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
                  word.isStarred ? Boxicons.bxs_star : Boxicons.bx_star,
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

class _WordTypeBadge extends StatelessWidget {
  final String type;
  const _WordTypeBadge({required this.type});

  @override
  Widget build(BuildContext context) {
    Color color;
    switch (type.toLowerCase()) {
      case 'noun': case 'n': color = Colors.blue; break;
      case 'verb': case 'v': color = Colors.red; break;
      case 'adj': case 'adjective': color = Colors.green; break;
      case 'adv': case 'adverb': color = Colors.orange; break;
      default: color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color.withOpacity(0.3), width: 0.5),
      ),
      child: Text(
        type.toLowerCase(),
        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }
}

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
        decoration: const BoxDecoration(
          color: AppColors.primarySurface,
          shape: BoxShape.circle,
        ),
        child: const Icon(Boxicons.bx_volume_full, color: AppColors.primary, size: 18),
      ),
    );
  }
}
