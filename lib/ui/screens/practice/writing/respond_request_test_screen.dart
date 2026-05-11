import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/shared/bold_text_label.dart';
import '../../../widgets/inputs/description_input_box.dart';
import '../../../widgets/practice/practice_bottom_bar.dart';
import '../../../widgets/cards/email_card.dart';
import '../../../../data/models/writing_question_model.dart';

class RespondRequestTestScreen extends StatefulWidget {
  final List<WritingQuestion> questions;
  final int initialIndex;

  const RespondRequestTestScreen({
    super.key,
    required this.questions,
    this.initialIndex = 0,
  });

  @override
  State<RespondRequestTestScreen> createState() =>
      _RespondRequestTestScreenState();
}

class _RespondRequestTestScreenState extends State<RespondRequestTestScreen> {
  late final TextEditingController _controller;
  late final Map<int, String> _answers;
  late int _currentQuestionIndex;

  @override
  void initState() {
    super.initState();
    _currentQuestionIndex = widget.initialIndex;
    _answers = {};
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  WritingQuestion get _currentQuestion =>
      widget.questions[_currentQuestionIndex];

  void _saveAnswer() {
    _answers[_currentQuestionIndex] = _controller.text;
  }

  void _goToNextQuestion() {
    _saveAnswer();
    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _controller.text = _answers[_currentQuestionIndex] ?? '';
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _submitTest() {
    _saveAnswer();
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Hoàn thành bài thi'),
          content: Text(
            'Bạn đã hoàn thành ${widget.questions.length} câu hỏi.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text('Quay lại'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final emailContent = _currentQuestion.emailContent ??
        'Nội dung email chưa có sẵn. Vui lòng kiểm tra dữ liệu từ backend.';
    final emailQuestions = _currentQuestion.emailQuestions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text('Câu ${_currentQuestionIndex + 1}/${widget.questions.length}'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Phản hồi yêu cầu',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            EmailCard(
              from: 'Author',
              subject: _currentQuestion.promptText,
              content: emailContent,
            ),
            const SizedBox(height: 24),
            if (emailQuestions.isNotEmpty) ...[
              const Text(
                'Các yêu cầu cần trả lời:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ...emailQuestions.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: TextStyle(fontSize: 16)),
                      Expanded(child: Text(item)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            const BoldTextLabel(text: 'Write a reply to this email'),
            const SizedBox(height: 16),
            DescriptionInputBox(
              controller: _controller,
              hintText: 'Viết email trả lời...',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
      bottomNavigationBar: PracticeBottomBar(
        onSubmit: _submitTest,
        onNext: _goToNextQuestion,
      ),
    );
  }
}
