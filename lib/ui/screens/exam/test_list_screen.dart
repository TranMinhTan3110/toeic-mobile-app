import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/test_info.dart';
import '../../widgets/cards/test_card_widget.dart';
import 'test_detail_screen.dart';
import 'see_more_screen.dart';
import '../../widgets/common/custom_app_bar.dart';

class TestListScreen extends StatelessWidget {
  const TestListScreen({super.key});

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

  @override
  Widget build(BuildContext context) {
    final listReading = _generateMockTests('ETS 2024');
    final listSpeaking = _generateSpeakingTests();
    final listWriting = _generateWritingTests();

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
              _buildTestGrid(context, listReading),

              const SizedBox(height: 32),

              // CỤM 2: Speaking
              _buildSectionHeader(
                context,
                'TOEIC Speaking Exam',
              ),
              const SizedBox(height: 16),
              _buildTestGrid(context, listSpeaking),

              const SizedBox(height: 32),

              // CỤM 3: Writing
              _buildSectionHeader(context, 'TOEIC Writing Exam'),
              const SizedBox(height: 16),
              _buildTestGrid(context, listWriting),
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
              color: AppColors.textPrimary, // Thêm màu cho text tiêu đề
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
              color: AppColors.textLink, // Màu cho link / nút bấm dạng chữ
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTestGrid(BuildContext context, List<TestInfo> tests) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: tests.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 16,
        childAspectRatio: 0.6,
      ),
      itemBuilder: (context, index) {
        return TestCardWidget(
          testInfo: tests[index],
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => TestDetailScreen(testData: tests[index]),
              ),
            );
          },
        );
      },
    );
  }
}
