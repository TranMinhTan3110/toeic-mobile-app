import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PracticeStatsCard extends StatelessWidget {
  const PracticeStatsCard({
    super.key,
    required this.totalDone,
    required this.correct,
    required this.progress,
    required this.icon,
  });

  final int totalDone;
  final int correct;
  final double progress;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 40, color: AppColors.primary),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              children: [
                _row('Số câu đã làm:', '$totalDone'),
                const SizedBox(height: 8),
                _row('Trả lời đúng:', '$correct'),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: AppColors.primaryLighter,
                  valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _row(String l, String v) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(l, style: const TextStyle(fontWeight: FontWeight.bold)),
        // Text(l, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(width: 12),
        Text(v, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }
}
