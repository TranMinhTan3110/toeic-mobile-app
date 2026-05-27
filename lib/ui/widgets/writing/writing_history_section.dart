import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
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
              padding: EdgeInsets.all(18.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (provider.errorMessage != null) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  provider.errorMessage!,
                  style: const TextStyle(color: AppColors.error),
                ),
                const SizedBox(height: 8),
                TextButton.icon(
                  onPressed: () => provider.fetchHistory(forceRefresh: true),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Thử lại'),
                ),
              ],
            ),
          );
        }

        final items = provider.historyItems;
        if (items.isEmpty) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Chưa có lịch sử luyện tập Writing.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          separatorBuilder: (context, index) => const Divider(height: 1),
          itemBuilder: (context, index) {
            final item = items[index];
            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 8,
              ),
              leading: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.primary.withAlpha(31),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.edit_note, color: AppColors.primary),
              ),
              title: Text(
                item.sessionLabel,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              subtitle: Text(
                'Ngày ${item.formattedDate} • ${item.questionCount} câu • ${item.taskTypeLabel} • ${item.statusLabel}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => WritingHistoryDetailScreen(item: item),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
