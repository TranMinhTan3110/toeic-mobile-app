import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'picture_description_test_screen.dart';
import '../../widgets/practice/practice_stats_card.dart';
import '../../widgets/practice/practice_setting_row.dart';
import '../../widgets/practice/instruction_card.dart';

class PictureDescriptionScreen extends StatefulWidget {
  const PictureDescriptionScreen({super.key});

  @override
  State<PictureDescriptionScreen> createState() =>
      _PictureDescriptionScreenState();
}

class _PictureDescriptionScreenState extends State<PictureDescriptionScreen> {
  int _selectedQuestionCount = 15;
  bool _isCheckMode = false;

  final List<int> _questionOptions = [5, 10, 15, 20, 25];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Mô tả tranh'),
      body: SingleChildScrollView(
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
                  builder: (_) => const PictureDescriptionTestScreen(),
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
