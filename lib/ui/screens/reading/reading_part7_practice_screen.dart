import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/practice/answer_card.dart';
import '../../../data/models/reading_part7_model.dart';
import '../../../providers/reading_part7_provider.dart';
import '../../../core/utils/practice_option_parser.dart';
import 'reading_part7_history_detail_screen.dart';

class ReadingPart7PracticeScreen extends StatefulWidget {
  final int passageCount;

  const ReadingPart7PracticeScreen({super.key, required this.passageCount});

  @override
  State<ReadingPart7PracticeScreen> createState() => _ReadingPart7PracticeScreenState();
}

class _ReadingPart7PracticeScreenState extends State<ReadingPart7PracticeScreen> {
  late PageController _pageController;
  int _currentIdx = 0;
  final _selectedKeys = <int, String?>{};
  final _submittedKeys = <int, String?>{};
  final _userAnswers = <String, String>{};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _currentIdx);
    WidgetsBinding.instance.addPostFrameCallback((_) { context.read<ReadingPart7Provider>().fetchQuestionsByPassageCount(widget.passageCount); });
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

  Future<void> _submitAnswer(int qIndex, ReadingPart7Question question) async {
    final provider = context.read<ReadingPart7Provider>();
    final selectedKey = _selectedKeys[qIndex];
    if (selectedKey == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vui lòng chọn một đáp án')));
      return;
    }

    final optIndex = selectedKey.codeUnitAt(0) - 65;
    final answers = <String, int?>{question.id: optIndex};

    try { await provider.submitAnswers(answers); } catch (e) { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi khi gửi đáp án: $e'))); } finally {
      _userAnswers[question.id] = selectedKey;
      setState(() { _submittedKeys[qIndex] = selectedKey; });
    }
  }

  Future<void> _finishQuiz() async {
    final provider = context.read<ReadingPart7Provider>();
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
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => ReadingPart7HistoryDetailScreen(historyItem: history)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi lưu lịch sử: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: 'Reading Part 7', centerTitle: true),
      body: Consumer<ReadingPart7Provider>(builder: (context, provider, child) {
        if (provider.isLoading && provider.questions.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }
        if (provider.errorMessage != null) {
          return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Lỗi: ${provider.errorMessage}', style: const TextStyle(color: Colors.red)), const SizedBox(height: 16), ElevatedButton(onPressed: () => provider.fetchQuestionsByPassageCount(widget.passageCount), child: const Text('Thử lại'))]));
        }

        final questions = provider.questions;
        if (questions.isEmpty) return const Center(child: Text('Không có câu hỏi nào'));

        return PageView.builder(controller: _pageController, onPageChanged: (index) => setState(() => _currentIdx = index), itemCount: questions.length, itemBuilder: (context, index) {
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

          return SingleChildScrollView(padding: const EdgeInsets.fromLTRB(16, 20, 16, 100), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Câu ${index + 1}/${questions.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.textSecondary))]),
            const SizedBox(height: 12),
            ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: (index + 1) / questions.length, backgroundColor: AppColors.primaryLighter, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary), minHeight: 6)),
            const SizedBox(height: 20),
            // Passage
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))]),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Đoạn văn', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                const SizedBox(height: 8),
                Text(question.passage, style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
                const SizedBox(height: 12),
                Text(question.prompt, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.6)),
              ]),
            ),
            const SizedBox(height: 16),
            // Options
            AnswerCardWrapper(options: question.options, selectedKey: selectedKey, correctKey: isSubmitted ? _correctKeyToShow : null, onSelect: (k) => _selectOption(index, k)),
            // Explanations (only shown in review/detail after submit)
            const SizedBox(height: 12),
            if (isSubmitted)
              Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: const Color(0xFFFFF8F0), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.primary.withOpacity(0.2))), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                if ((question.translation ?? '').isNotEmpty) ...[
                  const Text('Lời dịch', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Text(question.translation ?? '', style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
                  const SizedBox(height: 12),
                ],
                if ((question.grammarExplanation ?? '').isNotEmpty) ...[
                  const Text('Grammar', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Text(question.grammarExplanation ?? '', style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
                  const SizedBox(height: 12),
                ],
                if ((question.explanation ?? '').isNotEmpty) ...[
                  const Text('Lời giải', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 8),
                  Text(question.explanation ?? '', style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
                ],
                if ((question.optionExplanations ?? {}).isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Text('Giải thích các đáp án', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.primary)),
                  const SizedBox(height: 8),
                  ...question.optionExplanations!.entries.map((e) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text('${e.key}: ${e.value}', style: const TextStyle(fontSize: 13, color: AppColors.textPrimary)))),
                ],
              ])),
          ]));
        });
      }),
      bottomSheet: _buildBottomControls(),
    );
  }

  Widget _buildBottomControls() {
    return Consumer<ReadingPart7Provider>(builder: (context, provider, _) {
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

class AnswerCardWrapper extends StatelessWidget {
  const AnswerCardWrapper({required this.options, this.selectedKey, this.correctKey, this.onSelect});
  final List<String> options;
  final String? selectedKey;
  final String? correctKey;
  final ValueChanged<String>? onSelect;

  @override
  Widget build(BuildContext context) {
    return AnswerCard(
      options: List.generate(options.length, (oi) => AnswerOption(key: String.fromCharCode(65 + oi), text: options[oi])),
      selectedKey: selectedKey,
      correctKey: correctKey,
      onSelect: onSelect,
    );
  }
}
