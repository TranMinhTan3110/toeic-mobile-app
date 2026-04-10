import 'package:flutter/material.dart';
import '../../../data/models/test_info.dart';
import '../../widgets/buttons/start_exam_button.dart';

class TestDetailScreen extends StatelessWidget {
  final TestInfo testData;

  const TestDetailScreen({super.key, required this.testData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Text(
            testData.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Thời gian: ${testData.duration} phút',
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 4),
          Text(
            'Câu hỏi: ${testData.questionCount}',
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),

          const SizedBox(height: 32),

          Expanded(
            child: Center(
              child: Icon(
                Icons.sports_martial_arts,
                size: 150,
                color: Colors.green.shade300,
              ),
            ),
          ),

          StartExamButton(
            onPressed: () {
              print("Bắt đầu làm bài: ${testData.title}");
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
