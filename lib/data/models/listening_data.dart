import 'package:flutter/material.dart';

// ── Part info model ──────────────────────────────────────────────────────────

class ListeningPartInfo {
  final int partNumber;
  final String title;
  final String titleVi;
  final String description;
  final IconData icon;

  const ListeningPartInfo({
    required this.partNumber,
    required this.title,
    required this.titleVi,
    required this.description,
    required this.icon,
  });
}

// ── History item model ───────────────────────────────────────────────────────

class HistoryItem {
  final String title;
  final double percent;
  final int correct;
  final int total;
  final DateTime date;

  const HistoryItem({
    required this.title,
    required this.percent,
    required this.correct,
    required this.total,
    required this.date,
  });
}

// ── Static data ───────────────────────────────────────────────────────────────

class ListeningData {
  ListeningData._();

  static const parts = [
    ListeningPartInfo(
      partNumber: 1,
      title: 'Photographs',
      titleVi: 'Mô Tả Hình Ảnh',
      description:
          'For each question, you will see a picture and you will hear four short statements. '
          'The statements will be spoken just one time. They will not be printed in your test book '
          'so you must listen carefully to understand what the speaker says. '
          'When you hear the four statements, look at the picture and choose the statement '
          'that best describes what you see in the picture. Choose the best answer A, B, C or D.',
      icon: Icons.image_rounded,
    ),
    ListeningPartInfo(
      partNumber: 2,
      title: 'Question-Response',
      titleVi: 'Hỏi & Đáp',
      description:
          'You will hear a question or statement and three responses spoken in English. '
          'They will not be printed in your test book and will be spoken only one time. '
          'Select the best response to the question or statement and mark the letter '
          'A, B, or C on your answer sheet.',
      icon: Icons.question_answer_rounded,
    ),
    ListeningPartInfo(
      partNumber: 3,
      title: 'Conversations',
      titleVi: 'Đoạn Hội Thoại',
      description:
          'You will hear some conversations between two or more people. '
          'You will be asked to answer three questions about what the speakers say in each conversation. '
          'Select the best response to each question and mark the letter A, B, C, or D on your answer sheet. '
          'The conversations will not be printed in your test book and will be spoken only one time.',
      icon: Icons.forum_rounded,
    ),
    ListeningPartInfo(
      partNumber: 4,
      title: 'Short Talks',
      titleVi: 'Bài Nói Chuyện Ngắn',
      description:
          'You will hear some talks given by a single speaker. '
          'You will be asked to answer three questions about what the speaker says in each talk. '
          'Select the best response to each question and mark the letter A, B, C, or D on your answer sheet. '
          'The talks will not be printed in your test book and will be spoken only one time.',
      icon: Icons.record_voice_over_rounded,
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
