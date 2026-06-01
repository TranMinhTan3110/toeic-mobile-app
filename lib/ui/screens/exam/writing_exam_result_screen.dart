import 'package:flutter/material.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import '../../../data/models/writing_exam_history_model.dart';
import 'writing_exam_screen.dart';

class WritingExamResultScreen extends StatelessWidget {
  final WritingExamHistoryModel history;

  const WritingExamResultScreen({super.key, required this.history});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Kết Quả Thi Writing',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Banner chúc mừng & Tổng điểm
            _buildScoreBanner(),
            const SizedBox(height: 20),

            // Tiêu đề danh sách câu hỏi
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'CHI TIẾT BÀI LÀM WRITING',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textHint,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Từng task trong bài thi Writing
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: history.taskResults.length,
              itemBuilder: (context, index) {
                return _buildTaskCard(history.taskResults[index], index + 1);
              },
            ),

            const SizedBox(height: 32),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => WritingExamScreen(
                            examId: history.examSetId,
                            examTitle: history.examTitle,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.replay_rounded, color: Colors.white, size: 20),
                    label: const Text(
                      'Làm lại',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 2,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(32),
                      ),
                      elevation: 2,
                    ),
                    child: const Text(
                      'Hoàn thành',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildScoreBanner() {
    final minutes = history.timeSpent ~/ 60;
    final seconds = history.timeSpent % 60;
    final timeStr = minutes > 0 ? '$minutes phút $seconds giây' : '$seconds giây';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF6A1B9A)], // Màu tím đậm sang trọng
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'BÀI THI THỬ WRITING HOÀN THÀNH',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 11,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            history.examTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
          if (history.epAwarded > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.orangeAccent.withOpacity(0.5), width: 1),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.local_library_rounded, color: Colors.orangeAccent, size: 18),
                  const SizedBox(width: 6),
                  Text(
                    '+${history.epAwarded} EP (Lần đầu hoàn thành)',
                    style: const TextStyle(
                      color: Colors.orangeAccent,
                      fontWeight: FontWeight.w900,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 24),

          // Vòng tròn điểm TOEIC Writing 0-200
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.3),
                        width: 4,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            history.toeicScore.round().toString(),
                            style: const TextStyle(
                              color: Colors.yellow,
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              height: 1.1,
                            ),
                          ),
                          const Text(
                            '/200',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Điểm TOEIC Writing',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 32),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMiniStat('Điểm trung bình AI', '${history.rawAverageScore}/10'),
                  const SizedBox(height: 12),
                  _buildMiniStat('Thời gian làm bài', timeStr),
                  const SizedBox(height: 12),
                  _buildMiniStat('Cấp độ viết', _getEvaluationLevel(history.toeicScore)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  String _getEvaluationLevel(double score) {
    if (score >= 170) return 'Professional ✨';
    if (score >= 120) return 'Effective 📈';
    return 'Basic 🌱';
  }

  String _getTaskLabel(String type) {
    switch (type) {
      case 'write_sentence':
        return 'Part 1: Viết câu theo tranh';
      case 'respond_email':
        return 'Part 2: Trả lời email';
      case 'opinion_essay':
        return 'Part 3: Viết bài luận';
      default:
        return 'Bài làm';
    }
  }

  Widget _buildTaskCard(WritingExamTaskResultModel result, int index) {
    return Card(
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 1,
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_note_rounded,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Task $index',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  Text(
                    _getTaskLabel(result.taskType),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: result.aiScore >= 6 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${result.aiScore}/10',
                style: TextStyle(
                  color: result.aiScore >= 6 ? Colors.green : Colors.orange,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
        childrenPadding: const EdgeInsets.all(16),
        expandedCrossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),

          // User Response Text
          const Text(
            'Bài viết của bạn:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            result.userAnswer.isNotEmpty ? '"${result.userAnswer}"' : '(Trống / Bạn chưa trả lời câu hỏi này)',
            style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Text(
            'Số lượng từ: ${result.wordCount} từ',
            style: const TextStyle(fontSize: 12, fontStyle: FontStyle.italic, color: Colors.grey),
          ),
          const SizedBox(height: 16),

          // AI Feedback
          const Text(
            'Đánh giá & Phản hồi chuyên môn:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF6A1B9A)),
          ),
          const SizedBox(height: 6),
          Text(
            result.aiFeedback,
            style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Criteria scores
          if (result.criteriaScores.isNotEmpty) ...[
            const Text(
              'Tiêu chí chấm điểm:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: result.criteriaScores.entries.map((entry) {
                return Chip(
                  backgroundColor: const Color(0xFF6A1B9A).withOpacity(0.08),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  label: Text(
                    '${entry.key}: ${entry.value}/10',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Color(0xFF6A1B9A)),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
