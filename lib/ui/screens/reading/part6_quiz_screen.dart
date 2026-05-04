import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'reading_result_screen.dart';
import 'reading_quiz_screen.dart';

class Part6Passage {
  final List<String> segments; // text segments with blanks between
  final List<List<String>> options; // options per blank
  final List<int> correct; // correct index per blank

  Part6Passage({required this.segments, required this.options, required this.correct});
}

class Part6QuizScreen extends StatefulWidget {
  final List<Part6Passage> passages;

  const Part6QuizScreen({super.key, required this.passages});

  @override
  State<Part6QuizScreen> createState() => _Part6QuizScreenState();
}

class _Part6QuizScreenState extends State<Part6QuizScreen> {
  late final PageController _pageController;
  late final List<List<int?>> _selected; // selected per passage per blank
  late final List<int> _currentBlank; // current blank index per passage
  double _dragDx = 0.0; // for blank swipe
  double _pageDragDx = 0.0; // for passage swipe

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _selected = widget.passages.map((p) => List<int?>.filled(p.options.length, null)).toList();
    _currentBlank = widget.passages.map((p) => 0).toList();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _select(int passageIndex, int optIndex) {
    setState(() {
      final cur = _currentBlank[passageIndex];
      // allow changing answer? currently prevent override
      if (_selected[passageIndex][cur] != null) return;
      _selected[passageIndex][cur] = optIndex;
      // If all answered across all passages -> finish
      final allAnswered = _selected.every((list) => list.every((e) => e != null));
      if (allAnswered) Future.delayed(const Duration(milliseconds: 400), _finish);
    });
  }

  void _finish() {
    final questions = <QuizQuestion>[];
    final selectedFlat = <int?>[];
    for (var p = 0; p < widget.passages.length; p++) {
      final pass = widget.passages[p];
      for (var i = 0; i < pass.options.length; i++) {
        questions.add(QuizQuestion(prompt: 'Đoạn ${p + 1} - Blank ${i + 1}', options: pass.options[i], correctIndex: pass.correct[i]));
        selectedFlat.add(_selected[p][i]);
      }
    }
    final correctCount = List.generate(questions.length, (i) => selectedFlat[i] == questions[i].correctIndex ? 1 : 0).fold(0, (a, b) => a + b);

    Navigator.of(context).pushReplacement(MaterialPageRoute(
      builder: (_) => ReadingResultScreen(correct: correctCount, total: questions.length, questions: questions, selectedIndices: selectedFlat),
    ));
  }

  Color? _optionColor(int pIndex, int blankIndex, int optIndex) {
    final sel = _selected[pIndex][blankIndex];
    if (sel == null) return null;
    final correct = widget.passages[pIndex].correct[blankIndex];
    if (optIndex == correct) return AppColors.answerCorrect;
    if (optIndex == sel && sel != correct) return AppColors.answerWrong;
    return null;
  }

  Border _optionBorder(int pIndex, int blankIndex, int optIndex) {
    final sel = _selected[pIndex][blankIndex];
    final correct = widget.passages[pIndex].correct[blankIndex];
    if (sel == null) return Border.all(color: AppColors.answerBorderDefault);
    if (optIndex == correct) return Border.all(color: AppColors.answerBorderCorrect, width: 2);
    if (optIndex == sel && sel != correct) return Border.all(color: AppColors.answerBorderWrong, width: 2);
    return Border.all(color: AppColors.answerBorderDefault);
  }

  Widget _buildBlankWidget(int pIndex, int idx) {
    final sel = _selected[pIndex][idx];
    final display = sel == null ? '_____' : widget.passages[pIndex].options[idx][sel];
    return GestureDetector(
      onTap: () => setState(() => _currentBlank[pIndex] = idx),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: AppColors.primaryLighter, borderRadius: BorderRadius.circular(6)),
        child: Text(display, style: const TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Part 6', centerTitle: true),
      backgroundColor: AppColors.background,
      body: PageView.builder(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: widget.passages.length,
        itemBuilder: (context, pIndex) {
          final passage = widget.passages[pIndex];
          final curBlank = _currentBlank[pIndex];

          return Column(
            children: [
              // Passage area: swipe here to jump passages
              GestureDetector(
                onHorizontalDragUpdate: (details) {
                  _pageDragDx += details.delta.dx;
                  if (_pageDragDx < -80) {
                    if (pIndex < widget.passages.length - 1) {
                      _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    }
                    _pageDragDx = 0;
                  } else if (_pageDragDx > 80) {
                    if (pIndex > 0) {
                      _pageController.previousPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut);
                    }
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
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Wrap(children: [for (var i = 0; i < passage.segments.length; i++) ...[
                        Text(passage.segments[i]), if (i < passage.correct.length) _buildBlankWidget(pIndex, i),
                      ]]),
                    ]),
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Options area: swipe here to move between blanks in same passage
              Expanded(
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    _dragDx += details.delta.dx;
                    if (_dragDx < -80) {
                      if (_currentBlank[pIndex] < passage.options.length - 1) {
                        setState(() => _currentBlank[pIndex] = _currentBlank[pIndex] + 1);
                      }
                      _dragDx = 0;
                    } else if (_dragDx > 80) {
                      if (_currentBlank[pIndex] > 0) {
                        setState(() => _currentBlank[pIndex] = _currentBlank[pIndex] - 1);
                      }
                      _dragDx = 0;
                    }
                  },
                  onHorizontalDragEnd: (_) => _dragDx = 0,
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Chọn đáp án cho chỗ trống ${curBlank + 1}', style: const TextStyle(fontWeight: FontWeight.w700)),
                      const SizedBox(height: 12),

                      // options list for current blank
                      ...List.generate(passage.options[curBlank].length, (i) {
                        final bg = _optionColor(pIndex, curBlank, i);
                        final border = _optionBorder(pIndex, curBlank, i);
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
                                Expanded(child: Text(passage.options[curBlank][i], style: const TextStyle(fontSize: 16))),
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
                              final cur = _currentBlank[pIndex];
                              if (cur < passage.options.length - 1) {
                                setState(() => _currentBlank[pIndex] = cur + 1);
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
            ],
          );
        },
      ),
    );
  }
}
