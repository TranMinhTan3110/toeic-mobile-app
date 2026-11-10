import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'reading_quiz_screen.dart';
import 'reading_answers_screen.dart';

class ReadingResultScreen extends StatelessWidget {
  final int correct;
  final int total;
  final List<QuizQuestion> questions;
  final List<int?> selectedIndices;

  const ReadingResultScreen({
    super.key,
    required this.correct,
    required this.total,
    required this.questions,
    required this.selectedIndices,
  });

  @override
  Widget build(BuildContext context) {
    final percent = total == 0 ? 0 : ((correct / total) * 100).round();
    return Scaffold(
      appBar: const CustomAppBar(title: 'Kết quả', centerTitle: true),
      backgroundColor: AppColors.background,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(radius: 28, backgroundColor: AppColors.primaryPale, child: const Icon(Icons.tag_faces, size: 28, color: AppColors.primary)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Bạn đã hoàn thành bài luyện tập', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16)),
                          const SizedBox(height: 6),
                          Text('Điền Vào Câu (Đọc Hiểu)', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w800, fontSize: 18)),
                          const SizedBox(height: 6),
                          const Text('Chúc mừng', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Row(
                  children: [
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Kết quả: $correct/$total', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 8),
                      const Text('Tỷ lệ trung bình của bạn:', style: TextStyle(fontSize: 14)),
                    ])),
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
                      child: Center(child: Text('$percent%', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),
              // Chart placeholder
              Container(
                height: 200,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Stack(
                    children: [
                      Positioned.fill(child: Container(color: AppColors.greenBg.withOpacity(0.12))),
                      Positioned(top: 8, right: 8, child: CircleAvatar(radius: 10, backgroundColor: AppColors.primary)),
                      Positioned(left: 8, bottom: 8, child: Text('Tỉ lệ/STT')),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Danh sách câu hỏi sai:', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.primary)),
                    const SizedBox(height: 12),
                    // Always show "Xem tất cả câu trả lời" centered
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (_) => ReadingAnswersScreen(questions: questions, selectedIndices: selectedIndices),
                          ));
                        },
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
                        child: const Padding(padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8), child: Text('Xem tất cả câu trả lời', style: TextStyle(color: Colors.white))),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),
              // Bottom wave + continue button mimic
              const SizedBox(height: 12),
              SizedBox(
                height: 72,
                child: Center(
                  child: SizedBox(
                    width: 280,
                    child: ElevatedButton(
                      onPressed: () => Navigator.maybePop(context),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                      child: const Padding(padding: EdgeInsets.symmetric(vertical: 12), child: Text('Tiếp tục', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white))),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
