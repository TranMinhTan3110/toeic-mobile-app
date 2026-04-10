import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';

/// Card dùng trong màn hình ôn luyện kỹ năng.
/// Hiển thị "Phần X – <tên phần>" kèm icon và tiến độ.
///
/// Cách dùng:
/// ```dart
/// SkillCard(
///   partNumber: 1,
///   title: 'Photographs',
///   subtitle: '10 câu hỏi',
///   progress: 0.6,         // 0.0 → 1.0, null nếu chưa bắt đầu
///   onTap: () {},
/// )
/// ```
class SkillCard extends StatelessWidget {
  const SkillCard({
    super.key,
    required this.partNumber,
    required this.title,
    this.subtitle,
    this.progress,
    this.icon,
    this.onTap,
    this.isLocked = false,
  });

  final int partNumber;
  final String title;
  final String? subtitle;

  /// 0.0 → 1.0. Null = chưa bắt đầu.
  final double? progress;

  final IconData? icon;
  final VoidCallback? onTap;
  final bool isLocked;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _CardBody(
                partNumber: partNumber,
                title: title,
                subtitle: subtitle,
                icon: icon,
                isLocked: isLocked,
                progress: progress,
              ),
              if (progress != null) _ProgressBar(value: progress!),
            ],
          ),
        ),
      ),
    );
  }
}

class _CardBody extends StatelessWidget {
  const _CardBody({
    required this.partNumber,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.isLocked,
    required this.progress,
  });

  final int partNumber;
  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool isLocked;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          // Part badge
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                'P$partNumber',
                style: const TextStyle(
                  color: AppColors.textOnPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),

          // Title + subtitle
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Phần $partNumber – $title',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
                if (progress != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '${(progress! * 100).round()}% hoàn thành',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),

          //Trailing icon
          isLocked
              ? const Icon(Icons.lock_outline, color: AppColors.textHint, size: 20)
              : const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.primary,
                  size: 24,
                ),
        ],
      ),
    );
  }
}

class _ProgressBar extends StatelessWidget {
  const _ProgressBar({required this.value});
  final double value;

  @override
  Widget build(BuildContext context) {
    return LinearProgressIndicator(
      value: value,
      backgroundColor: AppColors.primaryLighter,
      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
      minHeight: 4,
    );
  }
}
