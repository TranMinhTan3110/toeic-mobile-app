import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../widgets/practice/practice_stats_card.dart';
import '../../../widgets/practice/instruction_card.dart';
import '../../../widgets/practice/practice_setting_row.dart';
import '../../../../data/models/writing_question_model.dart';
import '../../../../data/repositories/writing_question_repository.dart';
import '../../../../data/services/writing_question_service.dart';
import 'essay_writing_test_screen.dart';

class EssayWritingScreen extends StatefulWidget {
  const EssayWritingScreen({super.key});

  @override
  State<EssayWritingScreen> createState() => _EssayWritingScreenState();
}

class _EssayWritingScreenState extends State<EssayWritingScreen> {
  final WritingQuestionRepository _repository =
      WritingQuestionRepository(WritingQuestionService(Dio()));
  late final Future<List<WritingQuestion>> _questionsFuture;

  int _selectedQuestionCount = 1;
  bool _isCheckMode = false;
  final List<int> _questionOptions = [1, 2, 3, 5];

  @override
  void initState() {
    super.initState();
    _questionsFuture = _repository.getByTaskType('opinion_essay');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Viết luận'),
      body: FutureBuilder<List<WritingQuestion>>(
        future: _questionsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Lỗi tải câu hỏi: ${snapshot.error}'),
            );
          }
          final questions = snapshot.data ?? [];
          final canStart = questions.isNotEmpty;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                const PracticeStatsCard(
                  totalDone: 0,
                  correct: 0,
                  progress: 0.0,
                  icon: Icons.article_rounded,
                ),
                const SizedBox(height: 24),
                const InstructionCard(
                  title: 'Câu hỏi',
                  english: [
                    'Write an essay responding to a specific opinion or issue. Use reasons and examples to support your answer.',
                  ],
                  vietnamese: [
                    'Viết một bài luận phản hồi lại một quan điểm hoặc vấn đề. Sử dụng các lý do và ví dụ cụ thể để củng cố câu trả lời của bạn.',
                  ],
                ),
                const SizedBox(height: 24),
                PracticeSettingsRow(
                  value: _selectedQuestionCount,
                  options: _questionOptions,
                  isCheckMode: _isCheckMode,
                  onChanged: (val) => setState(() => _selectedQuestionCount = val),
                  onToggleCheck: (val) => setState(() => _isCheckMode = val),
                ),
                const SizedBox(height: 32),
                if (!canStart)
                  const Text(
                    'Không có câu hỏi nào cho phần viết luận. Vui lòng thử lại sau.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: AppColors.textHint),
                  ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: FutureBuilder<List<WritingQuestion>>(
            future: _questionsFuture,
            builder: (context, snapshot) {
              final questions = snapshot.data ?? [];
              final canStart = questions.isNotEmpty;
              return ElevatedButton(
                onPressed: canStart
                    ? () {
                        final selectedQuestions = questions
                            .take(_selectedQuestionCount)
                            .toList();
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => EssayWritingTestScreen(
                              questions: selectedQuestions,
                            ),
                          ),
                        );
                      }
                    : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: const Text(
                  'Bắt đầu nào',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
