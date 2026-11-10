import 'package:flutter/material.dart';
import 'listening_data.dart';

// ── Part info model ──────────────────────────────────────────────────────────

class WritingPartInfo {
  final int partNumber;
  final String title;
  final String titleVi;
  final String description;
  final IconData icon;

  const WritingPartInfo({
    required this.partNumber,
    required this.title,
    required this.titleVi,
    required this.description,
    required this.icon,
  });
}

// ── Static data ───────────────────────────────────────────────────────────────

class WritingData {
  WritingData._();

  static const parts = [
    WritingPartInfo(
      partNumber: 1,
      title: 'Picture Description',
      titleVi: 'Mô Tả Tranh',
      description:
          'You will see a picture and you need to write a detailed description of what you see. '
          'Your description should include details about the people, objects, and activities in the picture. '
          'Write clearly and use proper grammar.',
      icon: Icons.photo_album_rounded,
    ),
    WritingPartInfo(
      partNumber: 2,
      title: 'Respond to a Request',
      titleVi: 'Phản Hồi Yêu Cầu',
      description:
          'You will read a request or question and you need to write a response. '
          'Your response should be appropriate and answer the request completely. '
          'Write clearly and use proper grammar.',
      icon: Icons.mark_email_read_rounded,
    ),
    WritingPartInfo(
      partNumber: 3,
      title: 'Write an Essay',
      titleVi: 'Viết Luận',
      description:
          'You will be given a topic and you need to write an essay about it. '
          'Your essay should have a clear introduction, body paragraphs, and conclusion. '
          'Write clearly and use proper grammar.',
      icon: Icons.description_rounded,
    ),
  ];

  static List<HistoryItem> demoHistory(int partNumber) => [
        HistoryItem(
          title: 'Part $partNumber – Luyện tập #1',
          percent: 80,
          correct: 8,
          total: 10,
          date: DateTime(2024, 4, 1),
        ),
        HistoryItem(
          title: 'Part $partNumber – Luyện tập #2',
          percent: 60,
          correct: 6,
          total: 10,
          date: DateTime(2024, 4, 3),
        ),
        HistoryItem(
          title: 'Part $partNumber – Luyện tập #3',
          percent: 90,
          correct: 9,
          total: 10,
          date: DateTime(2024, 4, 5),
        ),
        HistoryItem(
          title: 'Part $partNumber – Luyện tập #4',
          percent: 40,
          correct: 4,
          total: 10,
          date: DateTime(2024, 4, 7),
        ),
        HistoryItem(
          title: 'Part $partNumber – Luyện tập #5',
          percent: 70,
          correct: 7,
          total: 10,
          date: DateTime(2024, 4, 9),
        ),
        HistoryItem(
          title: 'Part $partNumber – Luyện tập #6',
          percent: 50,
          correct: 5,
          total: 10,
          date: DateTime(2024, 4, 11),
        ),
      ];
}
