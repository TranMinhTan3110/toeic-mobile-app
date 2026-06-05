import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/practice/answer_card.dart';
import '../../shared/practice_dialogs.dart';
import '../../../data/models/reading_part6_model.dart';
import '../../../providers/reading_part6_provider.dart';
import '../../../core/utils/practice_option_parser.dart';
import 'reading_part6_history_detail_screen.dart';

class ReadingPart6PracticeScreen extends StatefulWidget {
  final int passageCount;

  const ReadingPart6PracticeScreen({super.key, required this.passageCount});

  @override
  State<ReadingPart6PracticeScreen> createState() => _ReadingPart6PracticeScreenState();
}

class _ReadingPart6PracticeScreenState extends State<ReadingPart6PracticeScreen> {
  late PageController _pageController;
  int _currentIdx = 0;
  bool _showExplanation = false;
  double _fontSize = 14.0;
  bool _autoShowExplanation = false;
  final _selectedKeys = <int, String?>{};
  final _submittedKeys = <int, String?>{};
  final _userAnswers = <String, String>{};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIdx);
    WidgetsBinding.instance.addPostFrameCallback((_) { context.read<ReadingPart6Provider>().fetchQuestionsByPassageCount(widget.passageCount); });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectOption(int qIndex, String key) {
    if (_submittedKeys[qIndex] != null) return;
    setState(() { _selectedKeys[qIndex] = key; });
  }

  Future<void> _submitAnswer(int qIndex, ReadingPart6Question question) async {
    final provider = context.read<ReadingPart6Provider>();
    final selectedKey = _selectedKeys[qIndex];
    if (selectedKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn một đáp án')));
      return;
    }

    final optIndex = selectedKey.codeUnitAt(0) - 65;
    final answers = <String, int?>{question.id: optIndex};

    try { await provider.submitAnswers(answers); } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi gửi đáp án: $e'))); } finally {
      _userAnswers[question.id] = selectedKey;
      setState(() {
        _submittedKeys[qIndex] = selectedKey;
        if (_autoShowExplanation) {
          _showExplanation = true;
        }
      });
    }
  }

  Future<void> _finishQuiz() async {
    final provider = context.read<ReadingPart6Provider>();
    final questions = provider.questions;
    int correctCount = 0;
    List<String> incorrectQuestionIds = [];

    for (var question in questions) {
      final selectedKey = _userAnswers[question.id];
      if (selectedKey != null && PracticeOptionParser.isSelectionCorrect(selectedKey, question.correctAnswer, question.options)) {
        correctCount++;
      } else {
        incorrectQuestionIds.add(question.id);
      }
    }

    final percent = (questions.isEmpty ? 0.0 : (correctCount / questions.length * 100).toDouble());

    try {
      await provider.savePracticeHistory(correctCount: correctCount, totalCount: questions.length, percent: percent, incorrectQuestionIds: incorrectQuestionIds, selectedAnswers: _userAnswers);
      final history = provider.history.isNotEmpty ? provider.history.first : null;
      if (history != null && mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ReadingPart6HistoryDetailScreen(historyItem: history)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi lưu lịch sử: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Câu ${_currentIdx + 1}',
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.error_outline_rounded, color: AppColors.appBarFg, size: 22),
            onPressed: () => showReportDialog(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.settings_rounded, color: AppColors.appBarFg, size: 22),
            onPressed: () => showReadingSettingsDialog(
              context,
              fontSize: _fontSize,
              autoShowExplanation: _autoShowExplanation,
              onFontSizeChanged: (v) => setState(() => _fontSize = v),
              onAutoShowExplanationChanged: (v) => setState(() => _autoShowExplanation = v),
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.favorite_border_rounded, color: AppColors.appBarFg, size: 22),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: () => setState(() => _showExplanation = !_showExplanation),
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              child: const Text(
                'Giải thích',
                style: TextStyle(
                  color: AppColors.appBarFg,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  decoration: TextDecoration.underline,
                  decorationColor: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Consumer<ReadingPart6Provider>(builder: (context, provider, child) {
        if (provider.isLoading && provider.questions.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (provider.errorMessage != null) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Lỗi: ${provider.errorMessage}', style: const TextStyle(color: Colors.red)), const SizedBox(height: 16), ElevatedButton(onPressed: () => provider.fetchQuestionsByPassageCount(widget.passageCount), child: const Text('Thử lại'))]));
        }

        final questions = provider.questions;
        if (questions.isEmpty) return const Center(child: Text('Không có câu hỏi nào'));

        return Stack(
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() {
                _currentIdx = index;
                _showExplanation = false;
              }),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final question = questions[index];
                final selectedKey = _selectedKeys[index];
                final isSubmitted = _submittedKeys[index] != null;

                final _normalizedCorrect = PracticeOptionParser.normalizeCorrectKey(question.correctAnswer, options: question.options);
                String? _correctKeyToShow;
                if (_normalizedCorrect.length == 1 && 'ABCD'.contains(_normalizedCorrect)) {
                  _correctKeyToShow = _normalizedCorrect;
                } else {
                  final target = question.correctAnswer.trim().toLowerCase();
                  for (var oi = 0; oi < question.options.length; oi++) {
                    final optDisplay = PracticeOptionParser.displayText(question.options[oi]).toLowerCase();
                    final optRaw = question.options[oi].trim().toLowerCase();
                    if (optDisplay == target || optRaw == target || optDisplay.contains(target) || target.contains(optDisplay)) {
                      _correctKeyToShow = String.fromCharCode(65 + oi);
                      break;
                    }
                  }
                }

                // debug: print current question details
                // ignore: avoid_print
                print('ReadingPart6PracticeScreen: totalQuestions=${questions.length} currentIndex=$index');
                // ignore: avoid_print
                print('currentPassage.passageText: ${question.passage}');
                // ignore: avoid_print
                print('currentQuestion.questionText: ${question.questionText}');
                // ignore: avoid_print
                print('currentQuestion.optionA: ${question.options.isNotEmpty ? question.options[0] : ''}');

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Câu ${index + 1}/${questions.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary))]),
                      const SizedBox(height: 12),
                      ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: (index + 1) / questions.length, backgroundColor: AppColors.primaryLighter, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary), minHeight: 6)),
                      const SizedBox(height: 20),
                      // Passage (separate card)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))]),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Đoạn văn', style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                            const SizedBox(height: 8),
                            Text(question.passage, style: TextStyle(fontSize: _fontSize, color: AppColors.textPrimary, height: 1.6)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      const SizedBox(height: 16),
                      // Options
                      AnswerCardWrapper(options: question.options, selectedKey: selectedKey, correctKey: isSubmitted ? _correctKeyToShow : null, onSelect: (k) => _selectOption(index, k), fontSize: _fontSize),
                    ],
                  ),
                );
              },
            ),
            if (_showExplanation)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: SizedBox(
                  height: 420,
                  child: _ExplanationPanel(
                    passageVi: questions[_currentIdx].passageTranslationVi ?? questions[_currentIdx].translation ?? 'Không có lời dịch cho đoạn văn.',
                    answerVi: questions[_currentIdx].explanationVi ?? questions[_currentIdx].translation ?? questions[_currentIdx].explanation ?? 'Không có lời giải cho câu hỏi này.',
                    onClose: () => setState(() => _showExplanation = false),
                  ),
                ),
              ),
          ],
        );
      }),
      bottomSheet: _buildBottomControls(),
    );
  }

  Widget _buildBottomControls() {
    return Consumer<ReadingPart6Provider>(builder: (context, provider, _) {
      final questions = provider.questions;
      if (questions.isEmpty) return const SizedBox.shrink();
      final question = questions[_currentIdx];
      final selectedKey = _selectedKeys[_currentIdx];
      final isSubmitted = _submittedKeys[_currentIdx] != null;
      final isLastQuestion = _currentIdx == questions.length - 1;
      final allSubmitted = _submittedKeys.length == questions.length;

      final onPressed = !isSubmitted && selectedKey != null
          ? () => _submitAnswer(_currentIdx, question)
          : (isLastQuestion && allSubmitted)
              ? _finishQuiz
              : (isSubmitted && !isLastQuestion)
                  ? () => _pageController.nextPage(duration: const Duration(milliseconds: 300), curve: Curves.easeInOut)
                  : null;

      return Container(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.divider))),
        child: SafeArea(
          top: false,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Câu ${_currentIdx + 1}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.primary)),
              ElevatedButton(
                onPressed: onPressed,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, disabledBackgroundColor: AppColors.primaryLight, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  child: Text(!isSubmitted ? 'Xác nhận' : isLastQuestion ? 'Xem kết quả' : 'Tiếp tục', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}

// Wrapper to reuse existing AnswerCard component structure from Part5

class AnswerCardWrapper extends StatelessWidget {
  const AnswerCardWrapper({required this.options, this.selectedKey, this.correctKey, this.onSelect, this.fontSize = 14.0});
  final List<String> options;
  final String? selectedKey;
  final String? correctKey;
  final ValueChanged<String>? onSelect;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return AnswerCard(
      options: List.generate(options.length, (oi) => AnswerOption(key: String.fromCharCode(65 + oi), text: options[oi])),
      selectedKey: selectedKey,
      correctKey: correctKey,
      onSelect: onSelect,
      fontSize: fontSize,
    );
  }
}

class _ExplanationPanel extends StatefulWidget {
  final String passageVi;
  final String answerVi;
  final VoidCallback onClose;

  const _ExplanationPanel({required this.passageVi, required this.answerVi, required this.onClose});

  @override
  State<_ExplanationPanel> createState() => _ExplanationPanelState();
}

class _ExplanationPanelState extends State<_ExplanationPanel> {
  String _activeTab = 'Lời dịch';

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildTab('Lời dịch'),
                      const SizedBox(width: 24),
                      _buildTab('Lời giải'),
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: Colors.white30,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Container(height: 1, color: Colors.white24),
          SizedBox(
            height: 250,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_activeTab == 'Lời dịch')
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        widget.passageVi,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.7,
                        ),
                      ),
                    )
                  else
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        widget.answerVi,
                        textAlign: TextAlign.start,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.7,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title) {
    final isActive = _activeTab == title;
    return GestureDetector(
      onTap: () => setState(() => _activeTab = title),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isActive ? FontWeight.bold : FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          if (isActive)
            Container(
              height: 3,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
        ],
      ),
    );
  }
}


