import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import '../../../data/models/speaking_part_info.dart';
import '../../../providers/speaking_provider.dart';
import '../../widgets/practice/skill_card.dart';
import '../../widgets/practice/practice_stats_card.dart';
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
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16),
                  child: PracticeStatsCard(
                    icon: Icons.mic_rounded,
                    totalDone: 0,
                    correct: 0,
                    progress: 0.0,
                  ),
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
                    
                    return SkillCard(
                      partNumber: part.partNumber,
                      title: part.titleVi,
                      subtitle: 'Câu trả lời đúng 0/$totalCount',
                      progress: 0.0,
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
                // Xóa const ở đây để tránh lỗi biên dịch nếu widget dependency thay đổi
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
