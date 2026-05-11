import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../widgets/cards/reusable_image_card.dart';
import '../../../widgets/inputs/description_input_box.dart';
import '../../../widgets/practice/practice_bottom_bar.dart';
import '../../../widgets/shared/bold_text_label.dart';
import '../../../../data/models/writing_question_model.dart';

class PictureDescriptionTestScreen extends StatefulWidget {
  final List<WritingQuestion> questions;
  final int initialIndex;

  const PictureDescriptionTestScreen({
    super.key,
    required this.questions,
    this.initialIndex = 0,
  });

  @override
  State<PictureDescriptionTestScreen> createState() =>
      _PictureDescriptionTestScreenState();
}

class _PictureDescriptionTestScreenState extends State<PictureDescriptionTestScreen> {
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
    final promptImageUrl = _currentQuestion.promptImageUrl ??
        'https://via.placeholder.com/600x400?text=No+Image';
    final wordHint = _currentQuestion.givenWords.isNotEmpty
        ? _currentQuestion.givenWords.join(' / ')
        : 'Sử dụng các từ cho trước';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.primary,
        elevation: 0,
        title: Text(
          'Câu ${_currentQuestionIndex + 1}/${widget.questions.length}',
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Mô tả tranh',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            ReusableImageCard(imageUrl: promptImageUrl),
            const SizedBox(height: 24),
            BoldTextLabel(text: wordHint),
            const SizedBox(height: 16),
            DescriptionInputBox(
              controller: _controller,
              hintText: 'Viết câu trả lời của bạn...',
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
