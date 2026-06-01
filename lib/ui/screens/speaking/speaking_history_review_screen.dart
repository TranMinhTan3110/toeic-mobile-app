import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import '../../widgets/speaking/speaking_explanation_panel.dart';
import '../../shared/practice_dialogs.dart';
import '../../../data/models/speaking_question.dart';
import '../../../data/models/speaking_history_model.dart';
import '../../../core/services/tts_service.dart';
import '../../../providers/speaking_provider.dart';

class SpeakingHistoryReviewScreen extends StatefulWidget {
  final int partNumber;
  final List<SpeakingHistoryAnswerModel> answers;
  final int initialIndex;
  
  const SpeakingHistoryReviewScreen({
    super.key, 
    required this.partNumber,
    required this.answers,
    this.initialIndex = 0,
  });

  @override
  State<SpeakingHistoryReviewScreen> createState() => _SpeakingHistoryReviewScreenState();
}

class _SpeakingHistoryReviewScreenState extends State<SpeakingHistoryReviewScreen> {
  late PageController _pageController;
  int _currentIndex = 0;
  bool _showPanel = false;
  double _ttsRate = 0.5;
  double _fontSizeFactor = 1.0;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
    _pageController = PageController(initialPage: widget.initialIndex);
    
    // Tự động trượt bảng giải thích lên sau khi vào màn hình
    Future.delayed(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _showPanel = true);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                child: PageView.builder(
                  controller: _pageController,
                  onPageChanged: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  itemCount: widget.answers.length,
                  itemBuilder: (context, index) {
                    final answer = widget.answers[index];
                    final provider = context.read<SpeakingProvider>();
                    final question = provider.getQuestionById(answer.questionId);
                    
                    final SpeakingQuestion displayTask = question ?? SpeakingQuestion(
                      id: answer.questionId,
                      taskNumber: widget.partNumber,
                      prepSeconds: 45,
                      recordSeconds: 45,
                      text: 'Đang tải dữ liệu câu hỏi...',
                      imageUrl: null,
                      questions: widget.partNumber >= 3 ? ['...'] : [],
                    );

                    return _buildPageContent(displayTask, answer);
                  },
                ),
              ),
            ],
          ),

          // Panel giải thích tự động trượt lên
          Consumer<SpeakingProvider>(
            builder: (context, provider, _) {
              final currentAnswer = widget.answers[_currentIndex];
              final currentQuestion = provider.getQuestionById(currentAnswer.questionId);
              
              return Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SpeakingExplanationPanel(
                  isVisible: _showPanel,
                  question: currentQuestion,
                  partNumber: widget.partNumber,
                  onClose: () => setState(() => _showPanel = false),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPageContent(SpeakingQuestion displayTask, SpeakingHistoryAnswerModel answer) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Đề bài & Hình ảnh
          _buildPromptAndImage(displayTask),
          
          const SizedBox(height: 20),
          
          // 2. Card câu hỏi (nếu có - Part 3, 4)
          if (displayTask.questions.isNotEmpty)
            _buildCurrentQuestionCard(displayTask),

          const SizedBox(height: 24),
          
          // 3. Hiển thị câu trả lời của bạn
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
            child: Text(
              answer.transcript.isEmpty 
                ? '(Chưa có câu trả lời)' 
                : answer.transcript, 
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 19 * _fontSizeFactor,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),

          if (answer.feedback.isNotEmpty) ...[
            const SizedBox(height: 24),
            const Text(
              'Phản hồi từ giám khảo AI:',
              style: TextStyle(
                fontWeight: FontWeight.bold, 
                color: AppColors.primary, 
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange.withOpacity(0.2)),
              ),
              child: Text(
                answer.feedback,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14 * _fontSizeFactor,
                  height: 1.6,
                ),
              ),
            ),
          ],
          
          const SizedBox(height: 350), // Khoảng trống cho panel trượt lên
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
        'Câu ${_currentIndex + 1}/${widget.answers.length}',
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
      ),
      actions: [
        IconButton(
          onPressed: () => showReportDialog(context),
          icon: const Icon(Icons.report_problem_outlined, color: Colors.white, size: 20),
          tooltip: 'Báo lỗi',
        ),
        IconButton(
          onPressed: _showSettingsDialog,
          icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
          tooltip: 'Cài đặt',
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(Icons.favorite_border, color: Colors.white, size: 20),
          tooltip: 'Yêu thích',
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

  void _showSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => _SpeakingHistorySettingsDialog(
        currentTtsRate: _ttsRate,
        currentFontSizeFactor: _fontSizeFactor,
        onSave: (rate, size) {
          setState(() {
            _ttsRate = rate;
            _fontSizeFactor = size;
          });
          TtsService().setRate(rate);
        },
      ),
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
                      Text(promptText, style: TextStyle(fontSize: 14 * _fontSizeFactor, height: 1.5, fontStyle: FontStyle.italic)),
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
          Text(task.questions.isNotEmpty ? task.questions.first : '...',
            textAlign: TextAlign.center, 
            style: TextStyle(fontSize: 17 * _fontSizeFactor, fontWeight: FontWeight.w800, color: AppColors.textPrimary)
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

class _SpeakingHistorySettingsDialog extends StatefulWidget {
  final double currentTtsRate;
  final double currentFontSizeFactor;
  final Function(double, double) onSave;

  const _SpeakingHistorySettingsDialog({
    required this.currentTtsRate,
    required this.currentFontSizeFactor,
    required this.onSave,
  });

  @override
  State<_SpeakingHistorySettingsDialog> createState() => _SpeakingHistorySettingsDialogState();
}

class _SpeakingHistorySettingsDialogState extends State<_SpeakingHistorySettingsDialog> {
  late double _ttsRate;
  late double _fontSizeFactor;

  @override
  void initState() {
    super.initState();
    _ttsRate = widget.currentTtsRate;
    _fontSizeFactor = widget.currentFontSizeFactor;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      elevation: 8,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(28),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with icon and close button
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.settings, color: Colors.orange, size: 24),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Cài đặt',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // TTS Speed Section
              const Text(
                'Tốc độ phát âm thanh',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildSpeedButton(0.5, '0.5x'),
                    const SizedBox(width: 10),
                    _buildSpeedButton(0.75, '0.75x'),
                    const SizedBox(width: 10),
                    _buildSpeedButton(1.0, '1x'),
                    const SizedBox(width: 10),
                    _buildSpeedButton(1.25, '1.25x'),
                    const SizedBox(width: 10),
                    _buildSpeedButton(1.5, '1.5x'),
                  ],
                ),
              ),
              const SizedBox(height: 28),

              // Font Size Section
              const Text(
                'Kích thước chữ',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black87),
              ),
              const SizedBox(height: 14),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFontSizeButton(0.8, 'Nhỏ'),
                    const SizedBox(width: 10),
                    _buildFontSizeButton(1.0, 'Vừa'),
                    const SizedBox(width: 10),
                    _buildFontSizeButton(1.2, 'Lớn'),
                    const SizedBox(width: 10),
                    _buildFontSizeButton(1.5, 'Rất lớn'),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    widget.onSave(_ttsRate, _fontSizeFactor);
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 4,
                  ),
                  child: const Text(
                    'Lưu cài đặt',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
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

  Widget _buildSpeedButton(double value, String label) {
    final isSelected = (_ttsRate - value).abs() < 0.01;
    return GestureDetector(
      onTap: () => setState(() => _ttsRate = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
              : [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _buildFontSizeButton(double value, String label) {
    final isSelected = (_fontSizeFactor - value).abs() < 0.01;
    return GestureDetector(
      onTap: () => setState(() => _fontSizeFactor = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.orange : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? Colors.orange : Colors.grey.shade300,
            width: 2,
          ),
          boxShadow: isSelected
              ? [BoxShadow(color: Colors.orange.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 2))]
              : [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 4)],
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: isSelected ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }
}
