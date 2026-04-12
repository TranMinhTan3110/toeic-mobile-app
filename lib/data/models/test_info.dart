// lib/data/models/test_info.dart
class TestInfo {
  final String title;
  final int duration; // Thời gian làm bài (phút)
  final int questionCount; // Số lượng câu hỏi

  TestInfo({
    required this.title,
    this.duration = 120, // Mặc định 120 phút
    this.questionCount = 200, // Mặc định 200 câu
  });
}
