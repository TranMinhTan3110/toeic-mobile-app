import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../shared/practice_dialogs.dart';
import '../../../data/models/reading_part7_model.dart';
import '../../../core/utils/practice_option_parser.dart';

class ReadingPart7HistorySwipeScreen extends StatefulWidget {
  final ReadingPart7HistoryModel historyItem;
  final List<ReadingPart7Question> sessionQuestions;
  final int startIndex;

  const ReadingPart7HistorySwipeScreen({super.key, required this.historyItem, required this.sessionQuestions, required this.startIndex});

  @override
  State<ReadingPart7HistorySwipeScreen> createState() => _ReadingPart7HistorySwipeScreenState();
}

class _ReadingPart7HistorySwipeScreenState extends State<ReadingPart7HistorySwipeScreen> {
  late PageController _pageController;
  int _currentIdx = 0;
  bool _showExplanation = true;

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
    final answerVi = q.explanationVi ?? q.translation ?? q.explanation ?? 'Không có lời giải cho câu hỏi này.';
    final passageVi = q.passageTranslationVi ?? q.translation ?? 'Không có lời dịch cho đoạn văn.';
    return SizedBox(
      height: 420,
      child: _ExplanationPanel(
        passageVi: passageVi.isNotEmpty ? passageVi : 'Không có lời dịch cho đoạn văn.',
        answerVi: answerVi.isNotEmpty ? answerVi : 'Không có lời giải cho câu hỏi này.',
        onClose: () => setState(() => _showExplanation = false),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.sessionQuestions.length;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: 'Câu ${_currentIdx + 1}',
        onBack: () => Navigator.pop(context),
        actions: [
          IconButton(icon: const Icon(Icons.error_outline_rounded, color: AppColors.appBarFg, size: 22), onPressed: () => showReportDialog(context), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          const SizedBox(width: 4),
          IconButton(icon: const Icon(Icons.settings_rounded, color: AppColors.appBarFg, size: 22), onPressed: () => showDialog(context: context, builder: (_) => _LocalSettingsDialogStub()), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          const SizedBox(width: 4),
          IconButton(icon: const Icon(Icons.favorite_border_rounded, color: AppColors.appBarFg, size: 22), onPressed: () {}, padding: EdgeInsets.zero, constraints: const BoxConstraints()),
          const SizedBox(width: 4),
          AppBarTextAction(label: 'Giải thích', onTap: () => setState(() => _showExplanation = !_showExplanation)),
        ],
      ),
      body: Column(
        children: [
          Padding(padding: const EdgeInsets.fromLTRB(16, 16, 16, 0), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Part 7', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.primary)), Text('${_currentIdx + 1}/$total', style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textSecondary))])),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: ClipRRect(borderRadius: BorderRadius.circular(4), child: LinearProgressIndicator(value: (_currentIdx + 1) / total, backgroundColor: AppColors.primaryLighter, valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary), minHeight: 6))),
          const SizedBox(height: 12),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              onPageChanged: (index) => setState(() => _currentIdx = index),
              itemCount: widget.sessionQuestions.length,
              itemBuilder: (context, index) {
                final question = widget.sessionQuestions[index];
                final selectedAns = widget.historyItem.selectedAnswers[question.id];
                final isCorrect = selectedAns != null && PracticeOptionParser.isSelectionCorrect(selectedAns, question.correctAnswer, question.options);

                return SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 200),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    if ((question.passage ?? '').isNotEmpty)
                      Container(width: double.infinity, padding: const EdgeInsets.all(16), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), boxShadow: const [BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, 2))]), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Đoạn văn', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
                        const SizedBox(height: 8),
                        Text(question.passage ?? '', style: const TextStyle(fontSize: 14, color: AppColors.textPrimary, height: 1.6)),
                        const SizedBox(height: 12),
                        Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(8)), child: Text(question.prompt ?? '', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppColors.textPrimary, height: 1.6))),
                      ])),
                    if ((question.passage ?? '').isNotEmpty)
                      const SizedBox(height: 20),
                    Column(children: List.generate(question.options.length, (oi) {
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
                        decoration: BoxDecoration(color: bgColor, border: Border.all(color: borderColor, width: isSelected || isOptCorrect ? 2 : 1), borderRadius: BorderRadius.circular(10)),
                        child: Row(children: [
                          Container(width: 32, height: 32, decoration: BoxDecoration(color: borderColor, shape: BoxShape.circle), child: Center(child: Text(optionKey, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14)))),
                          const SizedBox(width: 14),
                          Expanded(child: Text(question.options[oi], style: TextStyle(fontSize: 14, color: textColor, height: 1.4))),
                        ]),
                      );
                    })),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: isCorrect ? AppColors.answerCorrect.withOpacity(0.12) : AppColors.answerWrong.withOpacity(0.12), borderRadius: BorderRadius.circular(8), border: Border.all(color: isCorrect ? AppColors.answerCorrect : AppColors.answerWrong)),
                      child: Row(children: [Icon(isCorrect ? Icons.check_circle : Icons.cancel_rounded, color: isCorrect ? AppColors.answerCorrect : AppColors.answerWrong, size: 20), const SizedBox(width: 10), Text(isCorrect ? 'Đúng' : 'Sai', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isCorrect ? AppColors.answerCorrect : AppColors.answerWrong)), ]),
                    ),
                  ]),
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
                    child: const Icon(Icons.close_rounded,
                        color: Colors.white, size: 18),
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

class _LocalSettingsDialogStub extends StatefulWidget {
  @override
  State<_LocalSettingsDialogStub> createState() => _LocalSettingsDialogStubState();
}

class _LocalSettingsDialogStubState extends State<_LocalSettingsDialogStub> {
  double _speed = 1.0;
  bool _autoPlay = false;

  @override
  Widget build(BuildContext context) {
    return Dialog(shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)), child: Padding(padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [const Text('Cài đặt', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)), const SizedBox(height: 12), Row(children: [const Text('Tốc độ: '), Expanded(child: Slider(value: _speed, min: 0.5, max: 2.0, divisions: 6, label: '${_speed}x', onChanged: (v) => setState(() => _speed = v)))]), Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const Text('Tự động hiển thị lời giải'), Switch(value: _autoPlay, onChanged: (v) => setState(() => _autoPlay = v))]), const SizedBox(height: 12), ElevatedButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))]),),);
  }
}
