class WritingHistoryItem {
  final String id;
  final String userId;
  final String questionId;
  final String sessionType;
  final String userAnswer;
  final int? wordCount;
  final int? timeUsed;
  final int? aiScore;
  final WritingAiFeedback? aiFeedback;
  final DateTime submittedAt;
  final int? taskNumber;
  final String? taskType;
  final int? questionCount;
  final String? aiModel;
  final DateTime? scoredAt;
  final String? resultId;
  final List<String> questionIds;
  final Map<String, String> answers;

  WritingHistoryItem({
    required this.id,
    required this.userId,
    required this.questionId,
    required this.sessionType,
    required this.userAnswer,
    this.wordCount,
    this.timeUsed,
    this.aiScore,
    this.aiFeedback,
    required this.submittedAt,
    this.taskNumber,
    this.taskType,
    this.questionCount,
    this.aiModel,
    this.scoredAt,
    this.resultId,
    this.questionIds = const [],
    this.answers = const {},
  });

  factory WritingHistoryItem.fromJson(Map<String, dynamic> json) {
    return WritingHistoryItem(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      questionId:
          json['questionId']?.toString() ??
          json['question_id']?.toString() ??
          '',
      sessionType:
          json['sessionType']?.toString() ??
          json['session_type']?.toString() ??
          'practice',
      userAnswer:
          json['userAnswer']?.toString() ??
          json['user_answer']?.toString() ??
          '',
      wordCount: json['wordCount'] is int
          ? json['wordCount'] as int
          : int.tryParse(json['wordCount']?.toString() ?? ''),
      timeUsed: json['timeUsed'] is int
          ? json['timeUsed'] as int
          : int.tryParse(json['timeUsed']?.toString() ?? ''),
      aiScore: json['aiScore'] is int
          ? json['aiScore'] as int
          : int.tryParse(json['aiScore']?.toString() ?? ''),
      aiFeedback: WritingAiFeedback.fromJson(
        json['aiFeedback'] ?? json['ai_feedback'],
      ),
      submittedAt:
          DateTime.tryParse(
            json['submittedAt']?.toString() ??
                json['submitted_at']?.toString() ??
                '',
          ) ??
          DateTime.now(),
      taskNumber: json['taskNumber'] is int
          ? json['taskNumber'] as int
          : int.tryParse(json['taskNumber']?.toString() ?? ''),
      taskType: json['taskType']?.toString() ?? json['task_type']?.toString(),
      questionCount: json['questionCount'] is int
          ? json['questionCount'] as int
          : int.tryParse(
              json['questionCount']?.toString() ??
                  json['question_count']?.toString() ??
                  '',
            ),
      aiModel: json['aiModel']?.toString() ?? json['ai_model']?.toString(),
      scoredAt: json['scoredAt'] != null
          ? DateTime.tryParse(json['scoredAt'].toString())
          : json['scored_at'] != null
          ? DateTime.tryParse(json['scored_at'].toString())
          : null,
      resultId: json['resultId']?.toString() ?? json['result_id']?.toString(),
      questionIds: (json['questionIds'] ?? json['question_ids']) is List
          ? List<String>.from(json['questionIds'] ?? json['question_ids'])
          : [],
      answers: json['answers'] is Map
          ? (json['answers'] as Map).map(
              (key, value) => MapEntry(key.toString(), value.toString()),
            )
          : {},
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'questionId': questionId,
      'sessionType': sessionType,
      'userAnswer': userAnswer,
      'wordCount': wordCount,
      'timeUsed': timeUsed,
      'aiScore': aiScore,
      'aiFeedback': aiFeedback?.toJson(),
      'submittedAt': submittedAt.toIso8601String(),
      'taskNumber': taskNumber,
      'taskType': taskType,
      'questionCount': questionCount,
      'aiModel': aiModel,
      'scoredAt': scoredAt?.toIso8601String(),
      'resultId': resultId,
      'questionIds': questionIds,
      'answers': answers,
    };
  }

  String get sessionLabel {
    switch (sessionType.toLowerCase()) {
      case 'exam':
        return 'Thi';
      case 'practice':
        return 'Luyện tập';
      default:
        return sessionType;
    }
  }

  String get statusLabel {
    switch (sessionType.toLowerCase()) {
      case 'exam':
        return 'Thi';
      case 'practice':
        return 'Luyện tập';
      default:
        return sessionType;
    }
  }

  String get taskTypeLabel {
    if (taskType == null) return '-';
    switch (taskType!.toLowerCase()) {
      case 'write_sentence':
        return 'Mô tả tranh';
      case 'respond_email':
        return 'Phản hồi yêu cầu';
      case 'opinion_essay':
        return 'Viết luận';
      default:
        return taskType!;
    }
  }

  String get formattedDate {
    final day = submittedAt.day.toString().padLeft(2, '0');
    final month = submittedAt.month.toString().padLeft(2, '0');
    final year = submittedAt.year;
    final hour = submittedAt.hour.toString().padLeft(2, '0');
    final minute = submittedAt.minute.toString().padLeft(2, '0');
    return '$hour:$minute - $day/$month/$year';
  }

  bool get hasAiFeedback {
    return aiScore != null || (aiFeedback?.hasAnyField ?? false);
  }

  bool get hasQuestionSession {
    return questionIds.isNotEmpty;
  }
}

class WritingAiFeedback {
  final int? grammarScore;
  final int? vocabularyScore;
  final int? cohesionScore;
  final String? correctionsVi;
  final String? suggestedImprovement;

  WritingAiFeedback({
    this.grammarScore,
    this.vocabularyScore,
    this.cohesionScore,
    this.correctionsVi,
    this.suggestedImprovement,
  });

  factory WritingAiFeedback.fromJson(dynamic json) {
    if (json == null) {
      return WritingAiFeedback();
    }

    final map = json is Map<String, dynamic> ? json : <String, dynamic>{};
    return WritingAiFeedback(
      grammarScore: map['grammarScore'] is int
          ? map['grammarScore'] as int
          : int.tryParse(map['grammarScore']?.toString() ?? ''),
      vocabularyScore: map['vocabularyScore'] is int
          ? map['vocabularyScore'] as int
          : int.tryParse(map['vocabularyScore']?.toString() ?? ''),
      cohesionScore: map['cohesionScore'] is int
          ? map['cohesionScore'] as int
          : int.tryParse(map['cohesionScore']?.toString() ?? ''),
      correctionsVi:
          map['correctionsVi']?.toString() ?? map['corrections_vi']?.toString(),
      suggestedImprovement:
          map['suggestedImprovement']?.toString() ??
          map['suggested_improvement']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (grammarScore != null) 'grammarScore': grammarScore,
      if (vocabularyScore != null) 'vocabularyScore': vocabularyScore,
      if (cohesionScore != null) 'cohesionScore': cohesionScore,
      if (correctionsVi != null) 'correctionsVi': correctionsVi,
      if (suggestedImprovement != null)
        'suggestedImprovement': suggestedImprovement,
    };
  }

  bool get hasAnyField {
    return grammarScore != null ||
        vocabularyScore != null ||
        cohesionScore != null ||
        (correctionsVi?.isNotEmpty ?? false) ||
        (suggestedImprovement?.isNotEmpty ?? false);
  }
}
