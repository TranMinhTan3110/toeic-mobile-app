class EngagementResultModel {
  final int epAwarded;
  final int totalExperiencePoints;
  final int weeklyEp;
  final int streakDays;
  final int bestStreakDays;
  final double streakMultiplier;
  final bool alreadyAwardedForReference;
  final bool dailyCapReached;

  EngagementResultModel({
    required this.epAwarded,
    required this.totalExperiencePoints,
    required this.weeklyEp,
    required this.streakDays,
    required this.bestStreakDays,
    required this.streakMultiplier,
    this.alreadyAwardedForReference = false,
    this.dailyCapReached = false,
  });

  factory EngagementResultModel.fromJson(Map<String, dynamic> json) {
    return EngagementResultModel(
      epAwarded: json['epAwarded'] ?? 0,
      totalExperiencePoints: json['totalExperiencePoints'] ?? 0,
      weeklyEp: json['weeklyEp'] ?? 0,
      streakDays: json['streakDays'] ?? 0,
      bestStreakDays: json['bestStreakDays'] ?? 0,
      streakMultiplier: (json['streakMultiplier'] ?? 1.0).toDouble(),
      alreadyAwardedForReference: json['alreadyAwardedForReference'] ?? false,
      dailyCapReached: json['dailyCapReached'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'epAwarded': epAwarded,
      'totalExperiencePoints': totalExperiencePoints,
      'weeklyEp': weeklyEp,
      'streakDays': streakDays,
      'bestStreakDays': bestStreakDays,
      'streakMultiplier': streakMultiplier,
      'alreadyAwardedForReference': alreadyAwardedForReference,
      'dailyCapReached': dailyCapReached,
    };
  }
}
