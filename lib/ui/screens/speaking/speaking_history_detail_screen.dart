import 'package:flutter/material.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import '../../../data/models/speaking_part_info.dart';
import '../../widgets/speaking/speaking_history_section.dart';
import 'speaking_prep_screen.dart';
import 'speaking_history_overview_screen.dart';

class SpeakingHistoryDetailScreen extends StatelessWidget {
  final SpeakingHistoryItem item;

  const SpeakingHistoryDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    // Tìm SpeakingPartInfo tương ứng
    SpeakingPartInfo? partInfo;
    try {
      partInfo = SpeakingPartInfo.parts.firstWhere(
        (p) => p.partNumber == item.partNumber,
      );
    } catch (_) {
      partInfo = SpeakingPartInfo.parts.first;
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lịch sử luyện tập',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                // --- CARD 1: Banner chúc mừng ---
                _buildBannerCard(partInfo),
                const SizedBox(height: 16),

                // --- CARD 2: Kết quả điểm số ---
                _buildScoreDetailsCard(),
                const SizedBox(height: 16),

                // Card nhận xét AI
                _buildAiFeedbackCard(),
              ],
            ),
          ),

          // --- BUTTONS: CHI TIẾT & LÀM LẠI (Dưới cùng) ---
          _buildBottomControls(context, partInfo),
        ],
      ),
    );
  }

  Widget _buildBannerCard(SpeakingPartInfo partInfo) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary,
            AppColors.primary.withRed(220),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.emoji_events_rounded,
              color: Colors.yellow,
              size: 48,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Bạn đã hoàn thành bài luyện tập',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Part ${partInfo.partNumber} – ${partInfo.titleVi}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Hãy cố gắng hơn lần sau nhé!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreDetailsCard() {
    double percent = (item.correctCount / item.totalQuestions) * 100;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _AccuracyIndicator(percent: percent),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'KẾT QUẢ ĐẠT ĐƯỢC',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textHint,
                    letterSpacing: 1.0,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.green, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Đúng: ${item.correctCount}/${item.totalQuestions} câu',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.stars_rounded,
                        color: AppColors.primary, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      'Tỷ lệ chính xác: ${percent.toInt()}%',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAiFeedbackCard() {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.primarySurface.withOpacity(0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLighter.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 16,
                color: AppColors.primaryDark,
              ),
              SizedBox(width: 8),
              Text(
                'Nhận xét từ AI',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            item.feedbackSummary,
            style: const TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls(BuildContext context, SpeakingPartInfo partInfo) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Điều hướng đến trang TỔNG QUAN mới thiết kế
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SpeakingHistoryOverviewScreen(
                      partNumber: item.partNumber,
                      partTitle: item.partTitle,
                    ),
                  ),
                );
              },
              icon: const Icon(Icons.assignment_rounded,
                  color: Colors.white, size: 20),
              label: const Text(
                'Chi tiết',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SpeakingPrepScreen(part: partInfo),
                  ),
                );
              },
              icon: const Icon(Icons.replay_rounded,
                  color: Colors.white, size: 20),
              label: const Text(
                'Làm lại',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AccuracyIndicator extends StatelessWidget {
  final double percent;
  const _AccuracyIndicator({required this.percent});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80,
      height: 80,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: 76,
            height: 76,
            child: CircularProgressIndicator(
              value: percent / 100,
              strokeWidth: 7,
              backgroundColor: AppColors.divider.withOpacity(0.5),
              valueColor: AlwaysStoppedAnimation<Color>(
                percent >= 70 ? AppColors.green : Colors.orange,
              ),
            ),
          ),
          Text(
            '${percent.toInt()}%',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
