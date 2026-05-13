import 'dart:math';
import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/reading_part6_model.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/practice_result_view.dart';
import 'reading_part6_quiz_screen.dart';

class ReadingPart6MultiQuizScreen extends StatefulWidget {
  final List<ReadingPart6Passage> passages;

  const ReadingPart6MultiQuizScreen({super.key, required this.passages});

  @override
  State<ReadingPart6MultiQuizScreen> createState() => _ReadingPart6MultiQuizScreenState();
}

class _ReadingPart6MultiQuizScreenState extends State<ReadingPart6MultiQuizScreen> {
  int _current = 0;
  int _totalScore = 0;

  Future<void> _startAll() async {
    for (var i = 0; i < widget.passages.length; i++) {
      final p = widget.passages[i];
      final res = await Navigator.of(context).push(MaterialPageRoute(builder: (_) => ReadingPart6QuizScreen(passage: p, showResultOnFinish: false)));
      if (res is Map && res['score'] != null) {
        _totalScore += (res['score'] as int);
      }
      setState(() => _current = i + 1);
    }

    // all done - show combined result
    final totalQuestions = widget.passages.fold<int>(0, (s, p) => s + p.questions.length);
    final resultView = Scaffold(
      backgroundColor: AppColors.background,
      body: PracticeResultView(
        score: _totalScore,
        total: totalQuestions,
        onRetry: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ReadingPart6MultiQuizScreen(passages: widget.passages)));
        },
        onBack: () => Navigator.of(context).pop(),
      ),
    );

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => resultView));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Làm 4 đoạn - Part 6', centerTitle: true),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Bạn sẽ làm ${widget.passages.length} đoạn, mỗi đoạn ${widget.passages.isNotEmpty ? widget.passages.first.questions.length : 0} câu', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.separated(
              itemCount: widget.passages.length,
              separatorBuilder: (_, __) => const Divider(),
              itemBuilder: (context, idx) {
                final p = widget.passages[idx];
                return ListTile(
                  title: Text('Đoạn ${idx + 1}'),
                  subtitle: Text(p.passage, maxLines: 3, overflow: TextOverflow.ellipsis),
                  trailing: Text('${p.questions.length} câu'),
                );
              },
            ),
          ),
          SafeArea(
            top: false,
            child: SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startAll,
                style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Bắt đầu làm 4 đoạn', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white))),
              ),
            ),
          )
        ]),
      ),
    );
  }
}
