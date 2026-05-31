import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/test_info.dart';
import '../../widgets/buttons/start_exam_button.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'exam_taking_screen.dart';
import 'speaking_exam_screen.dart';
import 'writing_exam_screen.dart';

class TestDetailScreen extends StatelessWidget {
  final TestInfo testData;

  const TestDetailScreen({super.key, required this.testData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Chi tiết bài thi',
        // showBackButton mặc định là true trong CustomAppBar rồi nên không cần khai báo lại
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Tiêu đề bài thi
            Text(
              testData.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary, // Màu chữ chuẩn
              ),
            ),

            const SizedBox(height: 32),

            // Box thông tin (Thời gian & Số câu)
            Container(
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
              decoration: BoxDecoration(
                color: AppColors.surface, // Nền trắng
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: AppColors.shadow, // Bóng đổ màu cam nhẹ
                    blurRadius: 15,
                    offset: Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildInfoItem(
                    icon: Icons.timer_outlined,
                    label: 'Thời gian',
                    value: '${testData.duration} phút',
                  ),

                  // Dòng kẻ dọc chia tách 2 cột
                  Container(width: 1, height: 50, color: AppColors.divider),

                  _buildInfoItem(
                    icon: Icons.assignment_outlined,
                    label: 'Câu hỏi',
                    value: '${testData.questionCount} câu',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),

            // Icon / Hình minh họa ở giữa màn hình
            Expanded(
              child: Center(
                child: Container(
                  padding: const EdgeInsets.all(40),
                  decoration: const BoxDecoration(
                    color:
                        AppColors.surfaceVariant, // Nền cam nhạt đằng sau icon
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons
                        .menu_book_rounded, // Đổi sang icon sách thay cho martial_arts
                    size: 100,
                    color: AppColors.primary, // Đổi màu xanh thành cam chủ đạo
                  ),
                ),
              ),
            ),

            // Nút bắt đầu
            StartExamButton(
              onPressed: () {
                Widget destinationScreen;
                if (testData.skill == 'speaking') {
                  destinationScreen = SpeakingExamScreen(
                    examId: testData.id,
                    examTitle: testData.title,
                  );
                } else if (testData.skill == 'writing') {
                  destinationScreen = WritingExamScreen(
                    examId: testData.id,
                    examTitle: testData.title,
                  );
                } else {
                  destinationScreen = ExamTakingScreen(
                    examId: testData.id,
                    examTitle: testData.title,
                  );
                }

                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => destinationScreen,
                  ),
                );
              },
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  // Widget phụ để tái sử dụng cho cột Thời gian và Số câu hỏi
  Widget _buildInfoItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: AppColors.primary, size: 32),
        const SizedBox(height: 12),
        Text(
          label,
          style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}
