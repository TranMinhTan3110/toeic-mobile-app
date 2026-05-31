import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../widgets/writing/writing_history_section.dart';
import '../../../../data/models/writing_data.dart';
import '../../../../providers/writing_provider.dart';
import '../../../widgets/practice/skill_card.dart';

// Screens
import 'picture_description_screen.dart';
import 'respond_request_screen.dart';
import 'essay_writing_screen.dart';
import 'writing_history_screen.dart';

/// Screen danh sách 3 Part của phần Viết.
class WritingScreen extends StatefulWidget {
  const WritingScreen({super.key});

  @override
  State<WritingScreen> createState() => _WritingScreenState();
}

class _WritingScreenState extends State<WritingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WritingProvider>().fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Viết'),
      body: Consumer<WritingProvider>(
        builder: (context, provider, child) {
          final historyItems = provider.historyItems;
          final totalSessions = historyItems.length;

          final scoredItems = historyItems.where((h) => h.aiScore != null).toList();
          final avgScore = scoredItems.isNotEmpty
              ? scoredItems.map((item) => item.aiScore!.toDouble()).reduce((a, b) => a + b) / scoredItems.length
              : 0.0;
          final estimatedToeic = (avgScore * 20).round();

          return ListView(
            children: [
              // ── Stats header ───────────────────────────────────────
              _StatsCard(
                totalSessions: totalSessions,
                avgScore: avgScore,
                estimatedToeic: estimatedToeic,
              ),
              const Divider(color: AppColors.divider, height: 1),
              const SizedBox(height: 8),

              // ── Part cards ─────────────────────────────────────────
              ...WritingData.parts.map((part) {
                Widget screen;
                switch (part.partNumber) {
                  case 1:
                    screen = const PictureDescriptionScreen();
                    break;
                  case 2:
                    screen = const RespondRequestScreen();
                    break;
                  case 3:
                    screen = const EssayWritingScreen();
                    break;
                  default:
                    screen = const PictureDescriptionScreen();
                }

                final partHistory = historyItems
                    .where((h) => (h.taskNumber ?? 0) == part.partNumber)
                    .toList();
                final maxScore = partHistory.isNotEmpty
                    ? partHistory
                        .where((h) => h.aiScore != null)
                        .map((h) => h.aiScore!.toDouble())
                        .fold(0.0, (prev, element) => element > prev ? element : prev)
                    : 0.0;

                final hasProgress = partHistory.isNotEmpty;
                int qCount = 5;
                if (part.partNumber == 2) qCount = 2;
                if (part.partNumber == 3) qCount = 1;

                final subtitleText = hasProgress
                    ? 'Điểm cao nhất: ${maxScore.toStringAsFixed(1)}/10 (${(maxScore * 20).round()}/200 TOEIC)'
                    : 'Số câu hỏi: $qCount câu';

                return SkillCard(
                  partNumber: part.partNumber,
                  title: part.titleVi,
                  subtitle: subtitleText,
                  progress: hasProgress ? maxScore / 10.0 : null,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => screen),
                  ),
                );
              }),

              // ── Divider & History ───────────────────────────────────
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
                            builder: (_) => const WritingHistoryScreen(),
                          ),
                        );
                      },
                      child: const Text('Xem tất cả'),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: WritingHistorySection(),
              ),

              const SizedBox(height: 16),
            ],
          );
        },
      ),
    );
  }
}

// ── Stats card ───────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  const _StatsCard({
    required this.totalSessions,
    required this.avgScore,
    required this.estimatedToeic,
  });

  final int totalSessions;
  final double avgScore;
  final int estimatedToeic;

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
            child: const Icon(Icons.draw_rounded, size: 40, color: Colors.white),
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
                      'Lượt luyện tập:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '$totalSessions lượt',
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
                      'Điểm trung bình:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    Text(
                      '${avgScore.toStringAsFixed(1)} / 10',
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
                      '$estimatedToeic / 200',
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
                    value: totalSessions > 0 ? avgScore / 10.0 : 0.0,
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
