class WritingExamHistoryModel {
  final String id;
  final String userId;
  final String examSetId;
  final String examTitle;
  final double toeicScore;
  final double rawAverageScore;
  final int totalTasks;
  final int timeSpent;
  final DateTime date;
  final List<WritingExamTaskResultModel> taskResults;

  WritingExamHistoryModel({
    required this.id,
    required this.userId,
    required this.examSetId,
    required this.examTitle,
    required this.toeicScore,
    required this.rawAverageScore,
    required this.totalTasks,
    required this.timeSpent,
    required this.date,
    required this.taskResults,
  });

  factory WritingExamHistoryModel.fromJson(Map<String, dynamic> json) {
    final tasksRaw = json['taskResults'] ?? json['task_results'] as List<dynamic>? ?? [];
    final tasksList = (tasksRaw is List ? tasksRaw : [])
        .map((e) => WritingExamTaskResultModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return WritingExamHistoryModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      examSetId: json['examSetId'] ?? json['exam_set_id'] ?? '',
      examTitle: json['examTitle'] ?? json['exam_title'] ?? '',
      toeicScore: (json['toeicScore'] ?? json['toeic_score'] as num?)?.toDouble() ?? 0.0,
      rawAverageScore: (json['rawAverageScore'] ?? json['raw_average_score'] as num?)?.toDouble() ?? 0.0,
      totalTasks: json['totalTasks'] ?? json['total_tasks'] ?? 0,
      timeSpent: json['timeSpent'] ?? json['time_spent'] ?? 0,
      date: json['date'] != null
          ? DateTime.parse(json['date'].toString())
          : DateTime.now(),
      taskResults: tasksList,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'examSetId': examSetId,
        'examTitle': examTitle,
        'toeicScore': toeicScore,
        'rawAverageScore': rawAverageScore,
        'totalTasks': totalTasks,
        'timeSpent': timeSpent,
        'date': date.toIso8601String(),
        'taskResults': taskResults.map((e) => e.toJson()).toList(),
      };
}

class WritingExamTaskResultModel {
  final String questionId;
  final int taskNumber;
  final String taskType;
  final String userAnswer;
  final int wordCount;
  final int aiScore;
  final String aiFeedback;
  final Map<String, double> criteriaScores;

  WritingExamTaskResultModel({
    required this.questionId,
    required this.taskNumber,
    required this.taskType,
    required this.userAnswer,
    required this.wordCount,
    required this.aiScore,
    required this.aiFeedback,
    required this.criteriaScores,
  });

  factory WritingExamTaskResultModel.fromJson(Map<String, dynamic> json) {
    final criteriaRaw = json['criteriaScores'] ?? json['criteria_scores'] as Map<String, dynamic>? ?? {};
    final criteria = criteriaRaw.map<String, double>(
      (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
    );

    return WritingExamTaskResultModel(
      questionId: json['questionId'] ?? json['question_id'] ?? '',
      taskNumber: json['taskNumber'] ?? json['task_number'] ?? 0,
      taskType: json['taskType'] ?? json['task_type'] ?? '',
      userAnswer: json['userAnswer'] ?? json['user_answer'] ?? '',
      wordCount: json['wordCount'] ?? json['word_count'] ?? 0,
      aiScore: json['aiScore'] ?? json['ai_score'] ?? 0,
      aiFeedback: json['aiFeedback'] ?? json['ai_feedback'] ?? '',
      criteriaScores: criteria,
    );
  }

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'taskNumber': taskNumber,
        'taskType': taskType,
        'userAnswer': userAnswer,
        'wordCount': wordCount,
        'aiScore': aiScore,
        'aiFeedback': aiFeedback,
        'criteriaScores': criteriaScores,
      };
}
