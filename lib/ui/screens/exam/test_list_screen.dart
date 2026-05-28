import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/test_info.dart';
import '../../../data/models/speaking_exam_history_model.dart';
import '../../../data/models/writing_exam_history_model.dart';
import '../../../providers/exam_provider.dart';
import '../../widgets/cards/test_card_widget.dart';
import 'test_detail_screen.dart';
import 'see_more_screen.dart';
import '../../widgets/common/custom_app_bar.dart';

class TestListScreen extends StatefulWidget {
  const TestListScreen({super.key});

  @override
  State<TestListScreen> createState() => _TestListScreenState();
}

class _TestListScreenState extends State<TestListScreen> {
  @override
  void initState() {
    super.initState();
    // Load histories in background to display score badges
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final examProvider = context.read<ExamProvider>();
      examProvider.fetchSpeakingExamHistory();
      examProvider.fetchWritingExamHistory();
    });
  }

  List<TestInfo> _generateMockTests(String prefix) {
    return List.generate(
      8,
      (index) {
        int testNumber = index + 1;
        return TestInfo(
          id: 'ets_2024_test_$testNumber',
          title: 'Test $testNumber $prefix',
          skill: 'listening',
        );
      },
    );
  }

  List<TestInfo> _generateSpeakingTests() {
    return [
      TestInfo(id: 'test_6', title: 'Test 1', duration: 20, questionCount: 11, skill: 'speaking'),
      TestInfo(id: 'test_7', title: 'Test 2', duration: 20, questionCount: 11, skill: 'speaking'),
      TestInfo(id: 'test_8', title: 'Test 3', duration: 20, questionCount: 11, skill: 'speaking'),
      TestInfo(id: 'test_9', title: 'Test 4', duration: 20, questionCount: 11, skill: 'speaking'),
      TestInfo(id: 'test_10', title: 'Test 5', duration: 20, questionCount: 11, skill: 'speaking'),
    ];
  }

  List<TestInfo> _generateWritingTests() {
    return [
      TestInfo(id: 'test_6', title: 'Test 1', duration: 60, questionCount: 8, skill: 'writing'),
      TestInfo(id: 'test_7', title: 'Test 2', duration: 60, questionCount: 8, skill: 'writing'),
    ];
  }

  bool _isSameExam(String id1, String id2) {
    if (id1.toLowerCase() == id2.toLowerCase()) return true;
    
    String normalize(String id) {
      id = id.toLowerCase();
      if (id.startsWith('test_')) {
        final num = int.tryParse(id.substring(5));
        if (num != null) return num.toString();
      }
      if (id.startsWith('ets-wrt-2024-')) {
        final num = int.tryParse(id.substring(13));
        if (num != null) return num.toString();
      }
      if (id.startsWith('ets-spk-2024-')) {
        final num = int.tryParse(id.substring(13));
        if (num != null) return num.toString();
      }
      return id;
    }
    
    return normalize(id1) == normalize(id2);
  }

  double? _getLatestSpeakingScore(String examId, List<SpeakingExamHistoryModel> histories) {
    final matches = histories.where((h) => _isSameExam(h.examSetId, examId)).toList();
    if (matches.isEmpty) return null;
    matches.sort((a, b) => b.date.compareTo(a.date));
    return matches.first.toeicScore;
  }

  double? _getLatestWritingScore(String examId, List<WritingExamHistoryModel> histories) {
    final matches = histories.where((h) => _isSameExam(h.examSetId, examId)).toList();
    if (matches.isEmpty) return null;
    matches.sort((a, b) => b.date.compareTo(a.date));
    return matches.first.toeicScore;
  }


  @override
  Widget build(BuildContext context) {
    final listReading = _generateMockTests('ETS 2024');
    final listSpeaking = _generateSpeakingTests();
    final listWriting = _generateWritingTests();
    final examProvider = context.watch<ExamProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const CustomAppBar(
        title: 'Thi thử',
        centerTitle: true,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CỤM 1: L&R
              _buildSectionHeader(
                context,
                'TOEIC Listening & Reading Fulltest',
              ),
              const SizedBox(height: 16),
              _buildTestGrid(context, listReading, examProvider),

              const SizedBox(height: 32),

              // CỤM 2: Speaking
              _buildSectionHeader(
                context,
                'TOEIC Speaking Exam',
              ),
              const SizedBox(height: 16),
              _buildTestGrid(context, listSpeaking, examProvider),

              const SizedBox(height: 32),

              // CỤM 3: Writing
              _buildSectionHeader(context, 'TOEIC Writing Exam'),
              const SizedBox(height: 16),
              _buildTestGrid(context, listWriting, examProvider),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => SeeMoreScreen(title: title),
              ),
            );
          },
          child: const Text(
            'Xem thêm',
            style: TextStyle(
              color: AppColors.textLink,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestGrid(BuildContext context, List<TestInfo> tests, ExamProvider examProvider) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tests.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 16,
        childAspectRatio: 0.58,
      ),
      itemBuilder: (context, index) {
        final test = tests[index];
        double? score;

        if (test.skill == 'speaking') {
          score = _getLatestSpeakingScore(test.id, examProvider.speakingExamHistories);
        } else if (test.skill == 'writing') {
          score = _getLatestWritingScore(test.id, examProvider.writingExamHistories);
        }

        return Stack(
          clipBehavior: Clip.none,
          children: [
            TestCardWidget(
              testInfo: test,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TestDetailScreen(testData: test),
                  ),
                );
              },
            ),
            if (score != null)
              Positioned(
                top: -4,
                right: -4,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.green,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Text(
                    '${score.round()}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
