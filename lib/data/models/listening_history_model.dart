class ListeningHistoryModel {
  final String id;
  final String userId;
  final int part;
  final int correctCount;
  final int totalCount;
  final double percent;
  final DateTime date;
  final List<String> incorrectQuestionIds;
  final Map<String, String> selectedAnswers;

  ListeningHistoryModel({
    required this.id,
    required this.userId,
    required this.part,
    required this.correctCount,
    required this.totalCount,
    required this.percent,
    required this.date,
    required this.incorrectQuestionIds,
    required this.selectedAnswers,
  });

  factory ListeningHistoryModel.fromJson(Map<String, dynamic> json) {
    return ListeningHistoryModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      part: json['part'] ?? 1,
      correctCount: json['correctCount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
      percent: (json['percent'] as num?)?.toDouble() ?? 0.0,
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      incorrectQuestionIds: List<String>.from(json['incorrectQuestionIds'] ?? []),
      selectedAnswers: Map<String, String>.from(json['selectedAnswers'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'part': part,
      'correctCount': correctCount,
      'totalCount': totalCount,
      'percent': percent,
      'date': date.toIso8601String(),
      'incorrectQuestionIds': incorrectQuestionIds,
      'selectedAnswers': selectedAnswers,
    };
  }
}
