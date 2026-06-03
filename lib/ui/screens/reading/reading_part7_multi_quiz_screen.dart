import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../data/models/reading_part7_model.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/common/practice_result_view.dart';
import 'reading_part7_quiz_screen.dart';

class ReadingPart7MultiQuizScreen extends StatefulWidget {
  final List<ReadingPart7Passage> passages;

  const ReadingPart7MultiQuizScreen({super.key, required this.passages});

  @override
  State<ReadingPart7MultiQuizScreen> createState() => _ReadingPart7MultiQuizScreenState();
}

class _ReadingPart7MultiQuizScreenState extends State<ReadingPart7MultiQuizScreen> {
  int _current = 0;
  int _totalScore = 0;
  int _totalQuestions = 0;
  bool _running = false;

  @override
  void initState() {
    super.initState();
    _totalQuestions = widget.passages.fold(0, (p, e) => p + e.questions.length);
    WidgetsBinding.instance.addPostFrameCallback((_) => _startSequential());
  }

  Future<void> _startSequential() async {
    if (_running) return;
    setState(() => _running = true);

    for (var i = _current; i < widget.passages.length; i++) {
      final passage = widget.passages[i];
      final result = await Navigator.of(context).push<Map>(MaterialPageRoute(
        builder: (_) => ReadingPart7QuizScreen(passage: passage, startIndex: 0, showResultOnFinish: false, returnResultMap: true),
      ));

      if (result == null || !result.containsKey('score') || !result.containsKey('total')) {
        setState(() => _running = false);
        Navigator.of(context).pop({'score': _totalScore, 'total': _totalQuestions});
        return;
      }

      final s = (result['score'] as int?) ?? 0;
      _totalScore += s;
      _current = i + 1;
    }

    setState(() => _running = false);

    final resultView = Scaffold(
      backgroundColor: AppColors.background,
      body: PracticeResultView(
        score: _totalScore,
        total: _totalQuestions,
        onRetry: () {
          Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => ReadingPart7MultiQuizScreen(passages: widget.passages)));
        },
        onBack: () => Navigator.of(context).pop(),
      ),
    );

    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => resultView));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Part 7 - Nhiều đoạn', centerTitle: true),
      backgroundColor: AppColors.background,
      body: Center(
        child: _running
            ? Column(mainAxisSize: MainAxisSize.min, children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text('Đang chuyển sang đoạn ${_current + 1} / ${widget.passages.length}', style: const TextStyle(fontWeight: FontWeight.w600)),
              ])
            : ElevatedButton(
                onPressed: () {
                  _current = 0;
                  _totalScore = 0;
                  _startSequential();
                },
                child: const Text('Bắt đầu lại'),
              ),
      ),
    );
  }
}

