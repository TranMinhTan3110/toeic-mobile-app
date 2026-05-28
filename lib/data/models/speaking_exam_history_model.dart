class SpeakingExamHistoryModel {
  final String id;
  final String userId;
  final String examSetId;
  final String examTitle;
  final double toeicScore;
  final double rawAverageScore;
  final int totalTasks;
  final DateTime date;
  final List<SpeakingExamTaskResultModel> taskResults;

  SpeakingExamHistoryModel({
    required this.id,
    required this.userId,
    required this.examSetId,
    required this.examTitle,
    required this.toeicScore,
    required this.rawAverageScore,
    required this.totalTasks,
    required this.date,
    required this.taskResults,
  });

  factory SpeakingExamHistoryModel.fromJson(Map<String, dynamic> json) {
    final tasksRaw = json['taskResults'] ?? json['task_results'] as List<dynamic>? ?? [];
    final tasksList = (tasksRaw is List ? tasksRaw : [])
        .map((e) => SpeakingExamTaskResultModel.fromJson(e as Map<String, dynamic>))
        .toList();

    return SpeakingExamHistoryModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? json['user_id'] ?? '',
      examSetId: json['examSetId'] ?? json['exam_set_id'] ?? '',
      examTitle: json['examTitle'] ?? json['exam_title'] ?? '',
      toeicScore: (json['toeicScore'] ?? json['toeic_score'] as num?)?.toDouble() ?? 0.0,
      rawAverageScore: (json['rawAverageScore'] ?? json['raw_average_score'] as num?)?.toDouble() ?? 0.0,
      totalTasks: json['totalTasks'] ?? json['total_tasks'] ?? 0,
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
        'date': date.toIso8601String(),
        'taskResults': taskResults.map((e) => e.toJson()).toList(),
      };
}

class SpeakingExamTaskResultModel {
  final String questionId;
  final int? subQuestionIndex;
  final String transcript;
  final double score;
  final String feedback;
  final Map<String, double> criteriaScores;
  final bool passed;

  SpeakingExamTaskResultModel({
    required this.questionId,
    this.subQuestionIndex,
    required this.transcript,
    required this.score,
    required this.feedback,
    required this.criteriaScores,
    required this.passed,
  });

  factory SpeakingExamTaskResultModel.fromJson(Map<String, dynamic> json) {
    final criteriaRaw = json['criteriaScores'] ?? json['criteria_scores'] as Map<String, dynamic>? ?? {};
    final criteria = criteriaRaw.map<String, double>(
      (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
    );

    return SpeakingExamTaskResultModel(
      questionId: json['questionId'] ?? json['question_id'] ?? '',
      subQuestionIndex: json['subQuestionIndex'] ?? json['sub_question_index'],
      transcript: json['transcript'] ?? '',
      score: (json['score'] as num?)?.toDouble() ?? 0.0,
      feedback: json['feedback'] ?? '',
      criteriaScores: criteria,
      passed: json['passed'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'questionId': questionId,
        'subQuestionIndex': subQuestionIndex,
        'transcript': transcript,
        'score': score,
        'feedback': feedback,
        'criteriaScores': criteriaScores,
        'passed': passed,
      };
}
