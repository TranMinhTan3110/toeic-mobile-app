import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../../providers/reading_part5_provider.dart';
import '../../../providers/reading_part6_provider.dart';
import '../../../providers/reading_part7_provider.dart';
import 'reading_part5_history_detail_screen.dart';
import 'reading_part6_history_detail_screen.dart';
import 'reading_part7_history_detail_screen.dart';

class ReadingHistoryListScreen extends StatelessWidget {
  const ReadingHistoryListScreen({super.key});

  Color _getPercentColor(double percent) {
    if (percent >= 70) return AppColors.green;
    if (percent >= 40) return Colors.orange;
    return Colors.red;
  }

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final month = dt.month.toString().padLeft(2, '0');
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$hour:$minute - $day/$month/$year';
  }

  @override
  Widget build(BuildContext context) {
    final part5Provider = context.watch<ReadingPart5Provider>();
    final part6Provider = context.watch<ReadingPart6Provider>();
    final part7Provider = context.watch<ReadingPart7Provider>();

    final isLoading = part5Provider.isHistoryLoading ||
        part6Provider.isHistoryLoading ||
        part7Provider.isHistoryLoading;

    // Gộp lịch sử từ cả 3 part, sắp xếp theo thời gian mới nhất trước
    final allHistory = [
      ...part5Provider.history.map((h) => {'part': 5, 'item': h, 'date': h.date}),
      ...part6Provider.history.map((h) => {'part': 6, 'item': h, 'date': h.date}),
      ...part7Provider.history.map((h) => {'part': 7, 'item': h, 'date': h.date}),
    ];
    allHistory.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Lịch sử ôn luyện Đọc Hiểu'),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            )
          : allHistory.isEmpty
              ? _buildEmptyState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  itemCount: allHistory.length,
                  itemBuilder: (context, index) {
                    final item = allHistory[index];
                    return _buildHistoryItemCard(context, item);
                  },
                ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 64,
            color: AppColors.textHint.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Chưa có lịch sử luyện tập',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Hãy bắt đầu làm bài luyện tập đọc\nđể lưu lại tiến độ học của bạn!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItemCard(BuildContext context, Map<String, dynamic> item) {
    final part = item['part'] as int;
    final historyItem = item['item'];
    final correctCount = historyItem.correctCount as int;
    final totalCount = historyItem.totalCount as int;
    final percent = historyItem.percent as double;
    final date = historyItem.date as DateTime;

    final percentColor = _getPercentColor(percent);

    String partTitle = '';
    switch (part) {
      case 5:
        partTitle = 'Phần 5 – Điền Vào Câu';
        break;
      case 6:
        partTitle = 'Phần 6 – Điền Vào Đoạn Văn';
        break;
      case 7:
        partTitle = 'Phần 7 – Đọc Hiểu Đoạn Văn';
        break;
      default:
        partTitle = 'Phần $part';
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        onTap: () {
          Widget detail;
          switch (part) {
            case 5:
              detail = ReadingPart5HistoryDetailScreen(historyItem: historyItem);
              break;
            case 6:
              detail = ReadingPart6HistoryDetailScreen(historyItem: historyItem);
              break;
            case 7:
              detail = ReadingPart7HistoryDetailScreen(historyItem: historyItem);
              break;
            default:
              return;
          }
          Navigator.push(context, MaterialPageRoute(builder: (_) => detail));
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.divider),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.calendar_today_rounded,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      partTitle,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(date),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textHint,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '$correctCount/$totalCount câu',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${percent.toInt()}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: percentColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textHint,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
