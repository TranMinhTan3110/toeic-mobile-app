import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'picture_description_test_screen.dart';

class PictureDescriptionScreen extends StatefulWidget {
  const PictureDescriptionScreen({super.key});

  @override
  State<PictureDescriptionScreen> createState() =>
      _PictureDescriptionScreenState();
}

class _PictureDescriptionScreenState extends State<PictureDescriptionScreen> {
  // Trạng thái cho Dropdown và Switch
  int _selectedQuestionCount = 15;
  bool _isCheckMode = false;

  final List<int> _questionOptions = [5, 10, 15, 20, 25];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Mô tả tranh'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Thẻ thông tin tiến độ
            _buildStatsCard(),
            const SizedBox(height: 24),

            // 2. Thẻ hướng dẫn (Câu hỏi)
            _buildInstructionCard(),
            const SizedBox(height: 16),

            // 3. Nâng cấp Banner (Optional - Làm dạng Text cho gọn gàng)
            const SizedBox(height: 24),

            // 4. Hàng cấu hình (Số câu hỏi & Switch Kiểm tra)
            _buildSettingsRow(),

            const SizedBox(height: 32), // Khoảng trống tránh bị dính đáy
          ],
        ),
      ),
      // Neo nút Bắt đầu ở dưới cùng
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              // TODO: Điều hướng vào màn hình làm bài thực tế
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PictureDescriptionTestScreen(),
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
              elevation: 4,
              shadowColor: AppColors.primary.withOpacity(0.4),
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

  // ---- WIDGETS CON ----

  /// Thẻ hiển thị trạng thái (Số câu đã làm, đúng, tiến độ)
  Widget _buildStatsCard() {
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
          // Icon minh họa
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.photo_album_rounded, // Icon phù hợp với "Mô tả tranh"
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 20),

          // Chi tiết số liệu
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow('Số câu đã làm', '0'),
                const SizedBox(height: 8),
                _buildStatRow('Trả lời đúng', '0'),
                const SizedBox(height: 12),
                _buildProgressBar(0.0), // Mặc định 0%
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Dòng hiển thị text và số liệu trong Thẻ trạng thái
  Widget _buildStatRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// Thanh tiến độ
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

  /// Thẻ Hướng dẫn (Câu hỏi)
  Widget _buildInstructionCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.divider, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Câu hỏi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              decoration: TextDecoration.underline,
              decorationColor: AppColors.primary,
              decorationThickness: 2,
            ),
          ),
          const SizedBox(height: 16),
          _buildInstructionText(
            '- With each picture, you\'ll be given two words or phrases that you need to use in a sentence.',
          ),
          const SizedBox(height: 8),
          _buildInstructionText(
            '- You can change the forms of the words and use the words in any order.',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.divider),
          ),
          _buildInstructionText(
            '- Với mỗi bức tranh, bạn sẽ được cung cấp hai từ hoặc cụm từ mà bạn cần sử dụng để viết một câu.',
            isVietnamese: true,
          ),
          const SizedBox(height: 8),
          _buildInstructionText(
            '- Bạn có thể thay đổi dạng của từ và sử dụng các từ này theo bất kỳ thứ tự nào.',
            isVietnamese: true,
          ),
        ],
      ),
    );
  }

  /// Dòng text hướng dẫn
  Widget _buildInstructionText(String text, {bool isVietnamese = false}) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14,
        color: isVietnamese ? AppColors.textSecondary : AppColors.textPrimary,
        fontStyle: isVietnamese ? FontStyle.italic : FontStyle.normal,
        height: 1.5,
      ),
    );
  }

  /// Hàng thiết lập Số câu hỏi và Switch
  Widget _buildSettingsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Dropdown Số câu hỏi
        Row(
          children: [
            const Text(
              'Số câu hỏi:',
              style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              decoration: BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: AppColors.divider),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<int>(
                  value: _selectedQuestionCount,
                  icon: const Icon(
                    Icons.keyboard_arrow_down_rounded,
                    color: AppColors.primary,
                  ),
                  items: _questionOptions.map((int value) {
                    return DropdownMenuItem<int>(
                      value: value,
                      child: Text(
                        value.toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    );
                  }).toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null) {
                      setState(() {
                        _selectedQuestionCount = newValue;
                      });
                    }
                  },
                ),
              ),
            ),
          ],
        ),

        // Switch Kiểm tra
        Row(
          children: [
            const Text(
              'Kiểm tra:',
              style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 8),
            Switch(
              value: _isCheckMode,
              activeColor: AppColors.primary,
              activeTrackColor: AppColors.primaryLighter,
              inactiveThumbColor: Colors.grey.shade400,
              inactiveTrackColor: Colors.grey.shade200,
              onChanged: (bool value) {
                setState(() {
                  _isCheckMode = value;
                });
              },
            ),
          ],
        ),
      ],
    );
  }
}
