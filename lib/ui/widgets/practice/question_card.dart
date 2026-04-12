import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';

/// Card bọc nội dung câu hỏi. Kích thước cố định (height), nội dung
/// bên trong scroll được nếu dài.
///
/// Cách dùng:
/// ```dart
/// QuestionCard(
///   questionNumber: 1,
///   totalQuestions: 10,
///   questionText: 'What does the woman say about the meeting?',
///   imagePath: 'assets/images/q1.jpg',   // tuỳ chọn
///   audioWidget: MyAudioPlayer(),         // tuỳ chọn
/// )
/// ```
class QuestionCard extends StatelessWidget {
  const QuestionCard({
    super.key,
    required this.questionNumber,
    required this.totalQuestions,
    required this.questionText,
    this.imagePath,
    this.audioWidget,
    this.height = 280,
  });

  final int questionNumber;
  final int totalQuestions;
  final String questionText;
  final String? imagePath;
  final Widget? audioWidget;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.primaryLighter, width: 1.5),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: const BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            child: Row(
              children: [
                const Icon(Icons.help_outline_rounded, color: AppColors.appBarFg, size: 16),
                const SizedBox(width: 6),
                Text(
                  'Câu $questionNumber / $totalQuestions',
                  style: const TextStyle(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          //Scrollable body
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (audioWidget != null) ...[
                    audioWidget!,
                    const SizedBox(height: 12),
                  ],
                  if (imagePath != null) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.asset(
                        imagePath!,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _ImagePlaceholder(),
                      ),
                    ),
                    const SizedBox(height: 12),
                  ],
                  Text(
                    questionText,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 15,
                      height: 1.6,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ImagePlaceholder extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Icon(Icons.image_not_supported_outlined, color: AppColors.textHint, size: 36),
    );
  }
}
