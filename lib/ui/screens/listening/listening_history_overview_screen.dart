import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/listening_history_model.dart';
import '../../../data/models/listening_question.dart';
import '../../../data/models/listening_data.dart';
import '../../../core/utils/practice_option_parser.dart';
import 'listening_history_swipe_screen.dart';

class ListeningHistoryOverviewScreen extends StatefulWidget {
  final ListeningHistoryModel historyItem;
  final List<ListeningQuestion> sessionQuestions;
  final Map<String, ListeningGroup> questionGroups;

  const ListeningHistoryOverviewScreen({
    super.key,
    required this.historyItem,
    required this.sessionQuestions,
    required this.questionGroups,
  });

  @override
  State<ListeningHistoryOverviewScreen> createState() =>
      _ListeningHistoryOverviewScreenState();
}

class _ListeningHistoryOverviewScreenState
    extends State<ListeningHistoryOverviewScreen> {
  String _activeFilter = 'Tất cả'; // 'Tất cả', 'Chọn đúng', 'Chọn sai'

  @override
  void initState() {
    super.initState();
  }

  String get _partTitle {
    try {
      final partInfo = ListeningData.parts.firstWhere(
        (p) => p.partNumber == widget.historyItem.part,
      );
      return 'Part ${partInfo.partNumber}: ${partInfo.titleVi}';
    } catch (_) {
      return 'Part ${widget.historyItem.part}';
    }
  }

  List<ListeningQuestion> get _filteredQuestions {
    return widget.sessionQuestions.where((q) {
      final selectedAns = widget.historyItem.selectedAnswers[q.id];
      final correctAns = PracticeOptionParser.normalizeCorrectKey(
        q.correctAnswer,
        options: q.options,
      );
      final isCorrect = selectedAns == correctAns;

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
            // --- HEADER ---
            Container(
              color: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox(width: 32), // Spacer to balance close button
                  const Text(
                    'Tổng quan',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),

            // --- FILTER PILLS ---
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

            // --- QUESTION LIST ---
            Expanded(
              child: filteredList.isEmpty
                  ? Center(
                      child: Text(
                        'Không có câu hỏi nào khớp với bộ lọc.',
                        style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8)),
                      ),
                    )
                  : ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      children: [
                        // Part header label
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12, top: 4),
                          child: Text(
                            _partTitle,
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

            // --- BOTTOM TELEPROMPTER BAR ---
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

  Widget _buildQuestionRow(ListeningQuestion q, int originalIdx) {
    final selectedAns = widget.historyItem.selectedAnswers[q.id];

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ListeningHistorySwipeScreen(
              historyItem: widget.historyItem,
              sessionQuestions: widget.sessionQuestions,
              questionGroups: widget.questionGroups,
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

  Widget _buildChoiceCircles(ListeningQuestion q, String? selectedAns) {
    final correctAns = PracticeOptionParser.normalizeCorrectKey(
      q.correctAnswer,
      options: q.options,
    );
    final totalOptions = q.options.length; // 3 or 4

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalOptions, (idx) {
        final optionKey = String.fromCharCode(65 + idx); // A, B, C, D
        final displayNum = '${idx + 1}'; // 1, 2, 3, 4

        final isSelected = selectedAns == optionKey;
        final isCorrect = correctAns == optionKey;

        Color bgColor = Colors.white;
        Color textColor = AppColors.textPrimary;
        Color borderColor = AppColors.divider;

        if (isCorrect) {
          bgColor = AppColors.green;
          textColor = Colors.white;
          borderColor = AppColors.green;
        } else if (isSelected) {
          bgColor = Colors.red;
          textColor = Colors.white;
          borderColor = Colors.red;
        }

        return Container(
          width: 32,
          height: 32,
          margin: const EdgeInsets.only(left: 10),
          decoration: BoxDecoration(
            color: bgColor,
            shape: BoxShape.circle,
            border: Border.all(color: borderColor, width: 1.5),
          ),
          child: Center(
            child: Text(
              displayNum,
              style: TextStyle(
                color: textColor,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }),
    );
  }
}
