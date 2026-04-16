import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';

class EssayWritingScreen extends StatefulWidget {
  const EssayWritingScreen({super.key});

  @override
  State<EssayWritingScreen> createState() => _EssayWritingScreenState();
}

class _EssayWritingScreenState extends State<EssayWritingScreen> {
  int _selectedQuestionCount = 2; // Viết luận thường rất dài nên làm ít câu
  bool _isCheckMode = false;
  final List<int> _questionOptions = [1, 2, 3, 5];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(title: 'Viết luận'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatsCard(),
            const SizedBox(height: 24),
            _buildInstructionCard(),
            const SizedBox(height: 16),
            const SizedBox(height: 24),
            _buildSettingsRow(),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: () {
              print('Bắt đầu Phần 3');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 4,
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryLighter,
              borderRadius: BorderRadius.circular(16),
            ),
            // Icon bài văn/tài liệu cho phần Viết luận
            child: const Icon(
              Icons.article_rounded,
              size: 40,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatRow('Số câu đã làm', '0'),
                const SizedBox(height: 8),
                _buildStatRow('Trả lời đúng', '0'),
                const SizedBox(height: 12),
                _buildProgressBar(0.0),
              ],
            ),
          ),
        ],
      ),
    );
  }

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
            '- Write an essay responding to a specific opinion or issue. Use reasons and examples to support your answer.',
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Divider(color: AppColors.divider),
          ),
          _buildInstructionText(
            '- Viết một bài luận phản hồi lại một quan điểm hoặc vấn đề. Sử dụng các lý do và ví dụ cụ thể để củng cố câu trả lời của bạn.',
            isVietnamese: true,
          ),
        ],
      ),
    );
  }

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

  Widget _buildSettingsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Text(
              'Số câu hỏi:',
              style: TextStyle(fontSize: 16, color: AppColors.textPrimary),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  items: _questionOptions
                      .map(
                        (int value) => DropdownMenuItem<int>(
                          value: value,
                          child: Text(
                            value.toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (int? newValue) {
                    if (newValue != null)
                      setState(() => _selectedQuestionCount = newValue);
                  },
                ),
              ),
            ),
          ],
        ),
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
              onChanged: (bool value) => setState(() => _isCheckMode = value),
            ),
          ],
        ),
      ],
    );
  }
}
