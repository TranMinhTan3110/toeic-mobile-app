import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/test/test_card.dart';

class SeeMoreScreen extends StatelessWidget {
  final String title;

  const SeeMoreScreen({super.key, required this.title});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: title),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: 10, // Giả lập hiển thị 10 bài test
        itemBuilder: (context, index) {
          // Logic nhỏ để test thử giao diện các trạng thái khác nhau
          // Giả sử bài 1 đang làm, bài 2 đã xong, còn lại chưa làm
          TestStatus currentStatus = TestStatus.notStarted;
          int? score;

          if (index == 0) {
            currentStatus = TestStatus.inProgress;
          } else if (index == 1) {
            currentStatus = TestStatus.completed;
            score = 850;
          }

          return TestCard(
            testName: 'Test ${index + 1}',
            duration: '60 phút',
            questionCount: 100,
            status: currentStatus,
            score: score,
            onTap: () {
              print('Bấm vào Test ${index + 1}');
              // TODO: Điều hướng sang TestDetailScreen hoặc màn hình làm bài
            },
          );
        },
      ),
    );
  }
}
