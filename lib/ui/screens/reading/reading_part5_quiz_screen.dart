import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/reading_part5_model.dart';
import '../../../providers/reading_part5_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'reading_result_screen.dart';
import 'reading_quiz_screen.dart';
import '../../widgets/common/practice_result_view.dart';

class ReadingPart5QuizScreen extends StatefulWidget {
  final List<ReadingPart5Question> questions;
  final int startIndex;

  const ReadingPart5QuizScreen({super.key, required this.questions, this.startIndex = 0});

  @override
  State<ReadingPart5QuizScreen> createState() => _ReadingPart5QuizScreenState();
}

class _ReadingPart5QuizScreenState extends State<ReadingPart5QuizScreen> {
  late final PageController _pageController;
  late List<int?> _selected;
  late List<int?> _correctIndices; // null = unknown, -1 = not provided
  late List<bool> _isSubmitted;
  int _score = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.startIndex);
    _selected = List<int?>.filled(widget.questions.length, null);
    _correctIndices = List<int?>.filled(widget.questions.length, null);
    _isSubmitted = List<bool>.filled(widget.questions.length, false);
    _currentPage = widget.startIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _select(int qIndex, int optIndex) {
    if (_isSubmitted[qIndex]) return; // cannot change after submitted
    setState(() {
      _selected[qIndex] = optIndex;
    });
  }

  // Submit a single question's answer to server and update UI to show correct/wrong
  Future<void> _confirmOrNext(int qIndex) async {
    final provider = context.read<ReadingPart5Provider>();

    if (!_isSubmitted[qIndex]) {
      // confirm flow
      final sel = _selected[qIndex];
      if (sel == null) return; // nothing selected

      final answers = <String, int?>{widget.questions[qIndex].id: sel};
      try {
        final res = await provider.submitAnswers(answers);
        // find detail for this question
        final found = res.details.firstWhere((d) => d.questionId == widget.questions[qIndex].id, orElse: () => QuestionResult(questionId: widget.questions[qIndex].id, selectedOption: sel != null ? String.fromCharCode(65 + (sel as int)) : null, correctAnswer: null, isCorrect: false));
        int? correctIdx;
        if (found.correctAnswer != null && (found.correctAnswer as String).isNotEmpty) {
          final letter = (found.correctAnswer as String).toUpperCase();
          correctIdx = (letter.codeUnitAt(0) - 'A'.codeUnitAt(0));
        } else {
          correctIdx = null;
        }
        setState(() {
          _isSubmitted[qIndex] = true;
          _correctIndices[qIndex] = correctIdx;
          if (found.isCorrect) _score += 1;
        });
      } catch (e) {
        final msg = provider.errorMessage ?? e.toString();
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi gửi đáp án: $msg')));
      }
    } else {
      // next flow
      if (qIndex < widget.questions.length - 1) {
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      } else {
        // finished - show result view
        final resultView = Scaffold(
          backgroundColor: AppColors.background,
          body: PracticeResultView(
            score: _score,
            total: widget.questions.length,
            onRetry: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ReadingPart5QuizScreen(questions: widget.questions)));
            },
            onBack: () => Navigator.of(context).pop(),
          ),
        );

        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => resultView));
      }
    }
  }

  Color? _optionColor(int qIndex, int optIndex) {
    if (!_isSubmitted[qIndex]) return null;
    final correct = _correctIndices[qIndex];
    final sel = _selected[qIndex];
    if (correct != null && correct >= 0) {
      if (optIndex == correct) return AppColors.answerCorrect.withOpacity(0.12);
      if (sel != null && optIndex == sel && sel != correct) return AppColors.answerWrong.withOpacity(0.12);
    } else {
      // if server didn't return correctIndex, use isCorrect flag heuristic (not available here) -> highlight selected wrong
      if (sel != null && optIndex == sel) return AppColors.answerWrong.withOpacity(0.12);
    }
    return null;
  }

  Border? _optionBorder(int qIndex, int optIndex) {
    if (!_isSubmitted[qIndex]) {
      final sel = _selected[qIndex];
      if (sel == null) return Border.all(color: AppColors.answerBorderDefault);
      if (optIndex == sel) return Border.all(color: AppColors.primary, width: 2);
      return Border.all(color: AppColors.answerBorderDefault);
    }

    final correct = _correctIndices[qIndex];
    final sel = _selected[qIndex];
    if (correct != null && correct >= 0) {
      if (optIndex == correct) return Border.all(color: AppColors.answerBorderCorrect, width: 2);
      if (sel != null && optIndex == sel && sel != correct) return Border.all(color: AppColors.answerBorderWrong, width: 2);
      return Border.all(color: AppColors.answerBorderDefault);
    }

    if (sel != null && optIndex == sel) return Border.all(color: AppColors.answerBorderWrong, width: 2);
    return Border.all(color: AppColors.answerBorderDefault);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Part 5 - Câu ${_currentPage + 1}', centerTitle: true),
      backgroundColor: AppColors.background,
      body: PageView.builder(
        controller: _pageController,
        itemCount: widget.questions.length,
        onPageChanged: (p) => setState(() => _currentPage = p),
        itemBuilder: (context, index) {
          final q = widget.questions[index];
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.all(16), child: Text(q.prompt, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                    const SizedBox(height: 20),
                    ...List.generate(q.options.length, (oi) {
                      final border = _optionBorder(index, oi);
                      final label = String.fromCharCode(65 + oi);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: InkWell(
                          onTap: () => _select(index, oi),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: border),
                            child: Row(children: [
                              CircleAvatar(radius: 16, backgroundColor: AppColors.primary.withOpacity(0.06), child: Text(label)),
                              const SizedBox(width: 12),
                              Expanded(child: Text(q.options[oi])),
                            ]),
                          ),
                        ),
                      );
                    }),
                  ]),
                ),
              ),

              SafeArea(
                top: false,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  color: AppColors.background,
                  child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text('Câu ${index + 1}', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.w700, fontSize: 16)),
                    // Confirm / Continue button
                    ElevatedButton(
                      onPressed: (_isSubmitted[index] || _selected[index] != null) ? () => _confirmOrNext(index) : null,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0),
                        child: Text(_isSubmitted[index] ? (index < widget.questions.length - 1 ? 'Tiếp tục' : 'Xem kết quả') : 'Xác nhận', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ]),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}

// Reuse `QuizQuestion` defined in `reading_quiz_screen.dart`
