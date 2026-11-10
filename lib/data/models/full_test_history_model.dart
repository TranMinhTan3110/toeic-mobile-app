class FullTestHistoryModel {
  final String id;
  final String userId;
  final String examId;
  final String examTitle;
  final int scoreListening;
  final int scoreReading;
  final int totalScore;
  final int correctCount;
  final int totalCount;
  final int timeSpent;
  final DateTime completedAt;
  final Map<String, String> answers;
  final Map<String, int> partScores;

  FullTestHistoryModel({
    required this.id,
    required this.userId,
    required this.examId,
    required this.examTitle,
    required this.scoreListening,
    required this.scoreReading,
    required this.totalScore,
    required this.correctCount,
    required this.totalCount,
    required this.timeSpent,
    required this.completedAt,
    required this.answers,
    required this.partScores,
  });

  factory FullTestHistoryModel.fromJson(Map<String, dynamic> json) {
    return FullTestHistoryModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      examId: json['examId'] ?? '',
      examTitle: json['examTitle'] ?? '',
      scoreListening: json['scoreListening'] ?? 0,
      scoreReading: json['scoreReading'] ?? 0,
      totalScore: json['totalScore'] ?? 0,
      correctCount: json['correctCount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
      timeSpent: json['timeSpent'] ?? 0,
      completedAt: json['completedAt'] != null
          ? DateTime.parse(json['completedAt'])
          : DateTime.now(),
      answers: Map<String, String>.from(json['answers'] ?? {}),
      partScores: Map<String, int>.from(json['partScores'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'examId': examId,
      'examTitle': examTitle,
      'scoreListening': scoreListening,
      'scoreReading': scoreReading,
      'totalScore': totalScore,
      'correctCount': correctCount,
      'totalCount': totalCount,
      'timeSpent': timeSpent,
      'completedAt': completedAt.toIso8601String(),
      'answers': answers,
      'partScores': partScores,
    };
  }
}
