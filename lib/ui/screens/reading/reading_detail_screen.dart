import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'reading_quiz_screen.dart';

class ReadingDetailScreen extends StatelessWidget {
  final String title;
  final String contentEnglish;
  final String contentVietnamese;

  const ReadingDetailScreen({
    super.key,
    required this.title,
    required this.contentEnglish,
    required this.contentVietnamese,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Điền Vào Câu', centerTitle: true),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 18, 16, 0),
              child: Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: AppColors.greenBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text('Aa', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text('Số câu đã làm', style: TextStyle(fontWeight: FontWeight.w600)),
                        SizedBox(height: 6),
                        Text('0', style: TextStyle(fontWeight: FontWeight.w800)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),

            // Question card with scrollable content inside card
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.border),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Câu hỏi', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textDark)),
                        const SizedBox(height: 10),
                        Text(contentEnglish, style: const TextStyle(height: 1.4)),
                        const SizedBox(height: 12),
                        Text(contentVietnamese, style: TextStyle(color: AppColors.textMuted.withOpacity(0.9))),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text('Nâng cấp để tải toàn bộ bài tập về máy, tải dữ liệu nhanh hơn, ổn định hơn', style: TextStyle(color: AppColors.textMuted), textAlign: TextAlign.center,),
            ),
            const SizedBox(height: 12),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.only(bottom: 8, left: 0, right: 0),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          color: Colors.transparent,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        const Text('Số câu hỏi:'),
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: DropdownButton<int>(
                            value: 5,
                            items: [5,10,20].map((v) => DropdownMenuItem(value: v, child: Text('$v'))).toList(),
                            onChanged: (_) {},
                            underline: const SizedBox.shrink(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text('Kiểm tra:'),
                        const SizedBox(width: 8),
                        Switch(value: false, onChanged: (_) {}),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // navigate to quiz with sample data
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => ReadingQuizScreen(
                        questions: [
                          QuizQuestion(
                            prompt: 'You have two ____ to choose from, you can either leave tonight or wait for the evening flight tomorrow',
                            options: ['suggestions', 'options', 'proposals', 'departures'],
                            correctIndex: 1,
                          ),
                          QuizQuestion(
                            prompt: 'She has decided to ____ her studies next year',
                            options: ['continue', 'finish', 'stop', 'postpone'],
                            correctIndex: 0,
                          ),
                        ],
                      ),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
                  ),
                  child: const Text('Bắt đầu nào', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
