import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../widgets/common/custom_app_bar.dart';
import 'part6_quiz_screen.dart';

/// Simple Part 6: Passage with multiple blanks. Each blank has 4 options.
class Part6Screen extends StatefulWidget {
  const Part6Screen({super.key});

  @override
  State<Part6Screen> createState() => _Part6ScreenState();
}

class _Part6ScreenState extends State<Part6Screen> {
  // Demo options and answers for a single passage (3 blanks)
  final List<List<String>> _options = [
    ['Monday', 'Tuesday', 'Wednesday', 'Thursday'],
    ['10:00 AM', '2:00 PM', '6:00 PM', '9:00 AM'],
    ['causes', 'creates', 'brings', 'makes'],
  ];
  final List<int> _correct = [1, 0, 0];

  int _passageCount = 1;

  void _start() {
    // Build passages by repeating demo passage _passageCount times
    final passages = <Part6Passage>[];
    for (var p = 0; p < _passageCount; p++) {
      // simple demo segments (3 blanks)
      final segments = [
        'Dear Mr. Thompson,\n\nI am writing to inform you that our meeting scheduled for ',
        ' has been moved to the following day due to unforeseen circumstances. The new time will be ',
        '. Please let me know if this ',
        ' any inconvenience to you.\n\nSincerely,\nKaren',
      ];
      passages.add(Part6Passage(segments: segments, options: _options, correct: _correct));
    }

    Navigator.of(context).push(MaterialPageRoute(builder: (_) => Part6QuizScreen(passages: passages)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Phần 6 - Điền Vào Đoạn Văn', centerTitle: true),
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
                Text('Hướng dẫn làm Part 6', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                SizedBox(height: 8),
                Text('Đọc đoạn văn và chọn đáp án phù hợp cho mỗi chỗ trống. Sau khi chọn số đoạn, hệ thống sẽ hiển thị ngay trang kết quả.', style: TextStyle(color: Colors.black87)),
              ]),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Expanded(child: Text('Số đoạn muốn làm', style: TextStyle(fontWeight: FontWeight.w700))),
                DropdownButton<int>(
                  value: _passageCount,
                  items: [1, 2, 3].map((e) => DropdownMenuItem(value: e, child: Text('$e'))).toList(),
                  onChanged: (v) => setState(() => _passageCount = v ?? 1),
                ),
              ]),
            ),

            const Spacer(),

            SafeArea(
              top: false,
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _start,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                  child: const Padding(padding: EdgeInsets.symmetric(vertical: 14), child: Text('Bắt đầu', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: Colors.white))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
