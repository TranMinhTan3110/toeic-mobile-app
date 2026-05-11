import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../widgets/practice/practice_stats_card.dart';
import '../../../widgets/practice/practice_setting_row.dart';
import '../../../widgets/practice/instruction_card.dart';
import '../../../../data/models/writing_question_model.dart';
import '../../../../data/repositories/writing_question_repository.dart';
import '../../../../data/services/writing_question_service.dart';
import 'picture_description_test_screen.dart';

class PictureDescriptionScreen extends StatefulWidget {
  const PictureDescriptionScreen({super.key});

  @override
  State<PictureDescriptionScreen> createState() =>
      _PictureDescriptionScreenState();
}

class _PictureDescriptionScreenState extends State<PictureDescriptionScreen> {
  final WritingQuestionRepository _repository =
      WritingQuestionRepository(WritingQuestionService(Dio()));
  late final Future<List<WritingQuestion>> _questionsFuture;

  int _selectedQuestionCount = 15;
  bool _isCheckMode = false;

  final List<int> _questionOptions = [5, 10, 15, 20, 25];

  @override
  void initState() {
    super.initState();
    _questionsFuture = _repository.getByTaskType('write_sentence');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Mô tả tranh'),
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
                  icon: Icons.photo_album_rounded,
                ),
                const SizedBox(height: 24),
                const InstructionCard(
                  title: 'Câu hỏi',
                  english: [
                    'With each picture, you\'ll be given two words or phrases that you need to use in a sentence.',
                    'You can change the forms of the words and use the words in any order.',
                  ],
                  vietnamese: [
                    'Với mỗi bức tranh, bạn sẽ được cung cấp hai từ hoặc cụm từ mà bạn cần sử dụng để viết một câu.',
                    'Bạn có thể thay đổi dạng của từ và sử dụng các từ này theo bất kỳ thứ tự nào.',
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
                    'Không có câu hỏi nào cho phần mô tả tranh. Vui lòng thử lại sau.',
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
                            builder: (_) => PictureDescriptionTestScreen(
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
