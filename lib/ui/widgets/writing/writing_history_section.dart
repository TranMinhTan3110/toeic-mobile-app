import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/writing_history_item.dart';
import '../../../providers/writing_provider.dart';
import '../../screens/practice/writing/writing_history_detail_screen.dart';

class WritingHistorySection extends StatelessWidget {
  const WritingHistorySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<WritingProvider>(
      builder: (context, provider, child) {
        if (provider.isHistoryLoading) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          );
        }

        if (provider.errorMessage != null) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: Column(
              children: [
                Text(
                  provider.errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => provider.fetchHistory(forceRefresh: true),
                  icon: const Icon(Icons.refresh_rounded, size: 18),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final items = provider.historyItems.take(3).toList();
        if (items.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.divider),
            ),
            child: const Center(
              child: Text(
                'Chưa có lịch sử làm bài. Hãy luyện tập ngay!',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          );
        }

        return Column(
          children: items
              .map((item) => WritingHistoryCard(item: item))
              .toList(),
        );
      },
    );
  }
}

class WritingHistoryCard extends StatelessWidget {
  const WritingHistoryCard({super.key, required this.item});

  final WritingHistoryItem item;

  int get _questionCount {
    if (item.questionCount != null && item.questionCount! > 0) {
      return item.questionCount!;
    }
    if (item.questionIds.isNotEmpty) return item.questionIds.length;
    if (item.answers.isNotEmpty) return item.answers.length;
    return 1;
  }

  int get _partNumber {
    if (item.taskNumber != null && item.taskNumber! > 0) {
      return item.taskNumber!;
    }
    switch (item.taskType?.toLowerCase()) {
      case 'write_sentence':
        return 1;
      case 'respond_email':
        return 2;
      case 'opinion_essay':
        return 3;
      default:
        return 0;
    }
  }

  String get _title {
    final label = item.taskTypeLabel == '-' ? 'Writing' : item.taskTypeLabel;
    final part = _partNumber;
    return part > 0 ? 'Phần $part - $label' : label;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
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
                builder: (_) => WritingHistoryDetailScreen(item: item),
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calendar_today_rounded,
                    size: 16,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item.formattedDate,
                        style: const TextStyle(
                          color: AppColors.textHint,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '$_questionCount/$_questionCount câu',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
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
      ),
    );
  }
}
