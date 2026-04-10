import 'package:flutter/material.dart';
import '../../../data/models/test_info.dart';
import '../../widgets/cards/test_card_widget.dart';
import 'test_detail_screen.dart';
import 'see_more_screen.dart';

class TestListScreen extends StatelessWidget {
  const TestListScreen({super.key});

  // Tạo mock data 8 bài test để set cứng
  List<TestInfo> _generateMockTests(String prefix) {
    return List.generate(
      8,
      (index) => TestInfo(
        title: 'Test ${10 - index} $prefix',
      ), // Đếm ngược từ 10 xuống
    );
  }

  @override
  Widget build(BuildContext context) {
    final listReading = _generateMockTests('ETS 2023');
    final listWriting = _generateMockTests('Writing 2023');

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Thi', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF4DB6AC),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // CỤM 1
              _buildSectionHeader(
                context,
                'TOEIC Listening & Reading Fulltest',
              ),
              const SizedBox(height: 16),
              _buildTestGrid(context, listReading),

              const SizedBox(height: 32),

              // CỤM 2
              _buildSectionHeader(context, 'TOEIC Writing & Speaking Fulltest'),
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
              color: Color(0xFF4DB6AC),
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
        childAspectRatio: 0.7,
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
