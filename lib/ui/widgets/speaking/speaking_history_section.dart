import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../screens/speaking/speaking_history_detail_screen.dart';

// ── Model dữ liệu lịch sử nói ───────────────────────────────────────────────
class SpeakingHistoryItem {
  final int attemptNumber;
  final int partNumber; // số Part để điều hướng Làm lại
  final String partTitle;
  final int correctCount; // số câu đúng/đạt
  final int totalQuestions; // tổng số câu
  final String date;
  final double score; // thang điểm 10 (vẫn giữ để dùng cho detail nếu cần)
  final String feedbackSummary;
  final Map<String, double> criteria; // Phát âm, Độ trôi chảy, Từ vựng, v.v.

  const SpeakingHistoryItem({
    required this.attemptNumber,
    required this.partNumber,
    required this.partTitle,
    required this.correctCount,
    required this.totalQuestions,
    required this.date,
    required this.score,
    required this.feedbackSummary,
    required this.criteria,
  });
}

// ── Widget chính: Section lịch sử ───────────────────────────────────────────
class SpeakingHistorySection extends StatelessWidget {
  const SpeakingHistorySection({super.key});

  // Dữ liệu mẫu (Demo) tương tự phần nghe và viết
  static const List<SpeakingHistoryItem> _mockHistory = [
    SpeakingHistoryItem(
      attemptNumber: 3,
      partNumber: 1,
      partTitle: 'Phần 1 – Đọc văn bản',
      correctCount: 8,
      totalQuestions: 15,
      date: '16/04/2026',
      score: 8.5,
      feedbackSummary:
          'Phát âm rõ ràng, trôi chảy, ngữ điệu tự nhiên. Tuy nhiên cần chú ý ngắt nghỉ đúng chỗ ở các câu ghép.',
      criteria: {
        'Phát âm': 8.5,
        'Lưu loát': 9.0,
        'Ngữ điệu': 8.0,
      },
    ),
    SpeakingHistoryItem(
      attemptNumber: 2,
      partNumber: 2,
      partTitle: 'Phần 2 – Mô tả tranh',
      correctCount: 4,
      totalQuestions: 5,
      date: '15/04/2026',
      score: 7.2,
      feedbackSummary:
          'Mô tả có cấu trúc tốt, từ vựng phong phú. Cần tăng tốc độ nói một chút để kịp thời gian quy định.',
      criteria: {
        'Phát âm': 7.5,
        'Lưu loát': 7.0,
        'Từ vựng': 7.0,
      },
    ),
    SpeakingHistoryItem(
      attemptNumber: 1,
      partNumber: 5,
      partTitle: 'Phần 5 – Thể hiện quan điểm',
      correctCount: 0,
      totalQuestions: 2,
      date: '14/04/2026',
      score: 6.5,
      feedbackSummary:
          'Đưa ra ý kiến rõ ràng nhưng các lập luận hỗ trợ chưa thực sự sâu sắc. Còn mắc một số lỗi ngữ pháp cơ bản.',
      criteria: {
        'Ngữ pháp': 6.0,
        'Từ vựng': 7.0,
        'Lưu loát': 6.5,
      },
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Divider with History Icon ───────────────────────────────────
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Row(
            children: [
              Expanded(
                child: Divider(color: AppColors.divider, thickness: 1.5),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(
                  Icons.history_rounded,
                  color: AppColors.textHint,
                  size: 20,
                ),
              ),
              Expanded(
                child: Divider(color: AppColors.divider, thickness: 1.5),
              ),
            ],
          ),
        ),

        // Tiêu đề section
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Lịch sử luyện tập',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Danh sách thẻ phẳng giống phần Viết
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: _mockHistory.map((item) => _SpeakingHistoryRow(item: item)).toList(),
          ),
        ),
      ],
    );
  }
}

// ── Widget thẻ phẳng (Flat Card) ────────────────────────────────────────────
class _SpeakingHistoryRow extends StatelessWidget {
  final SpeakingHistoryItem item;
  const _SpeakingHistoryRow({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SpeakingHistoryDetailScreen(item: item),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                // Icon lịch
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.partTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.date,
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  '${item.correctCount}/${item.totalQuestions} câu',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
