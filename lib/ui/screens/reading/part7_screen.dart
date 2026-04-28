import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'part7_quiz_screen.dart';

class Part7Screen extends StatefulWidget {
  const Part7Screen({super.key});

  @override
  State<Part7Screen> createState() => _Part7ScreenState();
}

class _Part7ScreenState extends State<Part7Screen> {
  int _passageCount = 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Phần 7 - Đọc Hiểu', centerTitle: true),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(12)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
              Text('Hướng dẫn', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
              SizedBox(height: 8),
              Text('Đọc đoạn văn rồi trả lời các câu hỏi. Kéo sang phải hoặc trái để chuyển câu. Khi hoàn thành, bạn sẽ thấy kết quả.'),
            ]),
          ),

          const SizedBox(height: 16),

          Row(children: [
            const Text('Số đoạn muốn làm:', style: TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(width: 12),
            DropdownButton<int>(value: _passageCount, items: [1,2,3,4].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(), onChanged: (v) { if (v!=null) setState(()=>_passageCount=v); }),
          ]),

          const SizedBox(height: 20),

          Expanded(child: Container()),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                // Build demo passages and start quiz
                final passages = List.generate(_passageCount, (p) {
                  return Part7Passage(
                    passageText: 'This is a sample passage ${p + 1}. Read carefully and answer the following questions.',
                    questions: [
                      Part7Question(prompt: 'What is the main topic of the passage?', options: ['Topic A', 'Topic B', 'Topic C', 'Topic D'], correctIndex: 1),
                      Part7Question(prompt: 'Which statement is true?', options: ['Option A', 'Option B', 'Option C', 'Option D'], correctIndex: 2),
                    ],
                  );
                });

                Navigator.of(context).push(MaterialPageRoute(builder: (_) => Part7QuizScreen(passages: passages)));
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
              child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Bắt đầu', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
            ),
          ),
        ]),
      ),
    );
  }
}
