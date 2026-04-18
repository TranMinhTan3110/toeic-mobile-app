import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/practice/practice_stats_card.dart';
import '../../widgets/practice/instruction_card.dart';
import '../../widgets/practice/practice_setting_row.dart';

class RespondRequestScreen extends StatefulWidget {
  const RespondRequestScreen({super.key});

  @override
  State<RespondRequestScreen> createState() => _RespondRequestScreenState();
}

class _RespondRequestScreenState extends State<RespondRequestScreen> {
  int _selectedQuestionCount = 5;
  bool _isCheckMode = false;

  final List<int> _questionOptions = [2, 5, 10];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Phản hồi yêu cầu'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const PracticeStatsCard(
              totalDone: 0,
              correct: 0,
              progress: 0.0,
              icon: Icons.mark_email_read_rounded,
            ),

            const SizedBox(height: 24),

            const InstructionCard(
              title: 'Câu hỏi',
              english: [
                'Read the email and write a response. Your response should address the tasks given.',
              ],
              vietnamese: [
                'Đọc email và viết thư phản hồi. Câu trả lời của bạn cần giải quyết các yêu cầu được đưa ra.',
              ],
            ),

            const SizedBox(height: 16),

            Center(
              child: TextButton(
                onPressed: () {},
                child: const Text(
                  'Nâng cấp để tải toàn bộ bài tập về máy,\ntải dữ liệu nhanh hơn, ổn định hơn',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
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
              print('Bắt đầu Phần 2');
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
