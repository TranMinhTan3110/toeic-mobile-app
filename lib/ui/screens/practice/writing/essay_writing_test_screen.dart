import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/cards/essay_prompt_card.dart';
import '../../../widgets/shared/bold_text_label.dart';
import '../../../widgets/inputs/description_input_box.dart';
import '../../../widgets/practice/practice_bottom_bar.dart';
import '../../../../data/models/writing_question_model.dart';

class EssayWritingTestScreen extends StatefulWidget {
  final List<WritingQuestion> questions;
  final int initialIndex;

  const EssayWritingTestScreen({
    super.key,
    required this.questions,
    this.initialIndex = 0,
  });

  @override
  State<EssayWritingTestScreen> createState() =>
      _EssayWritingTestScreenState();
}

class _EssayWritingTestScreenState extends State<EssayWritingTestScreen> {
  late int _currentQuestionIndex;
  late Map<int, String> _answers;
  late TextEditingController _controller;

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

  void _goToNextQuestion() {
    // Save current answer
    _answers[_currentQuestionIndex] = _controller.text;

    if (_currentQuestionIndex < widget.questions.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _controller.text = _answers[_currentQuestionIndex] ?? '';
      });
    } else {
      // All questions done
      _showCompletionDialog();
    }
  }

  void _goToPreviousQuestion() {
    // Save current answer
    _answers[_currentQuestionIndex] = _controller.text;

    if (_currentQuestionIndex > 0) {
      setState(() {
        _currentQuestionIndex--;
        _controller.text = _answers[_currentQuestionIndex] ?? '';
      });
    }
  }

  void _submitTest() {
    // Save current answer
    _answers[_currentQuestionIndex] = _controller.text;
    _showCompletionDialog();
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Hoàn thành bài thi'),
          content: Text(
            'Bạn đã hoàn thành ${widget.questions.length} câu hỏi.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Back to EssayWritingScreen
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        title: Text(
          'Câu ${_currentQuestionIndex + 1}/${widget.questions.length}',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Viết luận',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            EssayPromptCard(
              prompt: _currentQuestion.promptText,
            ),
            const SizedBox(height: 24),
            const BoldTextLabel(text: 'Write your essay'),
            const SizedBox(height: 16),
            DescriptionInputBox(
              controller: _controller,
              hintText: 'Viết bài luận của bạn...',
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
