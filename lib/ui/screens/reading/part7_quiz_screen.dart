import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'reading_result_screen.dart';
import 'reading_quiz_screen.dart';

class Part7Passage {
  final String passageText;
  final List<Part7Question> questions;
  Part7Passage({required this.passageText, required this.questions});
}

class Part7Question {
  final String prompt;
  final List<String> options;
  final int correctIndex;
  Part7Question({required this.prompt, required this.options, required this.correctIndex});
}

class Part7QuizScreen extends StatefulWidget {
  final List<Part7Passage> passages;
  const Part7QuizScreen({super.key, required this.passages});

  @override
  State<Part7QuizScreen> createState() => _Part7QuizScreenState();
}

class _Part7QuizScreenState extends State<Part7QuizScreen> {
  late final PageController _pageController;
  late final List<List<int?>> _selected; // per passage per question
  late final List<int> _currentQuestion; // current question index per passage
  double _dragDx = 0.0; // for question swipe
  double _pageDragDx = 0.0; // for passage swipe

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _selected = widget.passages.map((p) => List<int?>.filled(p.questions.length, null)).toList();
    _currentQuestion = widget.passages.map((p) => 0).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _select(int passageIndex, int optIndex) {
    setState(() {
      final cur = _currentQuestion[passageIndex];
      if (_selected[passageIndex][cur] != null) return;
      _selected[passageIndex][cur] = optIndex;
      final allAnswered = _selected.every((list) => list.every((e) => e != null));
      if (allAnswered) Future.delayed(const Duration(milliseconds: 350), _finish);
    });
  }

  Color? _optionColor(int pIndex, int qIndex, int optIndex) {
    final sel = _selected[pIndex][qIndex];
    if (sel == null) return null;
    final correct = widget.passages[pIndex].questions[qIndex].correctIndex;
    if (optIndex == correct) return AppColors.answerCorrect;
    if (optIndex == sel && sel != correct) return AppColors.answerWrong;
    return null;
  }

  Border _optionBorder(int pIndex, int qIndex, int optIndex) {
    final sel = _selected[pIndex][qIndex];
    final correct = widget.passages[pIndex].questions[qIndex].correctIndex;
    if (sel == null) return Border.all(color: AppColors.answerBorderDefault);
    if (optIndex == correct) return Border.all(color: AppColors.answerBorderCorrect, width: 2);
    if (optIndex == sel && sel != correct) return Border.all(color: AppColors.answerBorderWrong, width: 2);
    return Border.all(color: AppColors.answerBorderDefault);
  }

  void _finish() {
    final flatQuestions = <Part7Question>[];
    for (var p in widget.passages) {
      flatQuestions.addAll(p.questions);
    }

    int correctCount = 0;
    final selectedFlat = <int?>[];
    for (var p = 0; p < widget.passages.length; p++) {
      for (var q = 0; q < widget.passages[p].questions.length; q++) {
        selectedFlat.add(_selected[p][q]);
        if (_selected[p][q] != null && _selected[p][q] == widget.passages[p].questions[q].correctIndex) correctCount++;
      }
    }

    final quizQuestions = flatQuestions.map((q) => QuizQuestion(prompt: q.prompt, options: q.options, correctIndex: q.correctIndex)).toList();

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ReadingResultScreen(correct: correctCount, total: flatQuestions.length, questions: quizQuestions, selectedIndices: selectedFlat)));
  }

  Widget _questionChip(int pIndex, int qIndex) {
    final sel = _selected[pIndex][qIndex];
    return GestureDetector(
      onTap: () => setState(() => _currentQuestion[pIndex] = qIndex),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(color: sel == null ? AppColors.primaryLighter : AppColors.surface, borderRadius: BorderRadius.circular(6)),
        child: Text('${qIndex + 1}', style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Part 7', centerTitle: true),
      backgroundColor: AppColors.background,
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.passages.length,
        itemBuilder: (context, pIndex) {
          final passage = widget.passages[pIndex];
          final curQ = _currentQuestion[pIndex];

          return Column(children: [
            // Passage area: vertical scroll if long, swipe horizontally to change passage
            GestureDetector(
              onHorizontalDragUpdate: (details) {
                _pageDragDx += details.delta.dx;
                if (_pageDragDx < -80) {
                  if (pIndex < widget.passages.length - 1) _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  _pageDragDx = 0;
                } else if (_pageDragDx > 80) {
                  if (pIndex > 0) _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                  _pageDragDx = 0;
                }
              },
              onHorizontalDragEnd: (_) => _pageDragDx = 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
                  child: SingleChildScrollView(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(passage.passageText),
                      const SizedBox(height: 12),
                      Wrap(children: [for (var i = 0; i < passage.questions.length; i++) _questionChip(pIndex, i)]),
                    ]),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Options area: swipe to change question within same passage
            Expanded(
              child: GestureDetector(
                onHorizontalDragUpdate: (details) {
                  _dragDx += details.delta.dx;
                  if (_dragDx < -80) {
                    if (_currentQuestion[pIndex] < passage.questions.length - 1) setState(() => _currentQuestion[pIndex] = _currentQuestion[pIndex] + 1);
                    _dragDx = 0;
                  } else if (_dragDx > 80) {
                    if (_currentQuestion[pIndex] > 0) setState(() => _currentQuestion[pIndex] = _currentQuestion[pIndex] - 1);
                    _dragDx = 0;
                  }
                },
                onHorizontalDragEnd: (_) => _dragDx = 0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Câu hỏi ${curQ + 1}: ${passage.questions[curQ].prompt}', style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),

                    // options
                    ...List.generate(passage.questions[curQ].options.length, (i) {
                      final bg = _optionColor(pIndex, curQ, i);
                      final border = _optionBorder(pIndex, curQ, i);
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: GestureDetector(
                          onTap: () => _select(pIndex, i),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                            decoration: BoxDecoration(color: bg ?? Colors.white, borderRadius: BorderRadius.circular(12), border: border),
                            child: Row(children: [
                              Container(width: 36, height: 36, decoration: BoxDecoration(shape: BoxShape.circle, border: border, color: Colors.white), child: Center(child: Text(String.fromCharCode(65 + i), style: const TextStyle(fontWeight: FontWeight.w700)))),
                              const SizedBox(width: 12),
                              Expanded(child: Text(passage.questions[curQ].options[i], style: const TextStyle(fontSize: 16))),
                            ]),
                          ),
                        ),
                      );
                    }),

                    const Spacer(),

                    SafeArea(
                      top: false,
                      child: SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () {
                            final cur = _currentQuestion[pIndex];
                            if (cur < passage.questions.length - 1) {
                              setState(() => _currentQuestion[pIndex] = cur + 1);
                              return;
                            }
                            if (pIndex < widget.passages.length - 1) {
                              _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                              return;
                            }
                            final allAnswered = _selected.every((list) => list.every((e) => e != null));
                            if (allAnswered) _finish();
                          },
                          style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                          child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Hoàn thành', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800))),
                        ),
                      ),
                    ),
                  ]),
                ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}
