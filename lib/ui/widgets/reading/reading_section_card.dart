import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class ReadingSectionCard extends StatelessWidget {
  final String title;
  final String correctCount;
  final bool showLock;
  final VoidCallback? onTap;
  /// Optional trailing widget shown at the end of the card (e.g. chevron)
  final Widget? trailing;
  /// Optional small badge text shown at the left (e.g. 'P5')
  final String? badgeText;

  const ReadingSectionCard({
    super.key,
    required this.title,
    required this.correctCount,
    this.showLock = false,
    this.onTap,
    this.badgeText,
    this.trailing,
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
            if (badgeText != null) ...[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    badgeText!,
                    style: const TextStyle(
                      color: AppColors.textOnPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],

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
            if (trailing != null) ...[
              const SizedBox(width: 12),
              trailing!,
            ],
          ],
        ),
      ),
    );
  }
}
