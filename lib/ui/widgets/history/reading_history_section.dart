import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/history_item_model.dart';
import 'history_row.dart';
import '../home/section_title.dart';

/// A compact, reading-specific history section (no tabs).
class ReadingHistorySection extends StatelessWidget {
  final List<HistoryItem> items;
  final int previewCount;
  final VoidCallback? onSeeAll;

  const ReadingHistorySection({
    super.key,
    required this.items,
    this.previewCount = 5,
    this.onSeeAll,
  });

  bool get _hasItems => items.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SectionTitle(title: 'Lịch sử làm bài đọc'),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.04),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: _hasItems ? _buildList(context) : _buildEmpty(),
          ),
        ],
      ),
    );
  }

  Widget _buildList(BuildContext context) {
    final visible = items.take(previewCount).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          ...visible.map((it) => Column(
            children: [
              HistoryRow(item: it),
              if (it != visible.last) Divider(height: 1, color: AppColors.border),
            ],
          )),
          if (items.length > previewCount) ...[
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: onSeeAll,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                ),
                child: const Text('Xem tất cả'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 26),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.history, size: 36, color: AppColors.textMuted.withOpacity(0.5)),
            const SizedBox(height: 8),
            Text('Chưa có lịch sử làm bài đọc', style: TextStyle(color: AppColors.textMuted.withOpacity(0.8))),
          ],
        ),
      ),
    );
  }
}
