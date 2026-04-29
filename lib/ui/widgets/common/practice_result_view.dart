import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class PracticeResultView extends StatelessWidget {
  final int score;
  final int total;
  final int mistakes;
  final VoidCallback onRetry;
  final VoidCallback onBack;
  final String title;

  const PracticeResultView({
    super.key,
    required this.score,
    required this.total,
    this.mistakes = 0,
    required this.onRetry,
    required this.onBack,
    this.title = 'Hoàn thành buổi học!',
  });

  @override
  Widget build(BuildContext context) {
    // Nếu là quiz thì tính theo score, nếu là matching thì check mistakes
    final bool isExcellent = score == total && mistakes == 0;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isExcellent ? Icons.emoji_events : Icons.check_circle,
              size: 100,
              color: isExcellent ? AppColors.star : AppColors.primary,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (mistakes > 0) ...[
              Text(
                'Bạn đã ghép xong $total từ.',
                style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
              Text(
                'Số lần chọn sai: $mistakes',
                style: const TextStyle(color: AppColors.error, fontWeight: FontWeight.bold),
              ),
            ] else ...[
              Text(
                'Bạn đã trả lời đúng $score/$total câu hỏi.',
                style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
              ),
            ],
            const SizedBox(height: 40),
            
            // Nút Luyện lại
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onRetry,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.success,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.refresh, color: AppColors.textOnPrimary),
                    SizedBox(width: 8),
                    Text('Luyện lại', style: TextStyle(color: AppColors.textOnPrimary, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Nút Quay lại
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: onBack,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.primary),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                ),
                child: const Text('Quay lại danh sách', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
