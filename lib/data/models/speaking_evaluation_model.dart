class SpeakingEvaluation {
  final double overallScore;
  final Map<String, double> criteriaScores; // pronunciation, fluency, etc.
  final String feedback;
  final String? transcript; // Bản dịch lại từ giọng nói của người dùng

  SpeakingEvaluation({
    required this.overallScore,
    required this.criteriaScores,
    required this.feedback,
    this.transcript,
  });

  factory SpeakingEvaluation.fromJson(Map<String, dynamic> json) {
    return SpeakingEvaluation(
      overallScore: (json['overallScore'] as num?)?.toDouble() ?? 0.0,
      criteriaScores: Map<String, double>.from(
        (json['criteriaScores'] as Map? ?? {}).map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
        ),
      ),
      feedback: json['feedback'] ?? '',
      transcript: json['transcript'],
    );
  }
}
