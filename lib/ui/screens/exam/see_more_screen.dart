import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/test_info.dart';
import '../../../providers/exam_provider.dart';
import '../../widgets/common/custom_app_bar.dart';
import '../../widgets/test/test_card.dart';
import 'test_detail_screen.dart';

class SeeMoreScreen extends StatelessWidget {
  final String title;
  final List<TestInfo> tests;
  final ExamProvider? examProvider;

  const SeeMoreScreen({
    super.key,
    required this.title,
    required this.tests,
    this.examProvider,
  });

  bool _isSameExam(String id1, String id2) {
    if (id1.toLowerCase() == id2.toLowerCase()) return true;
    String normalize(String id) {
      id = id.toLowerCase();
      if (id.startsWith('test_')) {
        final num = int.tryParse(id.substring(5));
        if (num != null) return num.toString();
      }
      if (id.startsWith('ets-spk-2024-')) {
        final num = int.tryParse(id.substring(13));
        if (num != null) return num.toString();
      }
      if (id.startsWith('ets-wrt-2024-')) {
        final num = int.tryParse(id.substring(13));
        if (num != null) return num.toString();
      }
      if (id.startsWith('ets_2024_test_')) {
        final num = int.tryParse(id.substring(14));
        if (num != null) return num.toString();
      }
      return id;
    }
    return normalize(id1) == normalize(id2);
  }

  @override
  Widget build(BuildContext context) {
    final provider = examProvider ?? context.watch<ExamProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(title: title),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 12),
        itemCount: tests.length,
        itemBuilder: (context, index) {
          final test = tests[index];

          // Xác định status và score dựa vào skill
          TestStatus status = TestStatus.notStarted;
          int? score;

          if (test.skill == 'speaking') {
            final matches = provider.speakingExamHistories
                .where((h) => _isSameExam(h.examSetId, test.id))
                .toList();
            if (matches.isNotEmpty) {
              matches.sort((a, b) => b.date.compareTo(a.date));
              status = TestStatus.completed;
              score = matches.first.toeicScore.round();
            }
          } else if (test.skill == 'writing') {
            final matches = provider.writingExamHistories
                .where((h) => _isSameExam(h.examSetId, test.id))
                .toList();
            if (matches.isNotEmpty) {
              matches.sort((a, b) => b.date.compareTo(a.date));
              status = TestStatus.completed;
              score = matches.first.toeicScore.round();
            }
          } else {
            final matches = provider.fullTestHistories
                .where((h) => _isSameExam(h.examId, test.id))
                .toList();
            if (matches.isNotEmpty) {
              matches.sort((a, b) => b.completedAt.compareTo(a.completedAt));
              status = TestStatus.completed;
              score = matches.first.totalScore;
            }
          }

          final durationStr = test.duration != null ? '${test.duration} phút' : null;

          return TestCard(
            testName: test.title,
            duration: durationStr,
            questionCount: test.questionCount,

            status: status,
            score: score,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TestDetailScreen(testData: test),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
