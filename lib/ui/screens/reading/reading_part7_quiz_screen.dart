import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/reading_part7_model.dart';
import '../../../providers/reading_part7_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/practice_result_view.dart';

class ReadingPart7QuizScreen extends StatefulWidget {
  final ReadingPart7Passage passage;
  final int startIndex;

  const ReadingPart7QuizScreen({super.key, required this.passage, this.startIndex = 0});

  @override
  State<ReadingPart7QuizScreen> createState() => _ReadingPart7QuizScreenState();
}

class _ReadingPart7QuizScreenState extends State<ReadingPart7QuizScreen> {
  late final PageController _pageController;
  late List<int?> _selected;
  late List<int?> _correctIndices;
  late List<bool> _isSubmitted;
  int _score = 0;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.startIndex);
    _selected = List<int?>.filled(widget.passage.questions.length, null);
    _correctIndices = List<int?>.filled(widget.passage.questions.length, null);
    _isSubmitted = List<bool>.filled(widget.passage.questions.length, false);
    _currentPage = widget.startIndex;
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _select(int qIndex, int optIndex) {
    if (_isSubmitted[qIndex]) return;
    setState(() {
      _selected[qIndex] = optIndex;
    });
  }

  Future<void> _confirmOrNext(int qIndex) async {
    final provider = context.read<ReadingPart7Provider>();

    if (!_isSubmitted[qIndex]) {
      final sel = _selected[qIndex];
      if (sel == null) return;
      final answers = <String, int?>{widget.passage.questions[qIndex].id: sel};
      try {
        final res = await provider.submitAnswers(answers);
        final found = res.details.firstWhere((d) => d.questionId == widget.passage.questions[qIndex].id, orElse: () => QuestionResult7(questionId: widget.passage.questions[qIndex].id, selectedOption: sel != null ? String.fromCharCode(65 + (sel as int)) : null, correctAnswer: null, isCorrect: false));
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
      if (qIndex < widget.passage.questions.length - 1) {
        _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
      } else {
        final resultView = Scaffold(
          backgroundColor: AppColors.background,
          body: PracticeResultView(
            score: _score,
            total: widget.passage.questions.length,
            onRetry: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ReadingPart7QuizScreen(passage: widget.passage)));
            },
            onBack: () => Navigator.of(context).pop(),
          ),
        );
        Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => resultView));
      }
    }
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

  Color? _optionColor(int qIndex, int optIndex) {
    if (!_isSubmitted[qIndex]) return null;
    final correct = _correctIndices[qIndex];
    final sel = _selected[qIndex];
    if (correct != null && correct >= 0) {
      if (optIndex == correct) return AppColors.answerCorrect.withOpacity(0.12);
      if (sel != null && optIndex == sel && sel != correct) return AppColors.answerWrong.withOpacity(0.12);
    } else {
      if (sel != null && optIndex == sel) return AppColors.answerWrong.withOpacity(0.12);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Part 7 - Câu ${_currentPage + 1}', centerTitle: true),
      backgroundColor: AppColors.background,
      body: Column(children: [
        // Passage area: constrain height and make scrollable for long passages
        Container(
          width: double.infinity,
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 260),
            child: SingleChildScrollView(
              child: Text(widget.passage.passage, style: const TextStyle(fontSize: 15)),
            ),
          ),
        ),
        Expanded(
          child: PageView.builder(
            controller: _pageController,
            itemCount: widget.passage.questions.length,
            onPageChanged: (p) => setState(() => _currentPage = p),
            itemBuilder: (context, index) {
              final q = widget.passage.questions[index];
              return Column(children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Container(width: double.infinity, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)), padding: const EdgeInsets.all(16), child: Text(q.prompt, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600))),
                      const SizedBox(height: 16),
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
                              child: Row(children: [CircleAvatar(radius: 16, backgroundColor: AppColors.primary.withOpacity(0.06), child: Text(label)), const SizedBox(width: 12), Expanded(child: Text(q.options[oi]))]),
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
                      ElevatedButton(
                        onPressed: (_isSubmitted[index] || _selected[index] != null) ? () => _confirmOrNext(index) : null,
                        style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 12.0), child: Text(_isSubmitted[index] ? (index < widget.passage.questions.length - 1 ? 'Tiếp tục' : 'Xem kết quả') : 'Xác nhận', style: const TextStyle(fontWeight: FontWeight.bold))),
                      ),
                    ]),
                  ),
                )
              ]);
            },
          ),
        )
      ]),
    );
  }
}
