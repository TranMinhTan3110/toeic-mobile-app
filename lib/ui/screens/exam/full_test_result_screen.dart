import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../../data/models/full_test_history_model.dart';
import 'full_test_history_overview_screen.dart';

class FullTestResultScreen extends StatelessWidget {
  final FullTestHistoryModel historyItem;

  const FullTestResultScreen({
    super.key,
    required this.historyItem,
  });

  String _formatDuration(int seconds) {
    final h = seconds ~/ 3600;
    final m = (seconds % 3600) ~/ 60;
    final s = seconds % 60;
    if (h > 0) {
      return '${h}h ${m}m ${s}s';
    }
    return '${m}m ${s}s';
  }

  @override
  Widget build(BuildContext context) {
    final accuracy = historyItem.totalCount > 0
        ? (historyItem.correctCount / historyItem.totalCount * 100).toStringAsFixed(1)
        : '0.0';

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(
          title: 'Kết quả thi thử',
          showBackButton: true,
          onBack: () => Navigator.pop(context),
        ),
        body: Column(
          children: [
            // Score Summary Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
              decoration: const BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.vertical(bottom: Radius.circular(30)),
              ),
              child: Column(
                children: [
                  Text(
                    historyItem.examTitle,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Big Circular Score Badge
                  Container(
                    width: 140,
                    height: 140,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${historyItem.totalScore}',
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                            ),
                          ),
                          const Text(
                            '/ 990',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Sub-scores Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildSubScoreColumn('LISTENING', historyItem.scoreListening),
                      Container(width: 1, height: 40, color: Colors.white30),
                      _buildSubScoreColumn('READING', historyItem.scoreReading),
                    ],
                  ),
                ],
              ),
            ),

            // Performance Details Strip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      Icons.check_circle_outline_rounded,
                      'Đúng',
                      '${historyItem.correctCount}/${historyItem.totalCount}',
                      Colors.green,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      Icons.speed_rounded,
                      'Chính xác',
                      '$accuracy%',
                      Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _buildStatCard(
                      Icons.timer_outlined,
                      'Thời gian',
                      _formatDuration(historyItem.timeSpent),
                      Colors.blue,
                    ),
                  ),
                ],
              ),
            ),

            // Tabs for Listening and Reading detail
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
              child: const TabBar(
                indicatorColor: AppColors.primary,
                labelColor: AppColors.primary,
                unselectedLabelColor: Colors.grey,
                labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                indicatorSize: TabBarIndicatorSize.tab,
                tabs: [
                  Tab(text: 'Listening'),
                  Tab(text: 'Reading'),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Tab Views
            Expanded(
              child: TabBarView(
                children: [
                  _buildListeningTab(),
                  _buildReadingTab(),
                ],
              ),
            ),

            // Action Buttons
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.primary, width: 2),
                        foregroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text(
                        'Quay lại',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullTestHistoryOverviewScreen(
                              historyItem: historyItem,
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        elevation: 2,
                      ),
                      child: const Text(
                        'Coi chi tiết',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
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

  Widget _buildSubScoreColumn(String label, int score) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 11,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '$score/495',
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 6),
          Text(
            label,
            style: const TextStyle(color: Colors.grey, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListeningTab() {
    final correct1 = historyItem.partScores['part1_correct'] ?? 0;
    final total1 = historyItem.partScores['part1_total'] ?? 6;

    final correct2 = historyItem.partScores['part2_correct'] ?? 0;
    final total2 = historyItem.partScores['part2_total'] ?? 25;

    final correct3 = historyItem.partScores['part3_correct'] ?? 0;
    final total3 = historyItem.partScores['part3_total'] ?? 39;

    final correct4 = historyItem.partScores['part4_correct'] ?? 0;
    final total4 = historyItem.partScores['part4_total'] ?? 30;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildPartBreakdownCard('Part 1', 'Mô tả tranh (Photographs)', correct1, total1),
        _buildPartBreakdownCard('Part 2', 'Hỏi & Đáp (Question-Response)', correct2, total2),
        _buildPartBreakdownCard('Part 3', 'Hội thoại ngắn (Short Conversations)', correct3, total3),
        _buildPartBreakdownCard('Part 4', 'Bài nói ngắn (Short Talks)', correct4, total4),
      ],
    );
  }

  Widget _buildReadingTab() {
    final correct5 = historyItem.partScores['part5_correct'] ?? 0;
    final total5 = historyItem.partScores['part5_total'] ?? 30;

    final correct6 = historyItem.partScores['part6_correct'] ?? 0;
    final total6 = historyItem.partScores['part6_total'] ?? 16;

    final correct7 = historyItem.partScores['part7_correct'] ?? 0;
    final total7 = historyItem.partScores['part7_total'] ?? 54;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        _buildPartBreakdownCard('Part 5', 'Hoàn thành câu (Incomplete Sentences)', correct5, total5),
        _buildPartBreakdownCard('Part 6', 'Hoàn thành đoạn văn (Text Completion)', correct6, total6),
        _buildPartBreakdownCard('Part 7', 'Đọc hiểu đoạn văn (Reading Comprehension)', correct7, total7),
      ],
    );
  }

  Widget _buildPartBreakdownCard(String partTitle, String partDesc, int correct, int total) {
    final percent = total > 0 ? correct / total : 0.0;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                partTitle,
                style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary),
              ),
              Text(
                '$correct / $total câu',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            partDesc,
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percent,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(
                percent > 0.75
                    ? Colors.green
                    : percent > 0.4
                        ? Colors.orange
                        : Colors.red,
              ),
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
