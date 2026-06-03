import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../shared/practice_dialogs.dart';
import '../../../data/models/reading_part5_model.dart';
import '../../../core/utils/practice_option_parser.dart';

class ReadingPart5HistorySwipeScreen extends StatefulWidget {
  final ReadingPart5HistoryModel historyItem;
  final List<ReadingPart5Question> sessionQuestions;
  final int startIndex;

  const ReadingPart5HistorySwipeScreen({
    super.key,
    required this.historyItem,
    required this.sessionQuestions,
    required this.startIndex,
  });

  @override
  State<ReadingPart5HistorySwipeScreen> createState() =>
      _ReadingPart5HistorySwipeScreenState();
}

class _ReadingPart5HistorySwipeScreenState
    extends State<ReadingPart5HistorySwipeScreen> {
  late PageController _pageController;

  int _currentIdx = 0;
  bool _showExplanation = true; // Open by default

  @override
  void initState() {
    super.initState();
    _currentIdx = widget.startIndex;
    _pageController = PageController(initialPage: widget.startIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Widget _buildExplanationPanel() {
    final q = widget.sessionQuestions[_currentIdx];

    final explanation = q.explanation ?? q.grammarExplanation ?? 'Không có lời giải cho câu hỏi này.';
    final explanationVi = q.explanationVi ?? q.translation ?? 'Không có lời dịch cho câu hỏi này.';
    // debug prints
    // ignore: avoid_print
    print('ReadingPart5History.debug: grammarExplanation=${q.grammarExplanation}');
    // ignore: avoid_print
    print('ReadingPart5History.debug: grammarPoint=${q.grammarPoint}');
    // ignore: avoid_print
    print('ReadingPart5History.debug: optionExplanations=${q.optionExplanations}');

    // debug selected values
    // ignore: avoid_print
    print('ReadingPart5History.debug: using explanation="$explanation"');
    // ignore: avoid_print
    print('ReadingPart5History.debug: using explanationVi="$explanationVi"');

    // Return a fixed-height panel for bottomSheet (Positioned must be inside a Stack)
    return SizedBox(
      height: 420,
      child: _ExplanationPanel(
        explanation: explanation,
        explanationVi: explanationVi,
        onClose: () => setState(() => _showExplanation = false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.sessionQuestions.length;
    final q = widget.sessionQuestions[_currentIdx];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Câu ${_currentIdx + 1}',
        onBack: () => Navigator.pop(context),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.error_outline_rounded,
              color: AppColors.appBarFg,
              size: 22,
            ),
            onPressed: () => showReportDialog(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          // Settings icon inserted between report and favorite
          IconButton(
            icon: const Icon(
              Icons.settings_rounded,
              color: AppColors.appBarFg,
              size: 22,
            ),
            onPressed: () {
              // Open local settings dialog (reuse pattern from listening)
              showDialog(context: context, builder: (_) => _LocalSettingsDialogStub());
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(
              Icons.favorite_border_rounded,
              color: AppColors.appBarFg,
              size: 22,
            ),
            onPressed: () {},
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 4),
          AppBarTextAction(
            label: 'Giải thích',
            onTap: () {
              setState(() {
                _showExplanation = !_showExplanation;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Part 5',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${_currentIdx + 1}/$total',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (_currentIdx + 1) / total,
                backgroundColor: AppColors.primaryLighter,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.primary,
                ),
                minHeight: 6,
              ),
            ),
          ),

          // Content
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentIdx = index),
              itemCount: widget.sessionQuestions.length,
              itemBuilder: (context, index) {
                final question = widget.sessionQuestions[index];
                final selectedAns =
                    widget.historyItem.selectedAnswers[question.id];
                final correctAns = PracticeOptionParser.normalizeCorrectKey(
                  question.correctAnswer,
                  options: question.options,
                );
                final isCorrect = selectedAns != null && PracticeOptionParser.isSelectionCorrect(selectedAns, question.correctAnswer, question.options);

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 200),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Question prompt
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
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                            height: 1.6,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Answer options
                      Column(
                        children: List.generate(question.options.length, (oi) {
                          final optionKey = String.fromCharCode(65 + oi);
                          final isSelected = selectedAns == optionKey;
                          final isOptCorrect = PracticeOptionParser.isSelectionCorrect(optionKey, question.correctAnswer, question.options);

                          Color bgColor = Colors.white;
                          Color borderColor = AppColors.divider;
                          Color textColor = AppColors.textPrimary;

                          if (isOptCorrect) {
                            bgColor = AppColors.answerCorrect.withOpacity(0.12);
                            borderColor = AppColors.answerCorrect;
                          } else if (isSelected && !isOptCorrect) {
                            bgColor = AppColors.answerWrong.withOpacity(0.12);
                            borderColor = AppColors.answerWrong;
                          }

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: bgColor,
                              border: Border.all(
                                color: borderColor,
                                width: isSelected || isOptCorrect ? 2 : 1,
                              ),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: borderColor,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      optionKey,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Text(
                                    question.options[oi],
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: textColor,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ),

                      // Result indicator
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isCorrect
                              ? AppColors.answerCorrect.withOpacity(0.12)
                              : AppColors.answerWrong.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isCorrect
                                ? AppColors.answerCorrect
                                : AppColors.answerWrong,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              isCorrect
                                  ? Icons.check_circle
                                  : Icons.cancel_rounded,
                              color: isCorrect
                                  ? AppColors.answerCorrect
                                  : AppColors.answerWrong,
                              size: 20,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              isCorrect ? 'Đúng' : 'Sai',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: isCorrect
                                    ? AppColors.answerCorrect
                                    : AppColors.answerWrong,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomSheet: _showExplanation ? _buildExplanationPanel() : null,
    );
  }
}

/// Explanation panel widget
class _ExplanationPanel extends StatefulWidget {
  final String explanation;
  final String explanationVi;
  final VoidCallback onClose;

  const _ExplanationPanel({
    required this.explanation,
    required this.explanationVi,
    required this.onClose,
  });

  @override
  State<_ExplanationPanel> createState() => _ExplanationPanelState();
}

class _ExplanationPanelState extends State<_ExplanationPanel>
    with TickerProviderStateMixin {
  String _activeTab = 'Lời dịch'; // 'Lời dịch', 'Lời giải'

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
          // Header with tabs and centered settings icon style handled in appbar
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
          // White divider under the tabs
          const SizedBox(height: 8),
          Container(height: 1, color: Colors.white24),
          SizedBox(
            height: 250,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: _activeTab == 'Lời dịch'
                  ? Center(
                      child: Text(
                        widget.explanationVi,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.7,
                        ),
                      ),
                    )
                  : Center(
                      child: Text(
                        widget.explanation,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          height: 1.7,
                        ),
                      ),
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

// Small stub dialog to mimic listening local settings dialog used by the settings icon.
class _LocalSettingsDialogStub extends StatefulWidget {
  @override
  State<_LocalSettingsDialogStub> createState() => _LocalSettingsDialogStubState();
}

class _LocalSettingsDialogStubState extends State<_LocalSettingsDialogStub> {
  double _speed = 1.0;
  bool _autoPlay = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Cài đặt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(children: [const Text('Tốc độ: '), Expanded(child: Slider(value: _speed, min: 0.5, max: 2.0, divisions: 6, label: '${_speed}x', onChanged: (v) => setState(() => _speed = v)))]),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tự động hiển thị lời giải'), Switch(value: _autoPlay, onChanged: (v) => setState(() => _autoPlay = v))]),
          const SizedBox(height: 12),
          ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng')),
        ]),
      ),
    );
  }
}
