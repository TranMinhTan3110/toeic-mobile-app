import 'package:flutter/material.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import '../../../data/models/speaking_exam_history_model.dart';
import 'speaking_exam_screen.dart';

class SpeakingExamResultScreen extends StatelessWidget {
  final SpeakingExamHistoryModel history;

  const SpeakingExamResultScreen({super.key, required this.history});

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
          'Kết Quả Thi Speaking',
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
                'CHI TIẾT TỪNG PHẦN THI',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textHint,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Từng task trong bài thi Speaking
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
                          builder: (_) => SpeakingExamScreen(
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
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, Color(0xFF1E3C72)],
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
            'BÀI THI THỬ HOÀN THÀNH',
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

          // Vòng tròn điểm TOEIC Speaking 0-200
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
                    'Điểm TOEIC Speaking',
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
                  _buildMiniStat('Điểm trung bình AI', '${history.rawAverageScore}/5'),
                  const SizedBox(height: 12),
                  _buildMiniStat('Số câu đã làm', '${history.totalTasks} câu'),
                  const SizedBox(height: 12),
                  _buildMiniStat('Cấp độ đánh giá', _getEvaluationLevel(history.toeicScore)),
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
    if (score >= 160) return 'Advanced 🌟';
    if (score >= 110) return 'Intermediate 📈';
    return 'Novice 🌱';
  }

  Widget _buildTaskCard(SpeakingExamTaskResultModel result, int index) {
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
                Icons.mic_rounded,
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
                    'Câu hỏi $index',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (result.subQuestionIndex != null)
                    Text(
                      'Sub-question ${result.subQuestionIndex! + 1}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: result.score >= 3.0 ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '${result.score}/5',
                style: TextStyle(
                  color: result.score >= 3.0 ? Colors.green : Colors.orange,
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

          // User Audio/Transcript
          const Text(
            'Phản hồi của bạn:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 4),
          Text(
            result.transcript.isNotEmpty ? '"${result.transcript}"' : '(Không nhận diện được giọng nói hoặc bỏ qua)',
            style: const TextStyle(fontSize: 14, fontStyle: FontStyle.italic, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // AI Feedback
          const Text(
            'Đánh giá chuyên sâu từ AI:',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueAccent),
          ),
          const SizedBox(height: 6),
          Text(
            result.feedback,
            style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Criteria scores
          if (result.criteriaScores.isNotEmpty) ...[
            const Text(
              'Điểm tiêu chí:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.blueGrey),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: result.criteriaScores.entries.map((entry) {
                return Chip(
                  backgroundColor: AppColors.primaryLighter.withOpacity(0.3),
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  label: Text(
                    '${entry.key}: ${entry.value}/5',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary),
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
