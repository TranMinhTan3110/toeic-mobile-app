import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../../data/models/listening_data.dart';
import '../../../providers/listening_provider.dart';
import '../../../data/models/listening_history_model.dart';
import 'listening_part_detail_screen.dart';
import 'listening_history_detail_screen.dart';
import 'listening_history_list_screen.dart';

/// Screen danh sách 4 Part của phần Nghe Hiểu.
class ListeningScreen extends StatefulWidget {
  const ListeningScreen({super.key});

  @override
  State<ListeningScreen> createState() => _ListeningScreenState();
}

class _ListeningScreenState extends State<ListeningScreen> {
  @override
  void initState() {
    super.initState();
    // Kích hoạt preload toàn bộ 4 Part và fetch lịch sử trong background ngay khi vừa mở màn hình Nghe
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ListeningProvider>();
      provider.preloadAllParts();
      provider.fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ListeningProvider>();
    final history = provider.history;

    // Tính toán stats tổng hợp
    int totalDone = 0;
    int totalCorrect = 0;
    
    // Tính toán stats cho từng Part
    final partStats = <int, Map<String, int>>{
      1: {'correct': 0, 'total': 0},
      2: {'correct': 0, 'total': 0},
      3: {'correct': 0, 'total': 0},
      4: {'correct': 0, 'total': 0},
    };

    for (var item in history) {
      totalDone += item.totalCount;
      totalCorrect += item.correctCount;
      if (partStats.containsKey(item.part)) {
        partStats[item.part]!['correct'] = partStats[item.part]!['correct']! + item.correctCount;
        partStats[item.part]!['total'] = partStats[item.part]!['total']! + item.totalCount;
      }
    }

    final accuracyPercent = totalDone > 0 ? (totalCorrect * 100.0 / totalDone) : 0.0;
    final rawScore = totalDone > 0 ? (totalCorrect * 495.0 / totalDone) : 0.0;
    final estimatedScore = ((rawScore / 5).round() * 5).clamp(5, 495);

    // Lấy 3 lịch sử làm bài gần nhất
    final recentHistory = history.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Nghe Hiểu'),
      body: ListView(
        children: [
          // ── Stats header ───────────────────────────────────────
          _StatsCard(
            totalDone: totalDone,
            totalCorrect: totalCorrect,
            accuracyPercent: accuracyPercent,
            estimatedScore: estimatedScore,
          ),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 8),

          // ── Part cards ─────────────────────────────────────────
          ...ListeningData.parts.map(
            (part) {
              final stats = partStats[part.partNumber] ?? {'correct': 0, 'total': 0};
              return _PartCard(
                part: part,
                correctCount: stats['correct']!,
                totalCount: stats['total']!,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ListeningPartDetailScreen(part: part),
                  ),
                ).then((_) => provider.fetchHistory()), // Tự động reload khi quay lại
              );
            },
          ),
          
          // ── Lịch sử luyện tập ───────────────────────────────────
          if (provider.isHistoryLoading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(child: CircularProgressIndicator(color: AppColors.primary)),
            )
          else ...[
            const SizedBox(height: 8),
            const Divider(color: AppColors.divider, height: 1),
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

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      'Lịch sử luyện tập',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ListeningHistoryListScreen(),
                        ),
                      );
                    },
                    child: const Text('Xem tất cả'),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (recentHistory.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
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
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: recentHistory.map((item) => _buildHistoryItem(context, item)).toList(),
                ),
              ),
          ],
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, ListeningHistoryModel item) {
    String partTitle = '';
    switch (item.part) {
      case 1:
        partTitle = 'Phần 1 - Mô tả tranh';
        break;
      case 2:
        partTitle = 'Phần 2 - Phản hồi yêu cầu';
        break;
      case 3:
        partTitle = 'Phần 3 - Đoạn hội thoại';
        break;
      case 4:
        partTitle = 'Phần 4 - Bài nói chuyện ngắn';
        break;
      default:
        partTitle = 'Phần ${item.part}';
    }

    String formattedDate = '${item.date.day.toString().padLeft(2, '0')}/${item.date.month.toString().padLeft(2, '0')}/${item.date.year}';

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
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ListeningHistoryDetailScreen(historyItem: item),
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
                    color: AppColors.primary.withOpacity(0.08),
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
                        partTitle,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.5,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        formattedDate,
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
                  '${item.correctCount}/${item.totalCount} câu',
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


class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.totalDone,
    required this.totalCorrect,
    required this.accuracyPercent,
    required this.estimatedScore,
  });

  final int totalDone;
  final int totalCorrect;
  final double accuracyPercent;
  final int estimatedScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
        border: Border.all(color: AppColors.primary.withOpacity(0.08)),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFFF9F43), Color(0xFFFF5252)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFFF9F43).withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.headphones_rounded, size: 40, color: Colors.white),
          ),
          const SizedBox(width: 20),
          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Số câu đã làm:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '$totalDone câu',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Trả lời đúng:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '$totalCorrect câu',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Tỷ lệ chính xác:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${accuracyPercent.toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Ước lượng TOEIC:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '$estimatedScore / 495',
                      style: const TextStyle(
                        fontWeight: FontWeight.w900,
                        color: AppColors.green,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: totalDone > 0 ? (totalCorrect / totalDone) : 0.0,
                    minHeight: 8,
                    backgroundColor: AppColors.primaryLighter.withOpacity(0.5),
                    valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Part card ────────────────────────────────────────────────────────────────

class _PartCard extends StatelessWidget {
  const _PartCard({
    required this.part,
    required this.onTap,
    required this.correctCount,
    required this.totalCount,
  });

  final ListeningPartInfo part;
  final VoidCallback onTap;
  final int correctCount;
  final int totalCount;

  @override
  Widget build(BuildContext context) {
    double progress = totalCount > 0 ? (correctCount / totalCount) : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
                color: AppColors.shadow,
                blurRadius: 10,
                offset: Offset(0, 3)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Part icon badge
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'P${part.partNumber}',
                      style: const TextStyle(
                        color: AppColors.textOnPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Part ${part.partNumber} – ${part.titleVi}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Câu trả lời đúng  $correctCount/$totalCount',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.primary, size: 24),
              ],
            ),
            const SizedBox(height: 10),
            // Progress row
            Row(
              children: [
                const Text('Hoàn thành',
                    style: TextStyle(
                        color: AppColors.textSecondary, fontSize: 12)),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: AppColors.primaryLighter,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                      minHeight: 5,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${(progress * 100).toInt()}%',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
