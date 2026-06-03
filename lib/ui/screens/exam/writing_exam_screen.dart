import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:toeicmobileapp/core/theme/app_colors.dart';
import 'package:toeicmobileapp/core/constants/app_constants.dart';

import '../../../data/models/writing_question.dart';
import '../../../providers/exam_provider.dart';
import 'writing_exam_result_screen.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/cards/email_card.dart';
import '../../widgets/cards/essay_prompt_card.dart';
import '../../shared/practice_dialogs.dart';

class WritingExamScreen extends StatefulWidget {
  final String examId;
  final String examTitle;

  const WritingExamScreen({
    super.key,
    required this.examId,
    required this.examTitle,
  });

  @override
  State<WritingExamScreen> createState() => _WritingExamScreenState();
}

class _WritingExamScreenState extends State<WritingExamScreen> {
  final Dio _dio = Dio();
  final PageController _pageController = PageController();

  List<WritingQuestion> _questions = [];
  List<TextEditingController> _controllers = [];
  int _currentQ = 0;
  bool _isLoading = true;
  String? _error;

  // Timer
  Timer? _timer;
  int _remainingSeconds = 60 * 60; // 60 phút
  double _fontSize = 14.0;
  bool _isFavorite = false;

  @override
  void initState() {
    super.initState();
    _loadQuestions();
    _startTimer();
  }

  Future<void> _loadQuestions() async {
    try {
      final response = await _dio.get(
        '${AppConstants.baseUrl}/writing-questions/exam/${widget.examId}',
      );
      final List<dynamic> data = response.data;
      final fetched = data.map((json) => WritingQuestion.fromJson(json)).toList();

      // Sắp xếp các câu hỏi theo thứ tự taskNumber và taskType để đảm bảo hiển thị đúng Part 1 -> Part 2 -> Part 3
      fetched.sort((a, b) {
        if (a.taskNumber != b.taskNumber) {
          return a.taskNumber.compareTo(b.taskNumber);
        }
        return a.id.compareTo(b.id);
      });

      setState(() {
        _questions = fetched;
        _controllers = List.generate(
          _questions.length,
          (_) => TextEditingController(),
        );
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        if (mounted) {
          setState(() {
            _remainingSeconds--;
          });
        }
      } else {
        _timer?.cancel();
        _submitExam();
      }
    });
  }

  bool _isSubmitting = false;

  Future<void> _submitExam() async {
    if (_isSubmitting) return;
    _timer?.cancel();
    setState(() {
      _isSubmitting = true;
    });

    // Hiển thị loading overlay đè lên màn hình
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PopScope(
        canPop: false,
        child: AlertDialog(
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text(
                'AI đang chấm bài thi Writing của bạn. Quá trình này có thể mất 1-2 phút...',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ),
      ),
    );

    try {
      final List<Map<String, dynamic>> tasksData = [];
      for (int i = 0; i < _questions.length; i++) {
        final q = _questions[i];
        final answerText = _controllers[i].text.trim();
        final wordCount = answerText.isEmpty ? 0 : answerText.split(RegExp(r'\s+')).length;
        tasksData.add({
          'questionId': q.id,
          'taskNumber': q.taskNumber,
          'taskType': q.taskType,
          'userAnswer': answerText,
          'wordCount': wordCount,
        });
      }

      final examProvider = context.read<ExamProvider>();
      final resultHistory = await examProvider.submitWritingExam(
        examSetId: widget.examId,
        examTitle: widget.examTitle,
        timeSpent: (60 * 60) - _remainingSeconds,
        tasks: tasksData,
      );

      // Đóng loading dialog
      if (mounted) Navigator.pop(context);

      // Chuyển sang màn hình kết quả
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WritingExamResultScreen(history: resultHistory),
          ),
        );
      }
    } catch (e) {
      // Đóng loading dialog
      if (mounted) Navigator.pop(context);

      // Hiển thị lỗi
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Lỗi nộp bài'),
            content: Text('Đã xảy ra lỗi khi gửi bài thi lên hệ thống: $e'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Đóng'),
              ),
            ],
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    for (var c in _controllers) {
      c.dispose();
    }
    super.dispose();
  }

  String _formatTimer(int totalSeconds) {
    int h = totalSeconds ~/ 3600;
    int m = (totalSeconds % 3600) ~/ 60;
    int s = totalSeconds % 60;
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  void _nextQuestion() {
    if (_currentQ < _questions.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _submitExam();
    }
  }

  void _prevQuestion() {
    if (_currentQ > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        appBar: CustomAppBar(title: 'Đang tải...'),
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null || _questions.isEmpty) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: const CustomAppBar(title: 'Lỗi'),
        body: Center(child: Text('Không thể tải câu hỏi: ${_error ?? "Đề trống"}')),
      );
    }

    final currentQuestion = _questions[_currentQ];
    final questionNumber = _currentQ + 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildProgressStrip(),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _currentQ = index;
                });
              },
              itemCount: _questions.length,
              itemBuilder: (context, index) {
                return _buildQuestionContent(_questions[index], index);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final title = _questions.isNotEmpty
        ? 'Câu ${_currentQ + 1}/${_questions.length}'
        : widget.examTitle;
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
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.5,
        ),
      ),
      actions: [
        IconButton(
          onPressed: () => showWritingReportDialog(context),
          icon: const Icon(Icons.report_problem_outlined, color: Colors.white, size: 20),
          tooltip: 'Báo lỗi',
        ),
        IconButton(
          onPressed: () => showWritingSettingsDialog(
            context,
            fontSize: _fontSize,
            onFontSizeChanged: (v) => setState(() => _fontSize = v),
          ),
          icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 20),
          tooltip: 'Cài đặt',
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _isFavorite = !_isFavorite;
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(_isFavorite ? 'Đã thêm vào yêu thích' : 'Đã xóa khỏi yêu thích'),
                duration: const Duration(seconds: 1),
              ),
            );
          },
          icon: Icon(
            _isFavorite ? Icons.favorite : Icons.favorite_border,
            color: _isFavorite ? Colors.redAccent : Colors.white,
            size: 20,
          ),
          tooltip: 'Yêu thích',
        ),
        const SizedBox(width: 4),
        // Đồng hồ chạy ngược của toàn đề thi
        Container(
          margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.redAccent.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              const Icon(Icons.timer_outlined, color: Colors.white, size: 16),
              const SizedBox(width: 4),
              Text(
                _formatTimer(_remainingSeconds),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProgressStrip() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              'Part ${_questions[_currentQ].taskNumber}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentQ + 1) / _questions.length,
                backgroundColor: AppColors.primaryLighter,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                minHeight: 5,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${_currentQ + 1}/${_questions.length}',
            style: const TextStyle(
              color: AppColors.primary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionContent(WritingQuestion q, int index) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (q.taskType == 'write_sentence') ...[
          // Part 1: Picture Description
          _buildPictureSection(q),
        ] else if (q.taskType == 'respond_email') ...[
          // Part 2: Respond to Email
          EmailCard(
            from: 'sender@example.com',
            subject: 'Email Request',
            content: q.emailContent ?? 'No email content',
            fontSize: _fontSize,
          ),
        ] else if (q.taskType == 'opinion_essay') ...[
          // Part 3: Opinion Essay
          EssayPromptCard(
            prompt: q.promptText,
            fontSize: _fontSize,
          ),
        ],
        const SizedBox(height: 16),
        _buildResponseInput(q, index),
      ],
    );
  }

  Widget _buildPictureSection(WritingQuestion q) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 220,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            boxShadow: const [
              BoxShadow(
                color: AppColors.shadow,
                blurRadius: 6,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              q.promptImageUrl ?? 'https://via.placeholder.com/600x400?text=No+Image',
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) => const Center(
                child: Icon(Icons.image_not_supported_rounded, size: 48, color: AppColors.textHint),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.primary.withOpacity(0.1)),
          ),
          child: Center(
            child: Text(
              q.givenWords.isNotEmpty ? q.givenWords.join(' / ') : 'Sử dụng các từ cho trước',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildResponseInput(WritingQuestion q, int index) {
    String hintText = 'Mô tả hình ảnh của bạn...';
    if (q.taskType == 'respond_email') {
      hintText = 'Viết câu trả lời thư của bạn...';
    } else if (q.taskType == 'opinion_essay') {
      hintText = 'Viết bài luận bày tỏ ý kiến của bạn...';
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.divider),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: _controllers[index],
        maxLines: 12,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: AppColors.textHint,
            fontSize: _fontSize,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.zero,
        ),
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: _fontSize,
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: _currentQ > 0 ? _prevQuestion : () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  side: const BorderSide(color: AppColors.primary),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text(
                  _currentQ > 0 ? 'Câu trước' : 'Thoát',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: _nextQuestion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textOnPrimary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 4,
                ),
                child: Text(
                  _currentQ >= _questions.length - 1 ? 'Nộp bài' : 'Câu sau',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('🎉 Đã nộp bài!', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Bạn đã hoàn thành phần thi viết TOEIC. Câu trả lời của bạn đã được ghi nhận thành công!'),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context); // Đóng Dialog
              Navigator.pop(context); // Thoát về màn hình chi tiết đề thi
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Trở về', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
