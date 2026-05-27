class SpeakingHistoryItem {
  final String historyId;
  final int attemptNumber;
  final int partNumber;
  final String partTitle;
  final int correctCount;
  final int totalQuestions;
  final String date;
  final double score;
  final String feedbackSummary;
  final Map<String, double> criteria;

  SpeakingHistoryItem({
    required this.historyId,
    required this.attemptNumber,
    required this.partNumber,
    required this.partTitle,
    required this.correctCount,
    required this.totalQuestions,
    required this.date,
    required this.score,
    required this.feedbackSummary,
    required this.criteria,
  });
}
