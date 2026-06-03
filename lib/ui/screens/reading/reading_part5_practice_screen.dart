import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/practice/answer_card.dart';
// ...existing code...
import '../../../data/models/reading_part5_model.dart';
import '../../../providers/reading_part5_provider.dart';
import '../../../core/utils/practice_option_parser.dart';
import 'reading_part5_history_detail_screen.dart';

/// Màn hình làm bài Part 5 - dùng PageView để swipe qua các câu hỏi
class ReadingPart5PracticeScreen extends StatefulWidget {
  final int questionCount;

  const ReadingPart5PracticeScreen({
    super.key,
    required this.questionCount,
  });

  @override
  State<ReadingPart5PracticeScreen> createState() =>
      _ReadingPart5PracticeScreenState();
}

class _SelectAnswerHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFB8860B).withOpacity(0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: RichText(
        text: const TextSpan(
          style: TextStyle(color: Colors.white, fontSize: 15),
          children: [
            TextSpan(text: 'Select the '),
            TextSpan(
              text: 'answer',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
          ],
        ),
      ),
    );
  }
}

/// Reading-specific answer card that uses circular numbered pills for choices.
class ReadingAnswerCard extends StatelessWidget {
  const ReadingAnswerCard({
    super.key,
    required this.options,
    this.selectedKey,
    this.correctKey,
    this.onSelect,
    this.title = 'Chọn đáp án',
    this.fontSize = 14.0,
  });

  final List<AnswerOption> options;
  final String? selectedKey;
  final String? correctKey;
  final ValueChanged<String>? onSelect;
  final String title;
  final double fontSize;

  AnswerState _stateOf(String key) {
    if (correctKey == null) {
      return key == selectedKey ? AnswerState.selected : AnswerState.normal;
    }
    if (key == correctKey) return AnswerState.correct;
    if (key == selectedKey && key != correctKey) return AnswerState.wrong;
    return AnswerState.normal;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: AppColors.shadow,
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Row(
              children: [
                Container(
                  width: 4,
                  height: 18,
                  decoration: BoxDecoration(
                    color: AppColors.primary,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: AppColors.divider, height: 16),
          ...options.map((opt) {
            final state = _stateOf(opt.key);
            return _ReadingAnswerTile(
              option: opt,
              state: state,
              onTap: correctKey == null ? () => onSelect?.call(opt.key) : null,
              fontSize: fontSize,
            );
          }),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ReadingAnswerTile extends StatelessWidget {
  const _ReadingAnswerTile({required this.option, required this.state, this.onTap, required this.fontSize});

  final AnswerOption option;
  final AnswerState state;
  final VoidCallback? onTap;
  final double fontSize;

  Color get _bg {
    switch (state) {
      case AnswerState.selected:
        return AppColors.answerSelected;
      case AnswerState.correct:
        return AppColors.answerCorrect;
      case AnswerState.wrong:
        return AppColors.answerWrong;
      default:
        return AppColors.answerDefault;
    }
  }

  Color get _border {
    switch (state) {
      case AnswerState.selected:
        return AppColors.answerBorderSelected;
      case AnswerState.correct:
        return AppColors.answerBorderCorrect;
      case AnswerState.wrong:
        return AppColors.answerBorderWrong;
      default:
        return AppColors.answerBorderDefault;
    }
  }

  Color get _keyBg {
    switch (state) {
      case AnswerState.selected:
        return AppColors.primary;
      case AnswerState.correct:
        return AppColors.success;
      case AnswerState.wrong:
        return AppColors.error;
      default:
        return Colors.white;
    }
  }

  Color get _keyFg {
    return state == AnswerState.normal ? AppColors.textSecondary : AppColors.textOnPrimary;
  }

  IconData? get _trailingIcon {
    switch (state) {
      case AnswerState.correct:
        return Icons.check_circle_rounded;
      case AnswerState.wrong:
        return Icons.cancel_rounded;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _border, width: 1.5),
        ),
        child: Row(
          children: [
            // Circular key badge
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: _keyBg,
                shape: BoxShape.circle,
                border: state == AnswerState.normal ? Border.all(color: AppColors.surfaceVariant) : null,
              ),
              child: Center(
                child: Text(
                  option.key.length == 1 ? option.key : option.key[0].toUpperCase(),
                  style: TextStyle(
                    color: _keyFg,
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                option.text,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: fontSize,
                  height: 1.4,
                ),
              ),
            ),
            if (_trailingIcon != null) ...[
              const SizedBox(width: 8),
              Icon(
                _trailingIcon,
                color: state == AnswerState.correct ? AppColors.success : AppColors.error,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _ReadingExplanationPanel extends StatefulWidget {
  const _ReadingExplanationPanel({required this.script, required this.explanation, required this.explanationVi, required this.onClose});
  final String script;
  final String explanation;
  final String explanationVi;
  final VoidCallback onClose;

  @override
  State<_ReadingExplanationPanel> createState() => _ReadingExplanationPanelState();
}

class _ReadingExplanationPanelState extends State<_ReadingExplanationPanel> with SingleTickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() {
    super.initState();
    _tab = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tab.dispose();
    super.dispose();
  }

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
                  child: TabBar(
                    controller: _tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.white60,
                    labelStyle: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                    indicatorColor: Colors.white,
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Phụ đề'),
                      Tab(text: 'Lời dịch'),
                      Tab(text: 'Lời giải'),
                    ],
                  ),
                ),
                // Settings icon centered between two small icons (left placeholder + settings + close)
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(left: 8, right: 8),
                  decoration: const BoxDecoration(color: Colors.white30, shape: BoxShape.circle),
                  child: const Icon(Icons.settings_rounded, color: Colors.white, size: 18),
                ),
                GestureDetector(
                  onTap: widget.onClose,
                  child: Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: Colors.white30,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 250,
            child: TabBarView(
              controller: _tab,
              children: [
                _ExplanationText(widget.script),
                _ExplanationText(widget.explanationVi),
                _ExplanationText(widget.explanation),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ExplanationText extends StatelessWidget {
  const _ExplanationText(this.text);
  final String text;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontSize: 14, height: 1.7),
      ),
    );
  }
}

class _ReadingPart5PracticeScreenState extends State<ReadingPart5PracticeScreen> {
  late PageController _pageController;
  int _currentIdx = 0;

  // Track selected/submitted keys per page index
  final _selectedKeys = <int, String?>{};
  final _submittedKeys = <int, String?>{};

  // ...existing code...

  // Lưu tất cả câu trả lời của người dùng: QuestionId -> SelectedOption
  final _userAnswers = <String, String>{};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIdx);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ReadingPart5Provider>().fetchQuestionsByCount(widget.questionCount);
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _selectOption(int qIndex, String key) {
    if (_submittedKeys[qIndex] != null) return; // Can't change after submitted
    setState(() {
      _selectedKeys[qIndex] = key;
    });
  }

  Future<void> _submitAnswer(int qIndex, ReadingPart5Question question) async {
    final provider = context.read<ReadingPart5Provider>();
    final selectedKey = _selectedKeys[qIndex];

    if (selectedKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng chọn một đáp án')),
      );
      return;
    }

    // Debug log raw values to help diagnose correctness mismatches
    // ignore: avoid_print
    print('ReadingPart5._submitAnswer: qId=${question.id} rawCorrect="${question.correctAnswer}" options=${question.options} selectedKey=$selectedKey');
    // Also print parsed explanation/translation fields so we can verify model parsing
    // ignore: avoid_print
    print('ReadingPart5.debug: translation=${question.translation}');
    // ignore: avoid_print
    print('ReadingPart5.debug: explanation=${question.explanation}');
    // ignore: avoid_print
    print('ReadingPart5.debug: grammarExplanation=${question.grammarExplanation}');
    // ignore: avoid_print
    print('ReadingPart5.debug: grammarPoint=${question.grammarPoint}');
    // ignore: avoid_print
    print('ReadingPart5.debug: optionExplanations=${question.optionExplanations}');

    // Submit to server
    final optIndex = selectedKey.codeUnitAt(0) - 65; // A=0, B=1, C=2, D=3
    final answers = <String, int?>{question.id: optIndex};

    try {
      await provider.submitAnswers(answers);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi gửi đáp án (không ảnh hưởng tới trải nghiệm): ${e.toString()}')),
      );
    } finally {
      // Always record and show explanation locally so UX isn't blocked by backend errors
      _userAnswers[question.id] = selectedKey;
      setState(() {
        _submittedKeys[qIndex] = selectedKey;
      });
      // Do not show explanation immediately after submitting during practice.
      // Explanations are shown only in review/detail screens after finishing the quiz.
    }
  }

  Future<void> _finishQuiz() async {
    final provider = context.read<ReadingPart5Provider>();
    final questions = provider.questions;

    // Calculate correct answers
    int correctCount = 0;
    List<String> incorrectQuestionIds = [];

    for (var question in questions) {
      final selectedKey = _userAnswers[question.id];
      // debug
      // ignore: avoid_print
      print('ReadingPart5._finishQuiz: qId=${question.id} rawCorrect="${question.correctAnswer}" options=${question.options} selectedKey=$selectedKey');
      // ignore: avoid_print
      print('ReadingPart5.debug: translation=${question.translation}');
      // ignore: avoid_print
      print('ReadingPart5.debug: explanation=${question.explanation}');
      // ignore: avoid_print
      print('ReadingPart5.debug: grammarExplanation=${question.grammarExplanation}');
      // ignore: avoid_print
      print('ReadingPart5.debug: grammarPoint=${question.grammarPoint}');
      // ignore: avoid_print
      print('ReadingPart5.debug: optionExplanations=${question.optionExplanations}');
      if (selectedKey != null && PracticeOptionParser.isSelectionCorrect(selectedKey, question.correctAnswer, question.options)) {
        correctCount++;
      } else {
        incorrectQuestionIds.add(question.id);
      }
    }

    final percent = (correctCount / questions.length * 100).toDouble();

    try {
      // Save to backend
      await provider.savePracticeHistory(
        correctCount: correctCount,
        totalCount: questions.length,
        percent: percent,
        incorrectQuestionIds: incorrectQuestionIds,
        selectedAnswers: _userAnswers,
      );

      // Get the history item
      final history = provider.history.isNotEmpty ? provider.history.first : null;
      if (history != null && mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => ReadingPart5HistoryDetailScreen(historyItem: history),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi lưu lịch sử: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Reading Part 5',
        centerTitle: true,
      ),
      body: Consumer<ReadingPart5Provider>(
        builder: (context, provider, child) {
          if (provider.isLoading && provider.questions.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            );
          }

          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Lỗi: ${provider.errorMessage}',
                    style: const TextStyle(color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      provider.fetchQuestionsByCount(widget.questionCount);
                    },
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final questions = provider.questions;
          if (questions.isEmpty) {
            return const Center(
              child: Text('Không có câu hỏi nào'),
            );
          }

          return PageView.builder(
            controller: _pageController,
            onPageChanged: (index) => setState(() => _currentIdx = index),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final question = questions[index];
              final selectedKey = _selectedKeys[index];
              final isSubmitted = _submittedKeys[index] != null;

              // Precompute a letter A-D correct key when possible to pass to AnswerCard.
              // If backend returns full option text, try to match it against options.
              final _normalizedCorrect = PracticeOptionParser.normalizeCorrectKey(
                question.correctAnswer,
                options: question.options,
              );
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

              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Progress indicator
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Câu ${index + 1}/${questions.length}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (index + 1) / questions.length,
                        backgroundColor: AppColors.primaryLighter,
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.primary,
                        ),
                        minHeight: 6,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Select header (golden) + image/prompt + reading-specific answer card
                    _SelectAnswerHeader(),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(
                            color: AppColors.shadow,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        question.prompt,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                          height: 1.6,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    ReadingAnswerCard(
                      options: List.generate(
                        question.options.length,
                        (oi) => AnswerOption(
                          key: String.fromCharCode(65 + oi),
                          text: question.options[oi],
                        ),
                      ),
                      selectedKey: selectedKey,
                      correctKey: isSubmitted ? _correctKeyToShow : null,
                      onSelect: (key) => _selectOption(index, key),
                    ),

                    // Explanations are not displayed during practice.
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomSheet: _buildBottomControls(),
    );
  }

  Widget _buildExplanation(ReadingPart5Question question) {
    final translationText = question.explanationVi ?? question.translation;
    final explanationText = question.explanation ?? question.grammarExplanation;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8F0),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Lời dịch (ưu tiên explanationVi, fallback sang translation)
          if (translationText != null && translationText.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lời dịch',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  translationText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ),
          // Lời giải (ưu tiên explanation, fallback sang grammarExplanation)
          if (explanationText != null && explanationText.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Lời giải',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  explanationText,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textPrimary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Consumer<ReadingPart5Provider>(
      builder: (context, provider, _) {
        final questions = provider.questions;
        if (questions.isEmpty) return const SizedBox.shrink();

        final question = questions[_currentIdx];
        final selectedKey = _selectedKeys[_currentIdx];
        final isSubmitted = _submittedKeys[_currentIdx] != null;
        final isLastQuestion = _currentIdx == questions.length - 1;
        final allSubmitted = _submittedKeys.length == questions.length;

        return Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(top: BorderSide(color: AppColors.divider)),
          ),
          child: SafeArea(
            top: false,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Câu ${_currentIdx + 1}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
                ElevatedButton(
                  onPressed: !isSubmitted && selectedKey != null
                      ? () => _submitAnswer(_currentIdx, question)
                      : (isLastQuestion && allSubmitted)
                          ? _finishQuiz
                          : (isSubmitted && !isLastQuestion)
                              ? () => _pageController.nextPage(
                                    duration: const Duration(milliseconds: 300),
                                    curve: Curves.easeInOut,
                                  )
                              : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    disabledBackgroundColor: AppColors.primaryLight,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    child: Text(
                      !isSubmitted
                          ? 'Xác nhận'
                          : isLastQuestion
                              ? 'Xem kết quả'
                              : 'Tiếp tục',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
