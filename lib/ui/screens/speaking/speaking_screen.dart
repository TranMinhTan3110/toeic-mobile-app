import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import '../../../data/models/speaking_part_info.dart';
import '../../../providers/speaking_provider.dart';
import '../../widgets/practice/skill_card.dart';
import '../../widgets/speaking/speaking_history_section.dart';
import 'speaking_prep_screen.dart';

class SpeakingScreen extends StatefulWidget {
  const SpeakingScreen({super.key});

  @override
  State<SpeakingScreen> createState() => _SpeakingScreenState();
}

class _SpeakingScreenState extends State<SpeakingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<SpeakingProvider>();
      for (var part in SpeakingPartInfo.parts) {
        provider.fetchQuestionsByPart(part.partNumber, practiceMode: true);
      }
      provider.fetchHistory();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: Consumer<SpeakingProvider>(
        builder: (context, provider, child) {
          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () async {
              for (var part in SpeakingPartInfo.parts) {
                await provider.fetchQuestionsByPart(
                  part.partNumber,
                  practiceMode: true,
                  forceRefresh: true,
                );
              }
              await provider.fetchHistory(forceRefresh: true);
            },
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                Builder(
                  builder: (context) {
                    final historyItems = provider.historyItems;
                    final totalSessions = historyItems.length;
                    final avgScore = historyItems.isNotEmpty
                        ? historyItems.map((item) => item.score).reduce((a, b) => a + b) / historyItems.length
                        : 0.0;
                    final estimatedToeic = (avgScore * 20).round();

                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Container(
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
                              child: const Icon(Icons.mic_rounded, size: 40, color: Colors.white),
                            ),
                            const SizedBox(width: 20),
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
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
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
                        'Chọn phần luyện tập',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${SpeakingPartInfo.parts.length} phần',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                ...SpeakingPartInfo.parts.map(
                  (part) {
                    final questions = provider.getQuestionsForPart(
                      part.partNumber,
                      practiceMode: true,
                    );
                    final totalCount = questions.length;
                    
                    final partHistory = provider.historyItems
                        .where((h) => h.partNumber == part.partNumber)
                        .toList();
                    final maxScore = partHistory.isNotEmpty
                        ? partHistory.map((h) => h.score).reduce((a, b) => a > b ? a : b)
                        : 0.0;
                    
                    final hasProgress = partHistory.isNotEmpty;
                    
                    final subtitleText = hasProgress
                        ? 'Điểm cao nhất: ${maxScore.toStringAsFixed(1)}/10 (${(maxScore * 20).round()}/200 TOEIC)'
                        : 'Số câu hỏi: $totalCount câu';
                    
                    return SkillCard(
                      partNumber: part.partNumber,
                      title: part.titleVi,
                      subtitle: subtitleText,
                      progress: hasProgress ? maxScore / 10.0 : null,
                      isLocked: false,
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SpeakingPrepScreen(part: part),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 24),
                SpeakingHistorySection(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'Luyện nói',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }
}
