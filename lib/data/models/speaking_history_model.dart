class SpeakingHistoryModel {
  final String id;
  final String userId;
  final int part;
  final int correctCount;
  final int totalCount;
  final double percent;
  final double score;
  final String feedbackSummary;
  final Map<String, double> criteria;
  final String sessionType;
  final DateTime date;
  final List<SpeakingHistoryAnswerModel> answers;

  SpeakingHistoryModel({
    required this.id,
    required this.userId,
    required this.part,
    required this.correctCount,
    required this.totalCount,
    required this.percent,
    required this.score,
    required this.feedbackSummary,
    required this.criteria,
    required this.sessionType,
    required this.date,
    required this.answers,
  });

  factory SpeakingHistoryModel.fromJson(Map<String, dynamic> json) {
    final criteriaRaw = json['criteria'] as Map<String, dynamic>? ?? {};
    final criteria = criteriaRaw.map<String, double>(
      (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
    );

    final answersRaw = json['answers'] as List<dynamic>? ?? [];
    return SpeakingHistoryModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      part: json['part'] ?? 1,
      correctCount: json['correctCount'] ?? json['correct_count'] ?? 0,
      totalCount: json['totalCount'] ?? json['total_count'] ?? 0,
      percent: (json['percent'] as num?)?.toDouble() ?? 0,
      score: (json['score'] as num?)?.toDouble() ?? 0,
      feedbackSummary:
          json['feedbackSummary'] ?? json['feedback_summary'] ?? '',
      criteria: criteria,
      sessionType: json['sessionType'] ?? json['session_type'] ?? 'practice',
      date: json['date'] != null
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(),
      answers: answersRaw
          .map((e) =>
              SpeakingHistoryAnswerModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'part': part,
        'correctCount': correctCount,
        'totalCount': totalCount,
        'percent': percent,
        'score': score,
        'feedbackSummary': feedbackSummary,
        'criteria': criteria,
        'sessionType': sessionType,
        'date': date.toIso8601String(),
        'answers': answers.map((e) => e.toJson()).toList(),
      };
}

class SpeakingHistoryAnswerModel {
  final String questionId;
  final int? subQuestionIndex;
  final String transcript;
  final String audioUrl;
  final double overallScore;
  final bool passed;
  final String feedback;
  final Map<String, double> criteriaScores;

  SpeakingHistoryAnswerModel({
    required this.questionId,
    this.subQuestionIndex,
    required this.transcript,
    required this.audioUrl,
    required this.overallScore,
    required this.passed,
    required this.feedback,
    required this.criteriaScores,
  });

  factory SpeakingHistoryAnswerModel.fromJson(Map<String, dynamic> json) {
    final criteriaRaw =
        json['criteriaScores'] ?? json['criteria_scores'] as Map<String, dynamic>? ?? {};
    final criteria = (criteriaRaw is Map<String, dynamic> ? criteriaRaw : {})
        .map<String, double>((k, v) => MapEntry(k.toString(), (v as num).toDouble()));

    return SpeakingHistoryAnswerModel(
      questionId: json['questionId'] ?? json['question_id'] ?? '',
      subQuestionIndex: json['subQuestionIndex'] ?? json['sub_question_index'],
      transcript: json['transcript'] ?? '',
      audioUrl: json['audioUrl'] ?? json['audio_url'] ?? '',
      overallScore:
          (json['overallScore'] ?? json['overall_score'] as num?)?.toDouble() ??
              0,
      passed: json['passed'] == true,
      feedback: json['feedback'] ?? '',
      criteriaScores: criteria,
    );
  }

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'subQuestionIndex': subQuestionIndex,
        'transcript': transcript,
        'audioUrl': audioUrl,
        'overallScore': overallScore,
        'passed': passed,
        'feedback': feedback,
        'criteriaScores': criteriaScores,
        'aiFeedback': {
          'pronunciation': (overallScore / 2).round().clamp(0, 5),
          'grammar': (overallScore / 2).round().clamp(0, 5),
          'vocabulary': (overallScore / 2).round().clamp(0, 5),
          'feedbackVi': feedback,
        },
      };
}
