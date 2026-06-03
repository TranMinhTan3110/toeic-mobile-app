import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/reading_part5_model.dart';
import '../../../core/utils/practice_option_parser.dart';
import 'reading_part5_history_swipe_screen.dart';

class ReadingPart5HistoryOverviewScreen extends StatefulWidget {
  final ReadingPart5HistoryModel historyItem;
  final List<ReadingPart5Question> sessionQuestions;

  const ReadingPart5HistoryOverviewScreen({super.key, required this.historyItem, required this.sessionQuestions});

  @override
  State<ReadingPart5HistoryOverviewScreen> createState() => _ReadingPart5HistoryOverviewScreenState();
}

class _ReadingPart5HistoryOverviewScreenState extends State<ReadingPart5HistoryOverviewScreen> {
  String _activeFilter = 'Tất cả';

  List<ReadingPart5Question> get _filteredQuestions {
    return widget.sessionQuestions.where((q) {
      final selectedAns = widget.historyItem.selectedAnswers[q.id];
      final isCorrect = selectedAns != null && PracticeOptionParser.isSelectionCorrect(selectedAns, q.correctAnswer, q.options);

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
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [const SizedBox(width: 32), const Text('Tổng quan', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)), IconButton(icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero, constraints: const BoxConstraints())]),
            ),

            // --- FILTER PILLS ---
            Padding(padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16), child: Row(children: [_buildFilterPill('Tất cả'), const SizedBox(width: 10), _buildFilterPill('Chọn đúng'), const SizedBox(width: 10), _buildFilterPill('Chọn sai')]),),

            // --- QUESTION LIST ---
            Expanded(child: filteredList.isEmpty ? Center(child: Text('Không có câu hỏi nào khớp với bộ lọc.', style: TextStyle(color: AppColors.textSecondary.withOpacity(0.8)))) : ListView(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), children: [Padding(padding: const EdgeInsets.only(bottom: 12, top: 4), child: Text('Reading Part 5: Điền Vào Câu', style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15),),), ...List.generate(filteredList.length, (idx) { final q = filteredList[idx]; final actualIdx = widget.sessionQuestions.indexOf(q); return _buildQuestionRow(q, actualIdx);} ), ],),),

            // --- BOTTOM TELEPROMPTER BAR ---
            Container(width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 14), color: AppColors.primary, child: const Text('Ấn vào từng câu để xem giải thích chi tiết', textAlign: TextAlign.center, style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600, letterSpacing: 0.2),),),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterPill(String title) {
    final isActive = _activeFilter == title;
    return GestureDetector(onTap: () => setState(() => _activeFilter = title), child: Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), decoration: BoxDecoration(color: isActive ? Colors.grey[200] : Colors.grey[100], borderRadius: BorderRadius.circular(20), border: isActive ? Border.all(color: Colors.grey[400]!, width: 1) : Border.all(color: Colors.transparent)), child: Text(title, style: TextStyle(color: isActive ? AppColors.textPrimary : AppColors.textSecondary, fontWeight: isActive ? FontWeight.bold : FontWeight.w500, fontSize: 13.5),),),);
  }

  Widget _buildQuestionRow(ReadingPart5Question q, int originalIdx) {
    final selectedAns = widget.historyItem.selectedAnswers[q.id];

    return InkWell(onTap: () { Navigator.push(context, MaterialPageRoute(builder: (_) => ReadingPart5HistorySwipeScreen(historyItem: widget.historyItem, sessionQuestions: widget.sessionQuestions, startIndex: originalIdx, ), ), ); }, child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider)),), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Câu ${originalIdx + 1}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),), _buildChoiceCircles(q, selectedAns),],),),);
  }

  Widget _buildChoiceCircles(ReadingPart5Question q, String? selectedAns) {
    final correctAns = PracticeOptionParser.normalizeCorrectKey(q.correctAnswer, options: q.options,);
    final totalOptions = q.options.length;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(totalOptions, (idx) {
        final optionKey = String.fromCharCode(65 + idx);
        final displayNum = '${idx + 1}';
        final isSelected = selectedAns == optionKey;
        final isCorrect = PracticeOptionParser.isSelectionCorrect(optionKey, q.correctAnswer, q.options);

        Color bgColor = Colors.white;
        Color textColor = AppColors.textPrimary;
        Color borderColor = AppColors.divider;

        if (isCorrect) {
          bgColor = AppColors.success.withOpacity(0.18);
          textColor = Colors.white;
          borderColor = AppColors.success;
        } else if (isSelected && !isCorrect) {
          bgColor = AppColors.error.withOpacity(0.18);
          textColor = Colors.white;
          borderColor = AppColors.error;
        }

        return Container(
          margin: const EdgeInsets.only(left: 10),
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: bgColor,
            border: Border.all(color: borderColor, width: isSelected || isCorrect ? 2.5 : 1.6),
            shape: BoxShape.circle,
            boxShadow: isSelected || isCorrect
                ? [BoxShadow(color: borderColor.withOpacity(0.22), blurRadius: 8, offset: const Offset(0, 3))]
                : null,
          ),
          child: Center(
            child: Text(
              displayNum,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: textColor),
            ),
          ),
        );
      }),
    );
  }
}
