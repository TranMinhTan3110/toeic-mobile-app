class VocabularyHubStats {
  final int starredCount;
  final int dueCount;
  final int studiedCount;
  final int masteredCount;
  final int totalCount;
  final int dailyTargetCount;

  VocabularyHubStats({
    required this.starredCount,
    required this.dueCount,
    required this.studiedCount,
    required this.masteredCount,
    required this.totalCount,
    required this.dailyTargetCount,
  });

  factory VocabularyHubStats.fromJson(Map<String, dynamic> json) {
    return VocabularyHubStats(
      starredCount: json['starredCount'] ?? 0,
      dueCount: json['dueCount'] ?? 0,
      studiedCount: json['studiedCount'] ?? 0,
      masteredCount: json['masteredCount'] ?? 0,
      totalCount: json['totalCount'] ?? 0,
      dailyTargetCount: json['dailyTargetCount'] ?? 500,
    );
  }

  VocabularyHubStats copyWith({
    int? starredCount,
    int? dueCount,
    int? studiedCount,
    int? masteredCount,
    int? totalCount,
    int? dailyTargetCount,
  }) {
    return VocabularyHubStats(
      starredCount: starredCount ?? this.starredCount,
      dueCount: dueCount ?? this.dueCount,
      studiedCount: studiedCount ?? this.studiedCount,
      masteredCount: masteredCount ?? this.masteredCount,
      totalCount: totalCount ?? this.totalCount,
      dailyTargetCount: dailyTargetCount ?? this.dailyTargetCount,
    );
  }
}
