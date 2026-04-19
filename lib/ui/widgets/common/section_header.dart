import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

/// Widget header hiển thị ngay dưới AppBar, trên các thẻ card phần.
/// Thường gồm: tên phần lớn, mô tả ngắn, và thông tin tiến độ.
///
/// Cách dùng:
/// ```dart
/// SectionHeader(
///   sectionTitle: 'Phần 2',
///   sectionSubtitle: 'Question & Response',
///   currentQuestion: 3,
///   totalQuestions: 16,
/// )
/// ```
class SectionHeader extends StatelessWidget {
  const SectionHeader({
    super.key,
    required this.sectionTitle,
    this.sectionSubtitle,
    this.currentQuestion,
    this.totalQuestions,
    this.extraInfo,
  });

  final String sectionTitle;
  final String? sectionSubtitle;
  final int? currentQuestion;
  final int? totalQuestions;

  /// Nội dung tuỳ chọn ở góc phải (ví dụ: đồng hồ đếm ngược)
  final Widget? extraInfo;

  @override
  Widget build(BuildContext context) {
    final hasProgress = currentQuestion != null && totalQuestions != null;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Section badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  sectionTitle,
                  style: const TextStyle(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              if (sectionSubtitle != null)
                Expanded(
                  child: Text(
                    sectionSubtitle!,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              if (extraInfo != null) extraInfo!,
            ],
          ),
          if (hasProgress) ...[
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: currentQuestion! / totalQuestions!,
                      backgroundColor: AppColors.primaryLighter,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                      minHeight: 6,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$currentQuestion / $totalQuestions',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
