import 'package:flutter/material.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import '../../../data/models/speaking_part_info.dart';
import '../../../data/models/speaking_history_item.dart';
import 'speaking_prep_screen.dart';
import 'speaking_history_overview_screen.dart';
import 'speaking_doing_screen.dart';

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
          'Kết quả luyện tập',
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
              ],
            ),
          ),

          // --- BUTTONS: CHI TIẾT & LÀM LẠI ---
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
    final toeicScore = (item.score * 20).round();
    
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'BẢN ĐÁNH GIÁ CHUYÊN SÂU',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.textHint,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              // Cột trái: Điểm trung bình & Ước lượng TOEIC
              Column(
                children: [
                  SizedBox(
                    width: 90,
                    height: 90,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 84,
                          height: 84,
                          child: CircularProgressIndicator(
                            value: item.score / 10.0,
                            strokeWidth: 8,
                            backgroundColor: AppColors.divider.withOpacity(0.5),
                            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              item.score.toStringAsFixed(1),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: AppColors.primary,
                                height: 1.1,
                              ),
                            ),
                            const Text(
                              '/10',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'TOEIC: $toeicScore/200',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.local_library_rounded,
                          color: Colors.orange, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        '+${item.correctCount > 0 ? (item.correctCount * 5) + 5 : 0} EP',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(width: 24),
              
              // Cột phải: Thanh tiến trình các tiêu chí chấm điểm
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: item.criteria.entries.map((entry) {
                    final key = entry.key;
                    final val = entry.value;
                    
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                key,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                              Text(
                                '${val.toStringAsFixed(1)}/10',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: LinearProgressIndicator(
                              value: val / 10.0,
                              minHeight: 6,
                              backgroundColor: AppColors.divider.withOpacity(0.4),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                val >= 7.5 ? AppColors.green : (val >= 5.0 ? Colors.orange : Colors.red),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => SpeakingHistoryOverviewScreen(
                      partNumber: item.partNumber,
                      partTitle: item.partTitle,
                      historyId: item.historyId,
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
                    builder: (_) => SpeakingDoingScreen(
                      part: partInfo,
                      questionCount: item.totalQuestions,
                      examMode: false,
                    ),
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

// Deleted unused _AccuracyIndicator widget
