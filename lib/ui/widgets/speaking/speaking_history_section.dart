import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

// ── Model dữ liệu lịch sử nói ───────────────────────────────────────────────
class SpeakingHistoryItem {
  final int attemptNumber;
  final String partTitle;
  final int questionCount;
  final String date;
  final double score; // thang điểm 10
  final String feedbackSummary;
  final Map<String, double> criteria; // Phát âm, Độ trôi chảy, Từ vựng, v.v.

  const SpeakingHistoryItem({
    required this.attemptNumber,
    required this.partTitle,
    required this.questionCount,
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
      partTitle: 'Phần 1 – Đọc văn bản',
      questionCount: 1,
      date: 'Hôm nay • 15:30',
      score: 8.5,
      feedbackSummary: 'Phát âm rõ ràng, trôi chảy, ngữ điệu tự nhiên. Tuy nhiên cần chú ý ngắt nghỉ đúng chỗ ở các câu ghép.',
      criteria: {
        'Phát âm': 8.5,
        'Lưu loát': 9.0,
        'Ngữ điệu': 8.0,
      },
    ),
    SpeakingHistoryItem(
      attemptNumber: 2,
      partTitle: 'Phần 2 – Mô tả tranh',
      questionCount: 1,
      date: 'Hôm qua • 10:15',
      score: 7.2,
      feedbackSummary: 'Mô tả có cấu trúc tốt, từ vựng phong phú. Cần tăng tốc độ nói một chút để kịp thời gian quy định.',
      criteria: {
        'Phát âm': 7.5,
        'Lưu loát': 7.0,
        'Từ vựng': 7.0,
      },
    ),
    SpeakingHistoryItem(
      attemptNumber: 1,
      partTitle: 'Phần 5 – Thể hiện quan điểm',
      questionCount: 2,
      date: '23/05/2026 • 19:40',
      score: 6.5,
      feedbackSummary: 'Đưa ra ý kiến rõ ràng nhưng các lập luận hỗ trợ chưa thực sự sâu sắc. Còn mắc một số lỗi ngữ pháp cơ bản.',
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
        // Tiêu đề section (đồng bộ thiết kế với phần "Chọn phần luyện tập")
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'Lịch sử luyện tập',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '${_mockHistory.length} lần làm',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 4),

        // Danh sách thẻ lịch sử
        ..._mockHistory.map((item) => SpeakingHistoryCard(item: item)),
      ],
    );
  }
}

// ── Widget phụ: Thẻ lịch sử có thể mở rộng (Expandable Card) ────────────────
class SpeakingHistoryCard extends StatefulWidget {
  final SpeakingHistoryItem item;

  const SpeakingHistoryCard({super.key, required this.item});

  @override
  State<SpeakingHistoryCard> createState() => _SpeakingHistoryCardState();
}

class _SpeakingHistoryCardState extends State<SpeakingHistoryCard> {
  bool _isExpanded = false;

  Color _getScoreColor(double score) {
    if (score >= 8.0) return AppColors.success;
    if (score >= 6.0) return AppColors.warning;
    return AppColors.error;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isExpanded ? AppColors.primary.withOpacity(0.4) : AppColors.border.withOpacity(0.3),
          width: _isExpanded ? 1.5 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: _isExpanded ? AppColors.primary.withOpacity(0.06) : AppColors.shadow.withOpacity(0.4),
            blurRadius: _isExpanded ? 12 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header của thẻ
                Row(
                  children: [
                    // Badge icon mic màu cam
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.mic_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    // Tiêu đề phần & ngày làm
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Lần làm #${widget.item.attemptNumber}',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '${widget.item.partTitle} • ${widget.item.questionCount} câu',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            widget.item.date,
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.textHint,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Điểm số & nút mở rộng
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${widget.item.score.toStringAsFixed(1)} điểm',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: _getScoreColor(widget.item.score),
                          ),
                        ),
                        const SizedBox(width: 6),
                        AnimatedRotation(
                          turns: _isExpanded ? 0.5 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            color: AppColors.primary,
                            size: 20,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                // Nội dung mở rộng (Chi tiết điểm tiêu chí & Nhận xét AI)
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                  child: _isExpanded
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 14),
                            const Divider(height: 1, color: AppColors.divider),
                            const SizedBox(height: 12),

                            // Thanh điểm chi tiết các tiêu chí
                            const Text(
                              'Chi tiết các tiêu chí',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            ...widget.item.criteria.entries.map((entry) {
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 4),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 80,
                                      child: Text(
                                        entry.key,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: AppColors.textSecondary,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(4),
                                        child: LinearProgressIndicator(
                                          value: entry.value / 10.0,
                                          minHeight: 6,
                                          backgroundColor: AppColors.primaryLighter.withOpacity(0.3),
                                          valueColor: AlwaysStoppedAnimation<Color>(
                                            _getScoreColor(entry.value),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    SizedBox(
                                      width: 28,
                                      child: Text(
                                        entry.value.toStringAsFixed(1),
                                        textAlign: TextAlign.right,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: _getScoreColor(entry.value),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),

                            const SizedBox(height: 14),

                            // Khung nhận xét AI
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primarySurface.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.primaryLighter.withOpacity(0.5)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: const [
                                      Icon(
                                        Icons.auto_awesome_rounded,
                                        size: 14,
                                        color: AppColors.primaryDark,
                                      ),
                                      SizedBox(width: 6),
                                      Text(
                                        'Nhận xét từ AI',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.primaryDark,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    widget.item.feedbackSummary,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      height: 1.5,
                                      color: AppColors.textPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        )
                      : const SizedBox.shrink(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
