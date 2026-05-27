class WritingHistoryItem {
  final String id;
  final String userId;
  final String questionId;
  final int? taskNumber;
  final String? taskType;
  final List<String> questionIds;
  final int questionCount;
  final Map<String, String> answers;
  final String sessionType;
  final String userAnswer;
  final int? wordCount;
  final int? timeUsed;
  final int? aiScore;
  final WritingAiFeedback? aiFeedback;
  final String status;
  final DateTime? scoredAt;
  final String? resultId;
  final String? aiModel;
  final DateTime submittedAt;

  WritingHistoryItem({
    required this.id,
    required this.userId,
    required this.questionId,
    this.taskNumber,
    this.taskType,
    required this.questionIds,
    required this.questionCount,
    required this.answers,
    required this.sessionType,
    required this.userAnswer,
    this.wordCount,
    this.timeUsed,
    this.aiScore,
    this.aiFeedback,
    required this.status,
    this.scoredAt,
    this.resultId,
    this.aiModel,
    required this.submittedAt,
  });

  factory WritingHistoryItem.fromJson(Map<String, dynamic> json) {
    final questionIdsRaw = json['questionIds'] ?? json['question_ids'];
    final questionIds = <String>[];
    if (questionIdsRaw is List) {
      for (final entry in questionIdsRaw) {
        if (entry != null) questionIds.add(entry.toString());
      }
    }

    final answersRaw = json['answers'];
    final answers = <String, String>{};
    if (answersRaw is Map) {
      answersRaw.forEach((key, value) {
        if (key != null) {
          answers[key.toString()] = value?.toString() ?? '';
        }
      });
    }

    return WritingHistoryItem(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? json['user_id']?.toString() ?? '',
      questionId:
          json['questionId']?.toString() ??
          json['question_id']?.toString() ??
          '',
      taskNumber: json['taskNumber'] is int
          ? json['taskNumber'] as int
          : int.tryParse(json['taskNumber']?.toString() ?? ''),
      taskType: json['taskType']?.toString() ?? json['task_type']?.toString(),
      questionIds: questionIds,
      questionCount: json['questionCount'] is int
          ? json['questionCount'] as int
          : int.tryParse(json['questionCount']?.toString() ?? '') ??
                (questionIds.isNotEmpty ? questionIds.length : 1),
      answers: answers,
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
      status: json['status']?.toString() ?? 'pending',
      scoredAt: DateTime.tryParse(
        json['scoredAt']?.toString() ?? json['scored_at']?.toString() ?? '',
      ),
      resultId: json['resultId']?.toString() ?? json['result_id']?.toString(),
      aiModel: json['aiModel']?.toString() ?? json['ai_model']?.toString(),
      submittedAt:
          DateTime.tryParse(
            json['submittedAt']?.toString() ??
                json['submitted_at']?.toString() ??
                '',
          ) ??
          DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'questionId': questionId,
      if (taskNumber != null) 'taskNumber': taskNumber,
      if (taskType != null) 'taskType': taskType,
      'questionIds': questionIds,
      'questionCount': questionCount,
      'answers': answers,
      'sessionType': sessionType,
      'userAnswer': userAnswer,
      'wordCount': wordCount,
      'timeUsed': timeUsed,
      'aiScore': aiScore,
      'aiFeedback': aiFeedback?.toJson(),
      'status': status,
      'scoredAt': scoredAt?.toIso8601String(),
      'resultId': resultId,
      'aiModel': aiModel,
      'submittedAt': submittedAt.toIso8601String(),
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

  String get taskTypeLabel {
    switch (taskType?.toLowerCase()) {
      case 'write_sentence':
        return 'Viết câu';
      case 'respond_email':
        return 'Viết email';
      case 'opinion_essay':
        return 'Bài luận';
      default:
        return taskType ?? '-';
    }
  }

  String get formattedDate {
    return '${submittedAt.day.toString().padLeft(2, '0')}/${submittedAt.month.toString().padLeft(2, '0')}/${submittedAt.year}';
  }

  String get statusLabel {
    switch (status.toLowerCase()) {
      case 'pending':
        return 'Chờ chấm';
      case 'scored':
        return 'Đã chấm';
      default:
        return status;
    }
  }

  bool get hasAiFeedback {
    return aiScore != null || (aiFeedback?.hasAnyField ?? false);
  }

  bool get hasQuestionSession =>
      questionIds.isNotEmpty ||
      answers.isNotEmpty ||
      taskNumber != null ||
      taskType != null;
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
