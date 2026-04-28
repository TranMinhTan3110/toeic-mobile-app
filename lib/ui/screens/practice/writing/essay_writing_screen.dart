import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/common/custom_app_bar.dart';
import '../../../widgets/practice/practice_stats_card.dart';
import '../../../widgets/practice/instruction_card.dart';
import '../../../widgets/practice/practice_setting_row.dart';
import 'essay_writing_test_screen.dart';

class EssayWritingScreen extends StatefulWidget {
  const EssayWritingScreen({super.key});

  @override
  State<EssayWritingScreen> createState() => _EssayWritingScreenState();
}

class _EssayWritingScreenState extends State<EssayWritingScreen> {
  int _selectedQuestionCount = 2;
  bool _isCheckMode = false;

  final List<int> _questionOptions = [1, 2, 3, 5];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Viết luận'),
      body: SingleChildScrollView(
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
          ],
        ),
      ),

      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EssayWritingTestScreen(),
                ),
              );
            },
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
          ),
        ),
      ),
    );
  }
}
