import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../providers/exam_provider.dart';
import '../../screens/exam/speaking_exam_result_screen.dart';
import '../../screens/exam/writing_exam_result_screen.dart';

class ExamHistorySheet extends StatelessWidget {
  final String examId;
  final String examTitle;
  final String skill;

  const ExamHistorySheet({
    super.key,
    required this.examId,
    required this.examTitle,
    required this.skill,
  });

  static void show(
    BuildContext context, {
    required String examId,
    required String examTitle,
    required String skill,
  }) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ExamHistorySheet(
        examId: examId,
        examTitle: examTitle,
        skill: skill,
      ),
    );
  }

  bool _isSameExam(String id1, String id2) {
    if (id1.toLowerCase() == id2.toLowerCase()) return true;
    
    String normalize(String id) {
      id = id.toLowerCase();
      if (id.startsWith('test_')) {
        final num = int.tryParse(id.substring(5));
        if (num != null) return num.toString();
      }
      if (id.startsWith('ets-wrt-2024-')) {
        final num = int.tryParse(id.substring(13));
        if (num != null) return num.toString();
      }
      if (id.startsWith('ets-spk-2024-')) {
        final num = int.tryParse(id.substring(13));
        if (num != null) return num.toString();
      }
      return id;
    }
    
    return normalize(id1) == normalize(id2);
  }

  @override
  Widget build(BuildContext context) {
    final examProvider = context.watch<ExamProvider>();
    final List<Widget> listItems = [];

    if (skill == 'speaking') {
      final speakingHistories = examProvider.speakingExamHistories
          .where((h) => _isSameExam(h.examSetId, examId))
          .toList();
      speakingHistories.sort((a, b) => b.date.compareTo(a.date));

      for (int i = 0; i < speakingHistories.length; i++) {
        final history = speakingHistories[i];
        final attemptNum = speakingHistories.length - i;
        listItems.add(_buildHistoryRow(
          context,
          title: 'Lần thi #$attemptNum',
          score: history.toeicScore.round(),
          dateStr: _formatDate(history.date),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => SpeakingExamResultScreen(history: history),
              ),
            );
          },
        ));
      }
    } else if (skill == 'writing') {
      final writingHistories = examProvider.writingExamHistories
          .where((h) => _isSameExam(h.examSetId, examId))
          .toList();
      writingHistories.sort((a, b) => b.date.compareTo(a.date));

      for (int i = 0; i < writingHistories.length; i++) {
        final history = writingHistories[i];
        final attemptNum = writingHistories.length - i;
        listItems.add(_buildHistoryRow(
          context,
          title: 'Lần thi #$attemptNum',
          score: history.toeicScore.round(),
          dateStr: _formatDate(history.date),
          onTap: () {
            Navigator.pop(context);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => WritingExamResultScreen(history: history),
              ),
            );
          },
        ));
      }
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),
          // Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Lịch sử làm đề',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        examTitle,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, color: AppColors.textSecondary),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, color: AppColors.divider),
          
          // List
          Flexible(
            child: listItems.isEmpty
                ? _buildEmptyState()
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    itemCount: listItems.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.divider),
                    itemBuilder: (_, index) => listItems[index],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryRow(
    BuildContext context, {
    required String title,
    required int score,
    required String dateStr,
    required VoidCallback onTap,
  }) {
    Color scoreColor = Colors.red;
    if (score >= 160) {
      scoreColor = AppColors.success;
    } else if (score >= 110) {
      scoreColor = Colors.orange;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child: Icon(
                    Icons.assignment_turned_in_rounded,
                    size: 18,
                    color: AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateStr,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: scoreColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$score/200',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: scoreColor,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_rounded,
            size: 48,
            color: AppColors.textMuted.withOpacity(0.4),
          ),
          const SizedBox(height: 12),
          const Text(
            'Chưa có lịch sử làm đề này',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final localDt = dt.toLocal();
    final day = localDt.day.toString().padLeft(2, '0');
    final month = localDt.month.toString().padLeft(2, '0');
    final year = localDt.year;
    final hour = localDt.hour.toString().padLeft(2, '0');
    final minute = localDt.minute.toString().padLeft(2, '0');
    return '$hour:$minute - $day/$month/$year';
  }
}
