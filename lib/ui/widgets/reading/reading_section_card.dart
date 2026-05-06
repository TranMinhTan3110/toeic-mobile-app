import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ReadingSectionCard extends StatelessWidget {
  final String title;
  final String correctCount;
  final bool showLock;
  final VoidCallback? onTap;

  const ReadingSectionCard({
    super.key,
    required this.title,
    required this.correctCount,
    this.showLock = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                  const SizedBox(height: 8),
                  Text('Câu trả lời đúng $correctCount', style: const TextStyle(color: AppColors.textMuted)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: 0,
                      minHeight: 8,
                      backgroundColor: AppColors.primaryPale,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
            if (showLock) ...[
              const SizedBox(width: 12),
              Icon(Icons.lock_outline, color: AppColors.primary, size: 22),
            ],
          ],
        ),
      ),
    );
  }
}
