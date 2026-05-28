class WritingEvaluation {
  final double overallScore;
  final Map<String, double> criteriaScores;
  final String feedback;
  final String correctionsVi;
  final String suggestedImprovement;
  final String? userAnswer;
  final bool passed;

  WritingEvaluation({
    required this.overallScore,
    required this.criteriaScores,
    required this.feedback,
    required this.correctionsVi,
    required this.suggestedImprovement,
    this.userAnswer,
    this.passed = false,
  });

  factory WritingEvaluation.fromJson(Map<String, dynamic> json) {
    final overall =
        (json['overallScore'] ?? json['overall_score'] as num?)?.toDouble() ??
            0.0;
    final criteriaRaw =
        json['criteriaScores'] ?? json['criteria_scores'] as Map? ?? {};
    return WritingEvaluation(
      overallScore: overall,
      criteriaScores: Map<String, double>.from(
        criteriaRaw.map(
          (k, v) => MapEntry(k.toString(), (v as num).toDouble()),
        ),
      ),
      feedback: json['feedback']?.toString() ?? '',
      correctionsVi: json['correctionsVi']?.toString() ?? json['corrections_vi']?.toString() ?? '',
      suggestedImprovement: json['suggestedImprovement']?.toString() ?? json['suggested_improvement']?.toString() ?? '',
      userAnswer: json['userAnswer']?.toString() ?? json['user_answer']?.toString(),
      passed: json['passed'] == true || overall >= 6.0,
    );
  }
}
