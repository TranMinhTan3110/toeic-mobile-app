import 'package:flutter/material.dart';
import 'package:toeicmobileapp/ui/widgets/home/section_title.dart';
import '../../../core/theme/app_colors_home.dart';

class NotebookSection extends StatelessWidget {
  final int vocabularyCount;
  final int questionCount;
  final VoidCallback? onVocabReview;
  final VoidCallback? onQuestionReview;

  const NotebookSection({
    super.key,
    this.vocabularyCount = 0,
    this.questionCount = 0,
    this.onVocabReview,
    this.onQuestionReview,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Sổ tay'),
          const SizedBox(height: 14),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  Expanded(child: _buildCell(
                    icon: Icons.sort_by_alpha,
                    label: 'Từ vựng',
                    count: vocabularyCount,
                    buttonColor: AppColors.primary,
                    onTap: onVocabReview,
                  )),
                  VerticalDivider(
                    width: 1,
                    thickness: 1,
                    color: AppColors.border,
                  ),
                  Expanded(child: _buildCell(
                    icon: Icons.menu_book,
                    label: 'Câu hỏi',
                    count: questionCount,
                    buttonColor: AppColors.blue,
                    onTap: onQuestionReview,
                  )),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCell({
    required IconData icon,
    required String label,
    required int count,
    required Color buttonColor,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: buttonColor),
              const SizedBox(width: 6),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textMid,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            '$count',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: buttonColor,
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: buttonColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Ôn tập',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}