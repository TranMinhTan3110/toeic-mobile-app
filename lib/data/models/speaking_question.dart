import 'package:flutter/foundation.dart';

class KeywordItem {
  final String word;
  final String? ipa;
  final String meaning;

  const KeywordItem({
    required this.word,
    this.ipa,
    required this.meaning,
  });

  factory KeywordItem.fromJson(Map<String, dynamic> json) {
    return KeywordItem(
      word: json['word'] ?? '',
      ipa: json['ipa'],
      meaning: json['meaning'] ?? '',
    );
  }
}

class SpeakingExplanation {
  final String? translation;
  final String? contextTranslation;
  final List<KeywordItem> keywords;
  final List<String> questionsTranslation;
  final List<String> sampleAnswers;
  final List<String> sampleAnswersTranslation;

  const SpeakingExplanation({
    this.translation,
    this.contextTranslation,
    this.keywords = const [],
    this.questionsTranslation = const [],
    this.sampleAnswers = const [],
    this.sampleAnswersTranslation = const [],
  });

  factory SpeakingExplanation.fromJson(Map<String, dynamic> json) {
    return SpeakingExplanation(
      translation: json['translation'],
      contextTranslation: json['context_translation'] ?? json['contextTranslation'],
      keywords: (json['keywords'] as List?)
              ?.map((k) => KeywordItem.fromJson(k))
              .toList() ??
          const [],
      questionsTranslation: List<String>.from(json['questions_translation'] ?? json['questionsTranslation'] ?? []),
      sampleAnswers: List<String>.from(json['sample_answers'] ?? json['sampleAnswers'] ?? []),
      sampleAnswersTranslation: List<String>.from(json['sample_answers_translation'] ?? json['sampleAnswersTranslation'] ?? []),
    );
  }
}

class SpeakingQuestion {
  final String id;
  final String text;
  final String? imageUrl;
  final String? audioUrl;
  final int prepSeconds;
  final int recordSeconds;
  final int taskNumber;
  final String? aiPrompt;
  final List<String> scoringCriteria;
  final List<String> questions;
  final List<int> answerTimes;
  final String? sampleAnswer;
  final SpeakingExplanation? explanation;

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
    this.sampleAnswer,
    this.explanation,
  });

  factory SpeakingQuestion.fromJson(Map<String, dynamic> json) {
    var qData = json['questions'] ?? [];
    List<String> qList = qData is List ? qData.map((e) => e.toString()).toList() : [];

    var tData = json['answer_times'] ?? json['answerTimes'] ?? [];
    List<int> tList = tData is List ? tData.map((e) => int.tryParse(e.toString()) ?? 0).toList() : [];

    return SpeakingQuestion(
      id: json['id']?.toString() ?? '',
      text: json['prompt_text'] ?? json['promptText'] ?? '',
      imageUrl: json['prompt_image_url'] ?? json['promptImageUrl'] ?? json['image_url'],
      audioUrl: json['prompt_audio_url'] ?? json['promptAudioUrl'] ?? json['audio_url'],
      prepSeconds: (json['preparation_time'] ?? json['preparationTime'] ?? 0).toInt(),
      recordSeconds: (json['response_time'] ?? json['responseTime'] ?? 0).toInt(),
      taskNumber: (json['task_number'] ?? json['taskNumber'] ?? 0).toInt(),
      aiPrompt: json['ai_prompt'] ?? json['aiPrompt'],
      scoringCriteria: List<String>.from(json['scoring_criteria'] ?? json['scoringCriteria'] ?? []),
      questions: qList,
      answerTimes: tList,
      sampleAnswer: json['sample_answer'] ?? json['sampleAnswer'],
      explanation: json['explanation'] != null 
          ? SpeakingExplanation.fromJson(json['explanation']) 
          : null,
    );
  }
}

class SpeakingQuestionData {
  static const Map<int, List<SpeakingQuestion>> byPart = {
    1: [
      SpeakingQuestion(
        id: 'mock_1',
        taskNumber: 1,
        prepSeconds: 45,
        recordSeconds: 45,
        text: 'The personnel managers have decided to make staff changes in the finance...',
      ),
    ],
  };
}
