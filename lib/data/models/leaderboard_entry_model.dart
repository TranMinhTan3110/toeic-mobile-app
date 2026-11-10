class LeaderboardEntryModel {
  final int rank;
  final String uid;
  final String displayName;
  final String? avatarUrl;
  final int weeklyEp;
  final int streakDays;

  LeaderboardEntryModel({
    required this.rank,
    required this.uid,
    required this.displayName,
    this.avatarUrl,
    required this.weeklyEp,
    required this.streakDays,
  });

  factory LeaderboardEntryModel.fromJson(Map<String, dynamic> json) {
    return LeaderboardEntryModel(
      rank: json['rank'] ?? 0,
      uid: json['uid'] ?? '',
      displayName: json['displayName'] ?? '',
      avatarUrl: json['avatarUrl'],
      weeklyEp: json['weeklyEp'] ?? 0,
      streakDays: json['streakDays'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'rank': rank,
      'uid': uid,
      'displayName': displayName,
      'avatarUrl': avatarUrl,
      'weeklyEp': weeklyEp,
      'streakDays': streakDays,
    };
  }
}
