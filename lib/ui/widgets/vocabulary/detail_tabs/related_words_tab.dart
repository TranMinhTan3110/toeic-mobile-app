import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';

class RelatedWordsTab extends StatelessWidget {
  final List<String> synonyms;
  final List<String> antonyms;
  final List<String> collocations;

  const RelatedWordsTab({
    super.key,
    required this.synonyms,
    required this.antonyms,
    required this.collocations,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWordChipSection(
            title: 'Từ đồng nghĩa',
            words: synonyms,
            chipColor: AppColors.primarySurface,
            textColor: AppColors.primary,
          ),
          const SizedBox(height: 32),
          _buildWordChipSection(
            title: 'Từ trái nghĩa',
            words: antonyms,
            chipColor: const Color(0xFFF5F5F5),
            textColor: AppColors.textPrimary,
          ),
          const SizedBox(height: 32),
          _buildWordChipSection(
            title: 'Cụm từ thường gặp (Collocations)',
            words: collocations,
            chipColor: const Color(0xFFE3F2FD),
            textColor: Colors.blue.shade700,
          ),
        ],
      ),
    );
  }

  Widget _buildWordChipSection({
    required String title,
    required List<String> words,
    required Color chipColor,
    required Color textColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: textColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (words.isEmpty)
          Text(
            'Chưa có dữ liệu cho mục này.',
            style: TextStyle(color: AppColors.textSecondary.withOpacity(0.6)),
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: words.map((word) {
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: chipColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  word,
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}
