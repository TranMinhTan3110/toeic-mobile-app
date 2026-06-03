import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/reading_part6_model.dart';
import '../../../core/utils/practice_option_parser.dart';
import 'reading_part6_history_swipe_screen.dart';

class ReadingPart6HistoryOverviewScreen extends StatefulWidget {
  final ReadingPart6HistoryModel historyItem;
  final List<ReadingPart6Question> sessionQuestions;

  const ReadingPart6HistoryOverviewScreen({
    super.key,
    required this.historyItem,
    required this.sessionQuestions,
  });

  @override
  State<ReadingPart6HistoryOverviewScreen> createState() =>
      _ReadingPart6HistoryOverviewScreenState();
}

class _ReadingPart6HistoryOverviewScreenState
    extends State<ReadingPart6HistoryOverviewScreen> {
  String _activeFilter = 'Tất cả';

  List<ReadingPart6Question> get _filteredQuestions {
    return widget.sessionQuestions.where((q) {
      final selectedAns = widget.historyItem.selectedAnswers[q.id];
      final isCorrect =
          selectedAns != null &&
          PracticeOptionParser.isSelectionCorrect(
            selectedAns,
            q.correctAnswer,
            q.options,
          );

      if (_activeFilter == 'Chọn đúng') return isCorrect;
      if (_activeFilter == 'Chọn sai') return !isCorrect;
      return true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredQuestions;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32),
                  const Text(
                    'Tổng quan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // FILTER PILLS
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  _buildFilterPill('Tất cả'),
                  const SizedBox(width: 10),
                  _buildFilterPill('Chọn đúng'),
                  const SizedBox(width: 10),
                  _buildFilterPill('Chọn sai'),
                ],
              ),
            ),

            // QUESTION LIST
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Text(
                        'Không có câu hỏi nào khớp với bộ lọc.',
                        style: TextStyle(
                          color: AppColors.textSecondary.withOpacity(0.8),
                        ),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      children: [
                        // Header label
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, top: 4),
                          child: Text(
                            'Reading Part 6: Điền Trắc Nghiệm',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                        // Rows
                        ...List.generate(filteredList.length, (idx) {
                          final q = filteredList[idx];
                          final actualIdx = widget.sessionQuestions.indexOf(q);
                          return _buildQuestionRow(q, actualIdx);
                        }),
                      ],
                    ),
            ),

            // BOTTOM BAR
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 14),
              color: AppColors.primary,
              child: const Text(
                'Ấn vào từng câu để xem giải thích chi tiết',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String title) {
    final isActive = _activeFilter == title;
    return GestureDetector(
      onTap: () => setState(() => _activeFilter = title),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? Colors.grey[200] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: isActive
              ? Border.all(color: Colors.grey[400]!, width: 1)
              : Border.all(color: Colors.transparent),
        ),
        child: Text(
          title,
          style: TextStyle(
            color: isActive ? AppColors.textPrimary : AppColors.textSecondary,
            fontWeight: isActive ? FontWeight.bold : FontWeight.w500,
            fontSize: 13.5,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionRow(ReadingPart6Question q, int originalIdx) {
    final selectedAns = widget.historyItem.selectedAnswers[q.id];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ReadingPart6HistorySwipeScreen(
              historyItem: widget.historyItem,
              sessionQuestions: widget.sessionQuestions,
              startIndex: originalIdx,
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: const BoxDecoration(
          border: Border(bottom: BorderSide(color: AppColors.divider)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Câu ${originalIdx + 1}',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            _buildChoiceCircles(q, selectedAns),
          ],
        ),
      ),
    );
  }

  Widget _buildChoiceCircles(ReadingPart6Question q, String? selectedAns) {
    final correctAns = PracticeOptionParser.normalizeCorrectKey(
      q.correctAnswer,
      options: q.options,
    );
    final totalOptions = q.options.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalOptions, (idx) {
        final optionKey = String.fromCharCode(65 + idx);
        final displayNum = '${idx + 1}';

        final isSelected = selectedAns == optionKey;
        final isCorrect = PracticeOptionParser.isSelectionCorrect(
          optionKey,
          q.correctAnswer,
          q.options,
        );

        Color bgColor = Colors.white;
        Color textColor = AppColors.textPrimary;
        Color borderColor = AppColors.divider;

        if (isCorrect) {
          bgColor = AppColors.answerCorrect;
          textColor = Colors.white;
          borderColor = AppColors.answerCorrect;
        } else if (isSelected && !isCorrect) {
          bgColor = AppColors.answerWrong;
          textColor = Colors.white;
          borderColor = AppColors.answerWrong;
        }

        return Container(
          margin: const EdgeInsets.only(left: 8),
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: 1.5),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              displayNum,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
          ),
        );
      }),
    );
  }

  void _showExplanationDialog(
    BuildContext context,
    ReadingPart6Question question,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _ExplanationBottomSheet(question: question),
    );
  }
}

class _ExplanationBottomSheet extends StatefulWidget {
  final ReadingPart6Question question;

  const _ExplanationBottomSheet({required this.question});

  @override
  State<_ExplanationBottomSheet> createState() =>
      _ExplanationBottomSheetState();
}

class _ExplanationBottomSheetState extends State<_ExplanationBottomSheet>
    with SingleTickerProviderStateMixin {
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
    final q = widget.question;
    final script = q.passage;
    final passageVi =
        q.passageTranslationVi ?? 'Không có lời dịch cho đoạn văn.';
    final explanation =
        q.explanationVi ??
        q.explanation ??
        q.grammarExplanation ??
        'Không có lời giải cho câu hỏi này.';

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
                      Tab(text: 'Đoạn văn'),
                      Tab(text: 'Lời dịch'),
                      Tab(text: 'Lời giải'),
                    ],
                  ),
                ),
                Container(
                  width: 36,
                  height: 36,
                  margin: const EdgeInsets.only(left: 8, right: 8),
                  decoration: const BoxDecoration(
                    color: Colors.white30,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.settings_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
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
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    script,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    passageVi,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                ),
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    explanation,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      height: 1.7,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
