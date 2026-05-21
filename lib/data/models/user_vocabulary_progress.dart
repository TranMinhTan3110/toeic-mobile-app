class UserVocabularyProgress {
  final String id;
  final String userId;
  final String vocabularyId;
  final int repetitions;
  final double interval;
  final double easinessFactor;
  final DateTime? lastReviewedAt;
  final DateTime nextReviewDate;
  final int masteryLevel;
  final bool isMastered;

  UserVocabularyProgress({
    required this.id,
    required this.userId,
    required this.vocabularyId,
    required this.repetitions,
    required this.interval,
    required this.easinessFactor,
    this.lastReviewedAt,
    required this.nextReviewDate,
    required this.masteryLevel,
    required this.isMastered,
  });

  factory UserVocabularyProgress.fromJson(Map<String, dynamic> json) {
    return UserVocabularyProgress(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      vocabularyId: json['vocabularyId'] ?? '',
      repetitions: json['repetitions'] ?? 0,
      interval: (json['interval'] ?? 0).toDouble(),
      easinessFactor: (json['easinessFactor'] ?? 2.5).toDouble(),
      lastReviewedAt: json['lastReviewedAt'] != null ? DateTime.parse(json['lastReviewedAt']) : null,
      nextReviewDate: DateTime.parse(json['nextReviewDate']),
      masteryLevel: json['masteryLevel'] ?? 0,
      isMastered: json['isMastered'] ?? false,
    );
  }
}
