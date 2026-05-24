class ReviewScheduleItem {
  final String vocabularyId;
  final String word;
  final String definitionVi;
  final String wordType;
  final int repetitions;
  final int masteryLevel;
  final bool isMastered;
  final DateTime? lastReviewedAt;
  final DateTime nextReviewDate;
  final bool isDue;
  final int daysUntilDue;

  ReviewScheduleItem({
    required this.vocabularyId,
    required this.word,
    required this.definitionVi,
    required this.wordType,
    required this.repetitions,
    required this.masteryLevel,
    required this.isMastered,
    this.lastReviewedAt,
    required this.nextReviewDate,
    required this.isDue,
    required this.daysUntilDue,
  });

  factory ReviewScheduleItem.fromJson(Map<String, dynamic> json) {
    return ReviewScheduleItem(
      vocabularyId:   json['vocabularyId'] ?? '',
      word:           json['word'] ?? '',
      definitionVi:   json['definitionVi'] ?? '',
      wordType:       json['wordType'] ?? '',
      repetitions:    json['repetitions'] ?? 0,
      masteryLevel:   json['masteryLevel'] ?? 0,
      isMastered:     json['isMastered'] ?? false,
      lastReviewedAt: json['lastReviewedAt'] != null
          ? DateTime.tryParse(json['lastReviewedAt'])
          : null,
      nextReviewDate: DateTime.tryParse(json['nextReviewDate'] ?? '') ?? DateTime.now(),
      isDue:          json['isDue'] ?? false,
      daysUntilDue:   json['daysUntilDue'] ?? 0,
    );
  }
}
