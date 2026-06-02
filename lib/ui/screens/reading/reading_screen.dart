import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/home/section_title.dart';
import 'reading_detail_screen.dart';
import 'reading_part5_screen.dart';
import 'reading_part6_screen.dart';
import 'reading_part7_screen.dart';
import '../../../providers/reading_part5_provider.dart';
import '../../../providers/reading_part6_provider.dart';
import '../../../providers/reading_part7_provider.dart';
import 'reading_history_list_screen.dart';

class ReadingScreen extends StatefulWidget {
  const ReadingScreen({super.key});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  @override
  void initState() {
    super.initState();
    // Kích hoạt preload toàn bộ 3 Part và fetch lịch sử trong background ngay khi vừa mở màn hình Đọc Hiểu
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final part5Provider = context.read<ReadingPart5Provider>();
      final part6Provider = context.read<ReadingPart6Provider>();
      final part7Provider = context.read<ReadingPart7Provider>();
      
      part5Provider.preloadInBackground();
      part5Provider.fetchHistory();
      
      part6Provider.preloadInBackground();
      part6Provider.fetchHistory();
      
      part7Provider.preloadInBackground();
      part7Provider.fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    final part5Provider = context.watch<ReadingPart5Provider>();
    final part6Provider = context.watch<ReadingPart6Provider>();
    final part7Provider = context.watch<ReadingPart7Provider>();
    
    final part5History = part5Provider.history;
    final part6History = part6Provider.history;
    final part7History = part7Provider.history;

    // Tính toán stats tổng hợp
    int totalDone = 0;
    int totalCorrect = 0;
    
    // Tính toán stats cho từng Part
    final partStats = <int, Map<String, int>>{
      5: {'correct': 0, 'total': 0},
      6: {'correct': 0, 'total': 0},
      7: {'correct': 0, 'total': 0},
    };

    // Tính stats từ Part 5
    for (var item in part5History) {
      totalDone += item.totalCount;
      totalCorrect += item.correctCount;
      partStats[5]!['correct'] = partStats[5]!['correct']! + item.correctCount;
      partStats[5]!['total'] = partStats[5]!['total']! + item.totalCount;
    }

    // Tính stats từ Part 6
    for (var item in part6History) {
      totalDone += item.totalCount;
      totalCorrect += item.correctCount;
      partStats[6]!['correct'] = partStats[6]!['correct']! + item.correctCount;
      partStats[6]!['total'] = partStats[6]!['total']! + item.totalCount;
    }

    // Tính stats từ Part 7
    for (var item in part7History) {
      totalDone += item.totalCount;
      totalCorrect += item.correctCount;
      partStats[7]!['correct'] = partStats[7]!['correct']! + item.correctCount;
      partStats[7]!['total'] = partStats[7]!['total']! + item.totalCount;
    }

    final accuracyPercent = totalDone > 0 ? (totalCorrect * 100.0 / totalDone) : 0.0;

    // Gộp lịch sử từ cả 3 part, sắp xếp theo thời gian mới nhất trước
    final allHistory = [
      ...part5History.map((h) => {'part': 5, 'item': h, 'date': h.date}),
      ...part6History.map((h) => {'part': 6, 'item': h, 'date': h.date}),
      ...part7History.map((h) => {'part': 7, 'item': h, 'date': h.date}),
    ];
    allHistory.sort((a, b) => (b['date'] as DateTime).compareTo(a['date'] as DateTime));
    final recentHistory = allHistory.take(3).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomAppBar(title: 'Đọc Hiểu', centerTitle: true),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryCard(totalDone, totalCorrect, accuracyPercent),
                  const SizedBox(height: 10),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                    child: Column(
                      children: const [
                        SectionTitle(title: 'Phần đọc hiểu'),
                        SizedBox(height: 14),
                      ],
                    ),
                  ),
                  _buildSectionsList(context, partStats),
                  const SizedBox(height: 12),
                  // Lịch sử làm bài
                  _buildHistorySection(context, recentHistory, allHistory),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(int totalDone, int totalCorrect, double accuracyPercent) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: AppColors.primaryPale,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.menu_book, size: 36, color: AppColors.primary),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Text('Số câu đã làm', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Text('$totalDone', style: const TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Text('Trả lời đúng', style: TextStyle(fontWeight: FontWeight.w600)),
                      const SizedBox(width: 8),
                      Text('$totalCorrect', style: const TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text('Hoàn thành', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: totalDone > 0 ? accuracyPercent / 100 : 0,
                      minHeight: 8,
                      backgroundColor: AppColors.primaryPale,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionsList(BuildContext context, Map<int, Map<String, int>> partStats) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Column(
        children: [
          _buildPartCard(
            context: context,
            partNumber: 5,
            title: 'Phần 5 - Điền Vào Câu',
            correctCount: partStats[5]!['correct']!,
            totalCount: partStats[5]!['total']!,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReadingPart5Screen()))
                  .then((_) {
                context.read<ReadingPart5Provider>().fetchHistory();
              });
            },
          ),
          const SizedBox(height: 12),
          _buildPartCard(
            context: context,
            partNumber: 6,
            title: 'Phần 6 - Điền Vào Đoạn Văn',
            correctCount: partStats[6]!['correct']!,
            totalCount: partStats[6]!['total']!,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReadingPart6Screen()))
                  .then((_) {
                context.read<ReadingPart6Provider>().fetchHistory();
              });
            },
          ),
          const SizedBox(height: 12),
          _buildPartCard(
            context: context,
            partNumber: 7,
            title: 'Phần 7 - Đọc Hiểu Đoạn Văn',
            correctCount: partStats[7]!['correct']!,
            totalCount: partStats[7]!['total']!,
            onTap: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ReadingPart7Screen()))
                  .then((_) {
                context.read<ReadingPart7Provider>().fetchHistory();
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPartCard({
    required BuildContext context,
    required int partNumber,
    required String title,
    required int correctCount,
    required int totalCount,
    required VoidCallback onTap,
  }) {
    double progress = totalCount > 0 ? (correctCount / totalCount) : 0.0;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 3),
            ),
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
                    color: AppColors.primaryPale,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      'P$partNumber',
                      style: const TextStyle(
                        color: AppColors.primary,
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
                        title,
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
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: AppColors.primary, size: 24),
              ],
            ),
            const SizedBox(height: 10),
            // Progress row
            Row(
              children: [
                const Text(
                  'Hoàn thành',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: AppColors.primaryLighter,
                      valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
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

  Widget _buildHistorySection(
    BuildContext context,
    List<Map<String, dynamic>> recentHistory,
    List<Map<String, dynamic>> allHistory,
  ) {
    return Column(
      children: [
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
              if (allHistory.isNotEmpty)
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ReadingHistoryListScreen(),
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
    );
  }

  Widget _buildHistoryItem(BuildContext context, Map<String, dynamic> item) {
    final part = item['part'] as int;
    final historyItem = item['item'];
    final correctCount = historyItem.correctCount as int;
    final totalCount = historyItem.totalCount as int;
    final date = historyItem.date as DateTime;

    String partTitle = '';
    switch (part) {
      case 5:
        partTitle = 'Phần 5 - Điền Vào Câu';
        break;
      case 6:
        partTitle = 'Phần 6 - Điền Vào Đoạn Văn';
        break;
      case 7:
        partTitle = 'Phần 7 - Đọc Hiểu Đoạn Văn';
        break;
      default:
        partTitle = 'Phần $part';
    }

    String formattedDate =
        '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

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
            // Có thể thêm navigation đến chi tiết lịch sử nếu cần
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
                  '$correctCount/$totalCount câu',
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
