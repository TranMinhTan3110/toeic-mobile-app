import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../../data/models/writing_data.dart';

// Screens
import 'picture_description_screen.dart';
import 'respond_request_screen.dart';
import 'essay_writing_screen.dart';

/// Screen danh sách 3 Part của phần Viết.
class WritingScreen extends StatelessWidget {
  const WritingScreen({super.key});

  // Stats tổng hợp (demo)
  static const int _totalDone = 0;
  static const int _totalCorrect = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Viết'),
      body: ListView(
        children: [
          // ── Stats header ───────────────────────────────────────
          _StatsCard(totalDone: _totalDone, totalCorrect: _totalCorrect),
          const Divider(color: AppColors.divider, height: 1),
          const SizedBox(height: 8),

          // ── Part cards ─────────────────────────────────────────
          ...WritingData.parts.map(
            (part) {
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
              return _PartCard(
                part: part,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => screen),
                ),
              );
            },
          ),

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

          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Lịch sử luyện tập',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _buildHistoryItem(
                  date: '16/04/2026',
                  part: 'Phần 1 - Mô tả tranh',
                  score: '8/15 câu',
                ),
                _buildHistoryItem(
                  date: '15/04/2026',
                  part: 'Phần 2 - Phản hồi yêu cầu',
                  score: '4/5 câu',
                ),
                _buildHistoryItem(
                  date: '14/04/2026',
                  part: 'Phần 3 - Viết luận',
                  score: '0/2 câu',
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

// ── Stats card ───────────────────────────────────────────────────────────────

class _StatsCard extends StatelessWidget {
  const _StatsCard({required this.totalDone, required this.totalCorrect});
  final int totalDone;
  final int totalCorrect;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
              color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          // Icon
          Container(
            width: 68,
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.draw_rounded,
                size: 38, color: AppColors.primary),
          ),
          const SizedBox(width: 16),
          // Stats
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _StatRow(label: 'Số câu đã làm', value: '$totalDone'),
                const SizedBox(height: 4),
                _StatRow(label: 'Trả lời đúng', value: '$totalCorrect'),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Text('Hoàn thành',
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            color: AppColors.textPrimary,
                            fontSize: 13)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: 0.0,
                          backgroundColor: AppColors.primaryLighter,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.primary),
                          minHeight: 6,
                        ),
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
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(label,
            style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
                fontSize: 13)),
        const SizedBox(width: 8),
        Text(value,
            style: const TextStyle(
                color: AppColors.textSecondary, fontSize: 13)),
      ],
    );
  }
}

// ── Part card ────────────────────────────────────────────────────────────────

class _PartCard extends StatelessWidget {
  const _PartCard({required this.part, required this.onTap});
  final WritingPartInfo part;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
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
                      const Text(
                        'Câu trả lời đúng  0/0',
                        style: TextStyle(
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
                      value: 0.0,
                      backgroundColor: AppColors.primaryLighter,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary),
                      minHeight: 5,
                    ),
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

// ── History helper ──────────────────────────────────────────────────────────

Widget _buildHistoryItem({
  required String date,
  required String part,
  required String score,
}) {
  return Container(
    margin: const EdgeInsets.only(bottom: 12),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: AppColors.divider.withOpacity(0.5)),
    ),
    child: Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppColors.surfaceVariant,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Icon(
            Icons.calendar_today_rounded,
            size: 16,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                part,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: const TextStyle(
                  color: AppColors.textHint,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Text(
          score,
          style: const TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
