import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/vocabulary_model.dart';
import '../../widgets/practice/answer_card.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../../core/services/tts_service.dart';
import 'quiz_helper.dart';
import '../../widgets/common/practice_result_view.dart';

class VocabularyQuizScreen extends StatefulWidget {
  final List<VocabularyModel> words;
  final QuizType quizType;

  const VocabularyQuizScreen({
    super.key,
    required this.words,
    required this.quizType,
  });

  @override
  State<VocabularyQuizScreen> createState() => _VocabularyQuizScreenState();
}

class _VocabularyQuizScreenState extends State<VocabularyQuizScreen> {
  late List<QuizQuestion> _questions;
  int _currentIndex = 0;
  String? _selectedKey;
  bool _isSubmitted = false;
  int _score = 0;
  bool _isFinished = false;

  @override
  void initState() {
    super.initState();
    _questions = QuizHelper.generateQuiz(widget.words, widget.quizType);
    _playCurrentAudio();
  }

  void _playCurrentAudio() {
    if (widget.quizType == QuizType.wordToDefinition && _currentIndex < _questions.length) {
      TtsService().speak(_questions[_currentIndex].originalWord.word);
    }
  }

  void _handleSelect(String key) {
    if (_isSubmitted) return;
    setState(() {
      _selectedKey = key;
    });
  }

  void _handleSubmit() {
    if (_selectedKey == null || _isSubmitted) return;

    setState(() {
      _isSubmitted = true;
      if (_selectedKey == _questions[_currentIndex].correctKey) {
        _score++;
      }
    });
  }

  void _handleNext() {
    if (_currentIndex < _questions.length - 1) {
      setState(() {
        _currentIndex++;
        _selectedKey = null;
        _isSubmitted = false;
      });
      _playCurrentAudio();
    } else {
      setState(() {
        _isFinished = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isFinished) {
      return _buildResultScreen();
    }

    if (_questions.isEmpty) {
      return Scaffold(
        appBar: const CustomAppBar(title: 'Luyện tập', centerTitle: true),
        body: const Center(child: Text('Không đủ dữ liệu để tạo Quiz (Cần tối thiểu 4 từ).')),
      );
    }

    final currentQuestion = _questions[_currentIndex];
    final progress = (_currentIndex + 1) / _questions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: widget.quizType == QuizType.wordToDefinition ? 'Chọn từ' : 'Định nghĩa',
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Progress Bar
          _buildProgressBar(progress),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                children: [
                  // Question Card
                  _buildQuestionSection(currentQuestion.question),
                  
                  const SizedBox(height: 20),
                  
                  // Answer Options
                  AnswerCard(
                    options: currentQuestion.options,
                    selectedKey: _selectedKey,
                    correctKey: _isSubmitted ? currentQuestion.correctKey : null,
                    onSelect: _handleSelect,
                    title: 'Chọn đáp án đúng',
                  ),
                ],
              ),
            ),
          ),
          
          // Bottom Actions
          _buildBottomAction(),
        ],
      ),
    );
  }

  Widget _buildProgressBar(double progress) {
    return Column(
      children: [
        LinearProgressIndicator(
          value: progress,
          backgroundColor: AppColors.divider,
          color: AppColors.primary,
          minHeight: 6,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Câu hỏi ${_currentIndex + 1}/${_questions.length}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                  fontSize: 13,
                ),
              ),
              Text(
                'Đúng: $_score',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuestionSection(String question) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: shadowColor,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Nghĩa của từ này là gì?',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                question,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              if (widget.quizType == QuizType.wordToDefinition) ...[
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => TtsService().speak(question),
                  icon: const Icon(Icons.volume_up, color: AppColors.primary),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x0D000000),
            blurRadius: 10,
            offset: Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: _selectedKey == null ? null : (_isSubmitted ? _handleNext : _handleSubmit),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppColors.divider,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 0,
          ),
          child: Text(
            _isSubmitted ? 'Tiếp theo' : 'Kiểm tra',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
      ),
    );
  }

  void _resetQuiz() {
    setState(() {
      _questions = QuizHelper.generateQuiz(widget.words, widget.quizType);
      _currentIndex = 0;
      _score = 0;
      _isFinished = false;
      _isSubmitted = false;
      _selectedKey = null;
    });
    _playCurrentAudio();
  }

  Widget _buildResultScreen() {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PracticeResultView(
        score: _score,
        total: _questions.length,
        onRetry: _resetQuiz,
        onBack: () => Navigator.pop(context),
      ),
    );
  }

  static const Color shadowColor = Color(0x0F000000);
}
