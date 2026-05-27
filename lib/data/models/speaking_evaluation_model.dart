class SpeakingEvaluation {
  final double overallScore;
  final Map<String, double> criteriaScores;
  final String feedback;
  final String? transcript;
  final String? audioUrl; // Thêm trường này
  final bool passed;

  SpeakingEvaluation({
    required this.overallScore,
    required this.criteriaScores,
    required this.feedback,
    this.transcript,
    this.audioUrl,
    this.passed = false,
  });

  factory SpeakingEvaluation.fromJson(Map<String, dynamic> json) {
    final overall =
        (json['overallScore'] ?? json['overall_score'] as num?)?.toDouble() ??
            0.0;
    final criteriaRaw =
        json['criteriaScores'] ?? json['criteria_scores'] as Map? ?? {};
    return SpeakingEvaluation(
      overallScore: overall,
      criteriaScores: Map<String, double>.from(
        criteriaRaw.map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
        ),
      ),
      feedback: json['feedback'] ?? '',
      transcript: json['transcript']?.toString(),
      audioUrl: json['audioUrl'] ?? json['audio_url']?.toString(), // Lấy từ API
      passed: json['passed'] == true || overall >= 6.0,
    );
  }
}
