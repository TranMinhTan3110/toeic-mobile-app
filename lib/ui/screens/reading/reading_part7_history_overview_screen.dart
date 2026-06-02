import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/reading_part7_model.dart';
import '../../../core/utils/practice_option_parser.dart';

class ReadingPart7HistoryOverviewScreen extends StatelessWidget {
  final ReadingPart7HistoryModel historyItem;
  final List<ReadingPart7Question> sessionQuestions;

  const ReadingPart7HistoryOverviewScreen({super.key, required this.historyItem, required this.sessionQuestions});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Tổng quan'), backgroundColor: AppColors.primary, centerTitle: true),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: sessionQuestions.length,
        itemBuilder: (context, idx) {
          final q = sessionQuestions[idx];
          final selected = historyItem.selectedAnswers[q.id];
          final isCorrect = selected != null && PracticeOptionParser.isSelectionCorrect(selected, q.correctAnswer, q.options);

          return InkWell(
            onTap: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: Text('Câu ${idx + 1}'),
                  content: SingleChildScrollView(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(q.prompt), const SizedBox(height: 12), ...List.generate(q.options.length, (i) { final key = String.fromCharCode(65 + i); final isSel = selected == key; final isCorr = PracticeOptionParser.isSelectionCorrect(key, q.correctAnswer, q.options); return ListTile(leading: CircleAvatar(child: Text('${i + 1}')), title: Text(q.options[i]), trailing: isCorr ? const Icon(Icons.check_circle, color: AppColors.green) : (isSel ? const Icon(Icons.cancel, color: Colors.red) : null)); }), if ((q.explanation ?? '').isNotEmpty) ...[const SizedBox(height: 12), const Text('Giải thích', style: TextStyle(fontWeight: FontWeight.bold)), Text(q.explanation!)], ])),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Đóng'))],
                ),
              );
            },
            child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.divider))), child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Câu ${idx + 1}', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)), Row(children: [if (isCorrect) const Icon(Icons.check_circle, color: AppColors.green) else const SizedBox.shrink(), const SizedBox(width: 8), Text(isCorrect ? 'Đúng' : 'Sai', style: TextStyle(color: isCorrect ? AppColors.green : Colors.red))])]),
            ),
          );
        },
      ),
    );
  }
}
