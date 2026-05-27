import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../data/models/writing_history_item.dart';

class WritingHistoryDetailScreen extends StatelessWidget {
  final WritingHistoryItem item;

  const WritingHistoryDetailScreen({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        title: const Text('Chi tiết Writing'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _InfoCard(item: item),
          const SizedBox(height: 16),
          _DetailCard(item: item),
          const SizedBox(height: 16),
          if (item.hasQuestionSession) _SessionDetailCard(item: item),
          const SizedBox(height: 16),
          _UserAnswerCard(answer: item.userAnswer, answers: item.answers),
          const SizedBox(height: 16),
          if (item.hasAiFeedback)
            _AiFeedbackCard(item: item)
          else
            const _AiPlaceholderCard(),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({required this.item});
  final WritingHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          Text(
            item.sessionLabel,
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          _InfoRow(label: 'Ngày gửi', value: item.formattedDate),
          const SizedBox(height: 8),
          _InfoRow(label: 'Câu hỏi', value: item.questionId),
          const SizedBox(height: 8),
          _InfoRow(label: 'Trạng thái', value: item.statusLabel),
          const SizedBox(height: 8),
          _InfoRow(label: 'Điểm AI', value: item.aiScore?.toString() ?? '-'),
          const SizedBox(height: 8),
          _InfoRow(label: 'Số từ', value: item.wordCount?.toString() ?? '-'),
          const SizedBox(height: 8),
          _InfoRow(
            label: 'Thời gian',
            value: item.timeUsed != null ? '${item.timeUsed}s' : '-',
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.item});
  final WritingHistoryItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            'Chi tiết nộp bài',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            label: 'Question ID',
            value: item.questionId.isNotEmpty ? item.questionId : '-',
          ),
          const SizedBox(height: 6),
          _InfoRow(label: 'Task', value: item.taskTypeLabel),
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Task number',
            value: item.taskNumber?.toString() ?? '-',
          ),
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Question count',
            value: item.questionCount.toString(),
          ),
          const SizedBox(height: 6),
          _InfoRow(label: 'Session', value: item.sessionLabel),
          const SizedBox(height: 6),
          _InfoRow(label: 'Trạng thái', value: item.statusLabel),
          const SizedBox(height: 6),
          _InfoRow(label: 'Model AI', value: item.aiModel ?? '-'),
          const SizedBox(height: 6),
          _InfoRow(
            label: 'Scored at',
            value: item.scoredAt != null
                ? item.scoredAt!.toLocal().toString().split('.').first
                : '-',
          ),
          const SizedBox(height: 6),
          _InfoRow(label: 'Result ID', value: item.resultId ?? '-'),
        ],
      ),
    );
  }
}

class _SessionDetailCard extends StatelessWidget {
  const _SessionDetailCard({required this.item});
  final WritingHistoryItem item;

  @override
  Widget build(BuildContext context) {
    if (!item.hasQuestionSession) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
            'Phiên Writing',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (item.questionIds.isNotEmpty) ...[
            const Text(
              'Question IDs',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            ...item.questionIds.map(
              (id) => Text(
                id,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (item.answers.isNotEmpty) ...[
            const Text(
              'Answers',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
            const SizedBox(height: 8),
            ...item.answers.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      entry.value,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _AiFeedbackCard extends StatelessWidget {
  const _AiFeedbackCard({required this.item});
  final WritingHistoryItem item;

  @override
  Widget build(BuildContext context) {
    final feedback = item.aiFeedback;
    return Container(
      padding: const EdgeInsets.all(16),
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
            'Đánh giá AI',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          _InfoRow(label: 'Điểm AI', value: item.aiScore?.toString() ?? '-'),
          if (feedback?.grammarScore != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Grammar',
              value: feedback!.grammarScore.toString(),
            ),
          ],
          if (feedback?.vocabularyScore != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Vocabulary',
              value: feedback!.vocabularyScore.toString(),
            ),
          ],
          if (feedback?.cohesionScore != null) ...[
            const SizedBox(height: 8),
            _InfoRow(
              label: 'Cohesion',
              value: feedback!.cohesionScore.toString(),
            ),
          ],
          if (feedback?.correctionsVi != null &&
              feedback!.correctionsVi!.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Chỉnh sửa',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              feedback.correctionsVi!,
              style: const TextStyle(color: AppColors.textPrimary, height: 1.6),
            ),
          ],
          if (feedback?.suggestedImprovement != null &&
              feedback!.suggestedImprovement!.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Text(
              'Gợi ý cải thiện',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              feedback.suggestedImprovement!,
              style: const TextStyle(color: AppColors.textPrimary, height: 1.6),
            ),
          ],
        ],
      ),
    );
  }
}

class _UserAnswerCard extends StatelessWidget {
  const _UserAnswerCard({required this.answer, required this.answers});
  final String answer;
  final Map<String, String> answers;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
            'Nội dung bài viết',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          if (answers.isNotEmpty) ...[
            ...answers.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.key,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      entry.value.isNotEmpty
                          ? entry.value
                          : 'Không có nội dung. Có thể bạn chưa gửi câu trả lời.',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            Text(
              answer.isNotEmpty
                  ? answer
                  : 'Không có nội dung. Có thể bạn chưa gửi câu trả lời.',
              style: const TextStyle(color: AppColors.textPrimary, height: 1.6),
            ),
          ],
        ],
      ),
    );
  }
}

class _AiPlaceholderCard extends StatelessWidget {
  const _AiPlaceholderCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.primary.withAlpha(45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.primaryLighter.withAlpha(128)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Text(
            'Đánh giá AI',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          SizedBox(height: 10),
          Text(
            'Phần chấm điểm AI chưa được bật. Các thông tin phản hồi sẽ hiển thị ở bản cập nhật tiếp theo.',
            style: TextStyle(
              fontSize: 13,
              height: 1.6,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            '$label:',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
        ),
        Expanded(
          flex: 5,
          child: Text(
            value,
            style: const TextStyle(color: AppColors.textPrimary, fontSize: 13),
          ),
        ),
      ],
    );
  }
}
