import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';

// 1. IMPORT 3 MÀN HÌNH CỦA 3 PHẦN THI VÀO ĐÂY
// (Đảm bảo các file này nằm cùng thư mục với writing_screen.dart, nếu khác thì bạn sửa lại đường dẫn nhé)
import 'picture_description_screen.dart';
import 'respond_request_screen.dart';
import 'essay_writing_screen.dart';

class WritingScreen extends StatelessWidget {
  const WritingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Viết'),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Header: Tổng quan tiến độ
              _buildOverallProgress(),
              const SizedBox(height: 24),

              // 2. Danh sách các phần thi (Đã thêm sự kiện onTap)
              _buildPartCard(
                title: 'Phần 1 - Mô tả tranh',
                doneCount: 8,
                progress: 0.53,
                isLocked: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PictureDescriptionScreen(),
                    ),
                  );
                },
              ),
              _buildPartCard(
                title: 'Phần 2 - Phản hồi yêu cầu',
                doneCount: 4,
                progress: 0.8,
                isLocked: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RespondRequestScreen(),
                    ),
                  );
                },
              ),
              _buildPartCard(
                title: 'Phần 3 - Viết luận',
                doneCount: 0,
                progress: 0.0,
                isLocked: false,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const EssayWritingScreen(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // 3. Đường phân cách (Lằn ranh)
              const Row(
                children: [
                  Expanded(
                    child: Divider(color: AppColors.divider, thickness: 1.5),
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      Icons.history_rounded,
                      color: AppColors.textHint,
                      size: 20,
                    ),
                  ),
                  Expanded(
                    child: Divider(color: AppColors.divider, thickness: 1.5),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // 4. Phần Lịch sử luyện tập
              const Text(
                'Lịch sử luyện tập',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              _buildHistoryItem(
                date: '16/04/2026',
                part: 'Phần 1 - Mô tả tranh',
                score: '8/15 câu',
              ),
              _buildHistoryItem(
                date: '15/04/2026',
                part: 'Phần 2 - Phản hồi yêu cầu',
                score: '4/5 câu',
              ),
              _buildHistoryItem(
                date: '14/04/2026',
                part: 'Phần 3 - Viết luận',
                score: '0/2 câu',
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  // ---- WIDGETS CON ----

  Widget _buildOverallProgress() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 15,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.primaryLighter,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.draw_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Số câu đã làm',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  '12',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildProgressBar(0.55),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// 2. BỔ SUNG BIẾN onTap VÀ BỌC BẰNG GestureDetector
  Widget _buildPartCard({
    required String title,
    required int doneCount,
    required double progress,
    required bool isLocked,
    VoidCallback? onTap, // Thêm hàm callback xử lý sự kiện click
  }) {
    return GestureDetector(
      onTap: isLocked ? null : onTap, // Chỉ cho phép ấn nếu không bị khóa
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.divider, width: 1),
          boxShadow: const [
            BoxShadow(
              color: AppColors.shadow,
              blurRadius: 8,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isLocked
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                ),
                if (isLocked)
                  const Icon(
                    Icons.lock_rounded,
                    color: AppColors.primary,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Số câu đã làm:',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  '$doneCount',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildProgressBar(progress),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Row(
      children: [
        const Text(
          'Hoàn thành',
          style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: AppColors.primaryLighter,
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.primary,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHistoryItem({
    required String date,
    required String part,
    required String score,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider.withOpacity(0.5)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.calendar_today_rounded,
              size: 16,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  part,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: const TextStyle(
                    color: AppColors.textHint,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Text(
            score,
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
