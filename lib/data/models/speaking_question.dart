import 'package:flutter/foundation.dart';
import '../../ui/widgets/speaking/speaking_explanation_panel.dart';

class SpeakingQuestion {
  final String id;
  final String text; // prompt_text
  final String? imageUrl;
  final String? audioUrl;
  final int prepSeconds;
  final int recordSeconds;
  final int taskNumber;
  final String? aiPrompt;
  final List<String> scoringCriteria;

  // ── Dữ liệu cho Task 3 & 4 ─────────────────────────────────────────
  final List<String> questions;    // Danh sách câu hỏi con
  final List<int> answerTimes;    // Thời gian cho từng câu [15, 15, 30]

  final String? transcriptText;
  final String? translationText;
  final List<KeywordItem> keywords;
  final String? sampleAnswer;
  final String? sampleTranslation;

  const SpeakingQuestion({
    required this.id,
    required this.text,
    this.imageUrl,
    this.audioUrl,
    required this.prepSeconds,
    required this.recordSeconds,
    required this.taskNumber,
    this.aiPrompt,
    this.scoringCriteria = const [],
    this.questions = const [],
    this.answerTimes = const [],
    this.transcriptText,
    this.translationText,
    this.keywords = const [],
    this.sampleAnswer,
    this.sampleTranslation,
  });

  factory SpeakingQuestion.fromJson(Map<String, dynamic> json) {
    // Ưu tiên các field theo contract camelCase của user
    
    // 1. Xử lý danh sách câu hỏi: 'questions' (ưu tiên) -> 'question' -> []
    var qData = json['questions'] ?? json['question'] ?? [];
    List<String> qList = [];
    if (qData is List) {
      qList = qData.map((e) => e.toString()).toList();
    } else if (qData is String && qData.isNotEmpty) {
      qList = [qData];
    }

    // 2. Xử lý thời gian trả lời: 'answerTimes' (ưu tiên) -> 'answer_times' -> []
    var tData = json['answerTimes'] ?? json['answer_times'] ?? [];
    List<int> tList = [];
    if (tData is List) {
      tList = tData.map((e) => int.tryParse(e.toString()) ?? 0).toList();
    }

    // Logging nhẹ để debug nếu cần
    if (kDebugMode) {
      print('SpeakingQuestion.fromJson: id=${json['id']}, questions.len=${qList.length}');
    }

    return SpeakingQuestion(
      id: json['id']?.toString() ?? '',
      text: json['promptText'] ?? json['prompt_text'] ?? json['promptText'] ?? '',
      imageUrl: json['promptImageUrl'] ?? json['prompt_image_url'],
      audioUrl: json['promptAudioUrl'] ?? json['prompt_audio_url'],
      prepSeconds: (json['preparationTime'] ?? json['preparation_time'] ?? 0).toInt(),
      recordSeconds: (json['responseTime'] ?? json['response_time'] ?? 0).toInt(),
      taskNumber: (json['taskNumber'] ?? json['task_number'] ?? 0).toInt(),
      aiPrompt: json['aiPrompt'] ?? json['ai_prompt'],
      scoringCriteria: List<String>.from(json['scoringCriteria'] ?? json['scoring_criteria'] ?? []),
      questions: qList,
      answerTimes: tList,
      transcriptText: json['transcriptText'] ?? json['promptText'] ?? json['prompt_text'],
      translationText: json['translationText'],
      keywords: (json['keywords'] as List?)
          ?.map((k) => KeywordItem(
                word: k['word'] ?? '',
                meaning: k['meaning'] ?? '',
              ))
          .toList() ??
          const [],
      sampleAnswer: json['sampleAnswer'],
      sampleTranslation: json['sampleTranslation'],
    );
  }
}

class SpeakingQuestionData {
  SpeakingQuestionData._();

  static const Map<int, List<SpeakingQuestion>> byPart = {
    1: _part1,
    2: _part2,
    3: _part3,
    4: _part4,
    5: _part5,
  };

  static const _part1 = [
    SpeakingQuestion(
      id: 'mock_1',
      taskNumber: 1,
      prepSeconds: 45,
      recordSeconds: 45,
      text: 'The personnel managers have decided to make staff changes in the finance...',
    ),
  ];

  static const _part2 = [
    SpeakingQuestion(
      id: 'mock_2',
      taskNumber: 2,
      prepSeconds: 30,
      recordSeconds: 45,
      text: 'Describe the picture below in as much detail as you can.',
      imageUrl: 'assets/images/speaking_p2_q1.jpg',
    ),
  ];

  static const _part3 = [
    SpeakingQuestion(
      id: 'mock_3',
      taskNumber: 3,
      prepSeconds: 0,
      recordSeconds: 60,
      text: 'Imagine that your friend is planning to go shopping. You and your friend are having a telephone conversation about shopping for clothes.',
      questions: [
        'Do you usually buy clothes before traveling? Why?',
        'What kind of clothes do people in your town usually wear these days?',
        'Please explain a good place to buy clothes in your city and why.'
      ],
      answerTimes: [15, 15, 30],
    ),
  ];

  static const _part4 = [
    SpeakingQuestion(
      id: 'mock_4',
      taskNumber: 4,
      prepSeconds: 45,
      recordSeconds: 60,
      text: 'Respond to Questions Using Information Provided.',
      questions: [
        'What time does the event start?',
        'Is there any lunch provided?',
        'Can you tell me the schedule for the afternoon?'
      ],
      answerTimes: [15, 15, 30],
    ),
  ];

  static const _part5 = [
    SpeakingQuestion(
      id: 'mock_5',
      taskNumber: 5,
      prepSeconds: 30,
      recordSeconds: 60,
      text: 'Do you think it is better to work from home or in an office?',
    ),
  ];
}
