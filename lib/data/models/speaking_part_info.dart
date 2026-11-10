import 'package:flutter/material.dart';

class SpeakingPartInfo {
  final int partNumber;
  final String title;       // tên tiếng Anh (dùng AppBar)
  final String titleVi;     // tên tiếng Việt
  final String descriptionEn;
  final String descriptionVi;
  final IconData icon;
  final int defaultQuestionCount; // số câu mặc định trong dropdown

  const SpeakingPartInfo({
    required this.partNumber,
    required this.title,
    required this.titleVi,
    required this.descriptionEn,
    required this.descriptionVi,
    required this.icon,
    this.defaultQuestionCount = 5,
  });

  // ── Danh sách 6 phần luyện nói TOEIC ──────────────────────────────────────
  static const List<SpeakingPartInfo> parts = [
    SpeakingPartInfo(
      partNumber: 1,
      title: 'Read a Text Aloud',
      titleVi: 'Đọc văn bản',
      descriptionEn:
      'In this part of the test, you will read a text on the screen. '
          'You will have 45 seconds to prepare. '
          'Then you will have 45 seconds to read the text aloud.',
      descriptionVi:
      'Trong phần này của bài kiểm tra, bạn sẽ đọc đoạn văn trên màn hình. '
          'Bạn sẽ có 45 giây để chuẩn bị. '
          'Sau đó, bạn sẽ có 45 giây để đọc to đoạn văn bản.',
      icon: Icons.menu_book_rounded,
      defaultQuestionCount: 5,
    ),
    SpeakingPartInfo(
      partNumber: 2,
      title: 'Describe a Picture',
      titleVi: 'Mô tả tranh',
      descriptionEn:
      'In this part of the test, you will describe the picture on your screen '
          'in as much detail as you can. '
          'You will have 30 seconds to prepare your response. '
          'Then you will have 45 seconds to speak about the picture.',
      descriptionVi:
      'Trong phần này, bạn sẽ mô tả hình ảnh trên màn hình càng chi tiết càng tốt. '
          'Bạn sẽ có 30 giây để chuẩn bị câu trả lời. '
          'Sau đó, bạn sẽ có 45 giây để nói về hình ảnh.',
      icon: Icons.image_rounded,
      defaultQuestionCount: 5,
    ),
    SpeakingPartInfo(
      partNumber: 3,
      title: 'Respond to Questions (1)',
      titleVi: 'Trả lời câu hỏi (1)',
      descriptionEn:
      'In this part of the test, you will answer three questions. '
          'For each question, begin responding immediately after you hear a beep. '
          'No preparation time is provided. '
          'You will have 15 seconds to respond to Questions 4 and 5 '
          'and 30 seconds to respond to Question 6.',
      descriptionVi:
      'Trong phần này, bạn sẽ trả lời ba câu hỏi. '
          'Với mỗi câu hỏi, hãy trả lời ngay sau khi nghe tiếng bíp. '
          'Không có thời gian chuẩn bị. '
          'Bạn có 15 giây cho câu 4 và 5, '
          'và 30 giây cho câu 6.',
      icon: Icons.record_voice_over_rounded,
      defaultQuestionCount: 5,
    ),
    SpeakingPartInfo(
      partNumber: 4,
      title: 'Respond to Questions (2)',
      titleVi: 'Trả lời câu hỏi (2)',
      descriptionEn:
      'In this part of the test, you will answer three questions based on '
          'information provided. You will have 30 seconds to read the information '
          'before the questions begin. '
          'For each question, you will have 15 or 30 seconds to respond.',
      descriptionVi:
      'Trong phần này, bạn sẽ trả lời ba câu hỏi dựa trên thông tin được cung cấp. '
          'Bạn sẽ có 30 giây để đọc thông tin trước khi các câu hỏi bắt đầu. '
          'Với mỗi câu hỏi, bạn có 15 hoặc 30 giây để trả lời.',
      icon: Icons.fact_check_rounded,
      defaultQuestionCount: 5,
    ),
    SpeakingPartInfo(
      partNumber: 5,
      title: 'Express an Opinion',
      titleVi: 'Thể hiện quan điểm',
      descriptionEn:
      'In this part of the test, you will give your opinion about '
          'a specific topic. Be sure to say as much as you can in the time allowed. '
          'You will have 15 seconds to prepare. '
          'Then you will have 60 seconds to speak.',
      descriptionVi:
      'Trong phần này, bạn sẽ trình bày quan điểm của mình về một chủ đề cụ thể. '
          'Hãy nói càng nhiều càng tốt trong thời gian cho phép. '
          'Bạn sẽ có 15 giây để chuẩn bị. '
          'Sau đó, bạn sẽ có 60 giây để nói.',
      icon: Icons.co_present_rounded,
      defaultQuestionCount: 5,
    ),
  ];
}