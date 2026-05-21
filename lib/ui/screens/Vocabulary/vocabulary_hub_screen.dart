import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_boxicons/flutter_boxicons.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/vocabulary_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'vocabulary_screen.dart';
import 'vocabulary_notebook_screen.dart';
import 'vocabulary_review_screen.dart';
import 'review_schedule_screen.dart';

class VocabularyHubScreen extends StatefulWidget {
  const VocabularyHubScreen({super.key});

  @override
  State<VocabularyHubScreen> createState() => _VocabularyHubScreenState();
}

class _VocabularyHubScreenState extends State<VocabularyHubScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<VocabularyProvider>();
      provider.fetchMetadata();
      provider.fetchHubStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Học Từ Vựng',
        centerTitle: true,
      ),
      body: Consumer<VocabularyProvider>(
        builder: (context, provider, _) {
          final stats = provider.hubStats;
          final isLoading = provider.isLoadingHub;

          return RefreshIndicator(
            color: AppColors.primary,
            onRefresh: () => provider.fetchHubStats(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── Phần Ôn tập & Sổ tay ──────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildHubCard(
                            title: 'Sổ tay của tôi',
                            subtitle: isLoading
                                ? '...'
                                : '${stats?.starredCount ?? 0} từ đã lưu',
                            icon: Boxicons.bx_bookmark,
                            color: AppColors.primary,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const VocabularyNotebookScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildHubCard(
                            title: 'Ôn tập ngay',
                            subtitle: isLoading
                                ? '...'
                                : '${stats?.dueCount ?? 0} từ cần ôn',
                            icon: Boxicons.bx_history,
                            color: AppColors.green,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const ReviewScheduleScreen(),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Banner Tiến độ ────────────────────────────────────────
                  _buildProgressBanner(stats, isLoading),

                  const SizedBox(height: 16),

                  // ── Stats Grid ────────────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      children: [
                        Expanded(
                          child: _buildMiniStat(
                            label: 'Đã học',
                            value: isLoading ? '...' : '${stats?.studiedCount ?? 0}',
                            icon: Boxicons.bx_book_reader,
                            color: AppColors.blue,
                            bgColor: AppColors.blueBg,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMiniStat(
                            label: 'Thành thạo',
                            value: isLoading ? '...' : '${stats?.masteredCount ?? 0}',
                            icon: Boxicons.bx_medal,
                            color: AppColors.green,
                            bgColor: AppColors.greenBg,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _buildMiniStat(
                            label: 'Cần ôn',
                            value: isLoading ? '...' : '${stats?.dueCount ?? 0}',
                            icon: Boxicons.bx_time,
                            color: AppColors.primary,
                            bgColor: AppColors.primarySurface,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),
                  
                  // ── Nút Học từ vựng mới ────────────────────────────────────
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _buildBigActionCard(
                      title: 'Học từ vựng mới',
                      subtitle: 'Khám phá các chủ đề và cấp độ bài học',
                      icon: Boxicons.bx_book_open,
                      color: AppColors.purple,
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const VocabularyScreen(),
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 32),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgressBanner(dynamic stats, bool isLoading) {
    final studied = stats?.studiedCount ?? 0;
    final total = stats?.totalCount ?? 1;
    final progress = total > 0 ? studied / total : 0.0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Boxicons.bx_trending_up, color: Colors.white, size: 40),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Tiến độ học tập',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isLoading
                      ? 'Đang tải...'
                      : 'Bạn đã thuộc $studied/$total từ mục tiêu',
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: isLoading ? 0 : progress,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(color: AppColors.shadow, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildHubCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.divider),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBigActionCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.divider),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 15,
              offset: Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: color, size: 32),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Boxicons.bx_chevron_right, color: AppColors.textHint, size: 16),
          ],
        ),
      ),
    );
  }
}
