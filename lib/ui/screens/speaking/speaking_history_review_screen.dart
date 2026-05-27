import 'package:flutter/material.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import '../../widgets/speaking/speaking_explanation_panel.dart';
import '../../../data/models/speaking_question.dart';
import '../../../core/services/tts_service.dart';

class SpeakingHistoryReviewScreen extends StatefulWidget {
  final String title;
  final SpeakingQuestion? question;
  final int partNumber;
  
  const SpeakingHistoryReviewScreen({
    super.key, 
    required this.title,
    this.question,
    required this.partNumber,
  });

  @override
  State<SpeakingHistoryReviewScreen> createState() => _SpeakingHistoryReviewScreenState();
}

class _SpeakingHistoryReviewScreenState extends State<SpeakingHistoryReviewScreen> {
  bool _showPanel = false;

  @override
  void initState() {
    super.initState();
    // Tự động trượt bảng giải thích lên sau khi vào màn hình
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showPanel = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Dữ liệu mẫu khớp với cấu trúc UI luyện tập
    final SpeakingQuestion reviewTask = widget.question ?? SpeakingQuestion(
      id: 'review_1',
      taskNumber: widget.partNumber,
      prepSeconds: 45,
      recordSeconds: 45,
      text: 'Madison Cinema, Bristol\'s favorite movie theater...',
      imageUrl: widget.partNumber == 2 ? 'https://example.com/image.jpg' : null,
      questions: widget.partNumber >= 3 ? ['What is your favorite book?'] : [],
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          Column(
            children: [
              // Thanh tiến trình giả lập (full 100%)
              LinearProgressIndicator(
                value: 1.0,
                minHeight: 4,
                backgroundColor: AppColors.primaryLighter,
                valueColor: const AlwaysStoppedAnimation(AppColors.primary),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Đề bài & Hình ảnh (Sử dụng lại style SpeakingDoingScreen)
                      _buildPromptAndImage(reviewTask),
                      
                      const SizedBox(height: 20),
                      
                      // 2. Card câu hỏi (nếu có - Part 3, 4)
                      if (reviewTask.questions.isNotEmpty)
                        _buildCurrentQuestionCard(reviewTask),

                      const SizedBox(height: 24),
                      
                      // 3. Hiển thị câu trả lời của bạn (Thay thế vùng ghi âm)
                      const Text(
                        'Câu trả lời của bạn:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold, 
                          color: AppColors.primary, 
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 30),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
                          border: Border.all(color: AppColors.primary.withOpacity(0.1)),
                        ),
                        alignment: Alignment.center,
                        child: const Text(
                          'The personnel managers have decided to make staff changes in the finance department...', 
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 350), // Khoảng trống cho panel trượt lên
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Panel giải thích tự động trượt lên (Y hệt luyện tập)
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SpeakingExplanationPanel(
              isVisible: _showPanel,
              question: reviewTask,
              partNumber: widget.partNumber,
              onClose: () => setState(() => _showPanel = false),
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      titleSpacing: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new, size: 18),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      actions: [
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.report_problem_outlined, color: Colors.white, size: 20),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite_border, color: Colors.white, size: 20),
        ),
        TextButton(
          onPressed: () => setState(() => _showPanel = !_showPanel),
          style: TextButton.styleFrom(padding: const EdgeInsets.only(right: 12)),
          child: const Text('Giải thích',
              style: TextStyle(
                color: Colors.white, 
                fontSize: 14, 
                fontWeight: FontWeight.w500,
              )),
        ),
      ],
    );
  }

  Widget _buildPromptAndImage(SpeakingQuestion task) {
    final String promptText = task.text.trim();
    final bool hasImage = task.imageUrl != null && task.imageUrl!.isNotEmpty;
    final bool isPart1 = widget.partNumber == 1;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(_getPromptLabel(widget.partNumber), 
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    if (promptText.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(promptText, style: const TextStyle(fontSize: 14, height: 1.5, fontStyle: FontStyle.italic)),
                    ],
                  ],
                ),
              ),
              if (isPart1 && promptText.isNotEmpty)
                Positioned(
                  top: 4,
                  right: 4,
                  child: IconButton(
                    icon: const Icon(Icons.volume_up_rounded, color: AppColors.primary, size: 22),
                    onPressed: () => TtsService().speak(promptText),
                  ),
                ),
            ],
          ),
          if (hasImage)
            ClipRRect(
              borderRadius: const BorderRadius.vertical(bottom: Radius.circular(12)),
              child: Image.network(
                task.imageUrl!, 
                fit: BoxFit.cover, 
                width: double.infinity, 
                height: 220,
                errorBuilder: (_, __, ___) => Container(height: 220, color: Colors.grey.shade200, child: const Icon(Icons.image)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCurrentQuestionCard(SpeakingQuestion task) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        border: Border.all(color: Colors.orange.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          const Text('Câu hỏi:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
          const SizedBox(height: 12),
          Text(task.questions.first, 
            textAlign: TextAlign.center, 
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppColors.textPrimary)
          ),
        ],
      ),
    );
  }

  String _getPromptLabel(int partNumber) {
    switch (partNumber) {
      case 1: return 'Đọc văn bản';
      case 2: return 'Mô tả tranh';
      case 3: return 'Trả lời câu hỏi';
      case 4: return 'Trả lời câu hỏi';
      case 5: return 'Bày tỏ quan điểm';
      default: return 'Ngữ cảnh';
    }
  }
}
