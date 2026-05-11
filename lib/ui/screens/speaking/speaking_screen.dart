import 'package:flutter/material.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import '../../../data/models/speaking_part_info.dart';
import '../../widgets/practice/skill_card.dart';
import '../../widgets/practice/practice_stats_card.dart';
import 'speaking_prep_screen.dart';

// ── Model dữ liệu cho từng phần ────────────────────────────────────────────
class _SpeakingPart {
  final int partNumber;
  final String title;
  final String subtitle;
  final double? progress;   // null = chưa bắt đầu
  final int totalQuestions;
  final int doneCounts;

  const _SpeakingPart({
    required this.partNumber,
    required this.title,
    required this.subtitle,
    required this.totalQuestions,
    required this.doneCounts,
    this.progress,
  });
}

// ── Màn hình chính ──────────────────────────────────────────────────────────
class SpeakingScreen extends StatelessWidget {
  const SpeakingScreen({super.key});

  // TODO: thay bằng dữ liệu từ DB / provider
  static const List<_SpeakingPart> _parts = [
    _SpeakingPart(
      partNumber: 1,
      title: 'Đọc văn bản',
      subtitle: 'Đọc to đoạn văn ngắn',
      totalQuestions: 10,
      doneCounts: 0,
      progress: null,
    ),
    _SpeakingPart(
      partNumber: 2,
      title: 'Mô tả tranh',
      subtitle: 'Mô tả hình ảnh trong 45 giây',
      totalQuestions: 10,
      doneCounts: 0,
      progress: null,
    ),
    _SpeakingPart(
      partNumber: 3,
      title: 'Trả lời câu hỏi (1)',
      subtitle: 'Trả lời dựa trên thông tin cá nhân',
      totalQuestions: 10,
      doneCounts: 0,
      progress: null,
    ),
    _SpeakingPart(
      partNumber: 4,
      title: 'Trả lời câu hỏi (2)',
      subtitle: 'Trả lời dựa trên bảng / biểu đồ',
      totalQuestions: 10,
      doneCounts: 0,
      progress: null,
    ),
    _SpeakingPart(
      partNumber: 5,
      title: 'Thể hiện quan điểm',
      subtitle: 'Trình bày ý kiến cá nhân',
      totalQuestions: 10,
      doneCounts: 0,
      progress: null,
    ),
  ];

  // ── Tổng hợp thống kê ─────────────────────────────────────────────────────
  int get _totalDone => _parts.fold(0, (sum, p) => sum + p.doneCounts);

  double get _overallProgress {
    final total = _parts.fold(0, (sum, p) => sum + p.totalQuestions);
    if (total == 0) return 0;
    return _totalDone / total;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(context),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16),
        children: [
          // ── Thẻ thống kê tổng quan ────────────────
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: PracticeStatsCard(
              icon: Icons.mic_rounded,
              totalDone: _totalDone,
              correct: 0,           // TODO: lấy từ DB
              progress: _overallProgress,
            ),
          ),

          const SizedBox(height: 24),

          // ── Tiêu đề danh sách phần ────────────────
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
                  '${_parts.length} phần',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          // ── Danh sách SkillCard ───────────────────
          ...SpeakingPartInfo.parts.map(
                (part) => SkillCard(
              partNumber: part.partNumber,
              title: part.titleVi,
              subtitle: part.descriptionVi.split('.').first + '.',
              progress: null,
              isLocked: false,
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => SpeakingPrepScreen(part: part),
                ),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  // ── AppBar ────────────────────────────────────────────────────────────────
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