class UserProfileModel {
  final String uid;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final int targetScore;
  final String currentLevel;
  final String plan;
  final List<String> preferredSkills;
  final int experiencePoints;
  final int weeklyEp;
  final String weeklyEpPeriodKey;
  final int streakDays;
  final int bestStreakDays;
  final int totalStudyMinutes;
  final DateTime createdAt;
  final String? phoneNumber;
  final String? gender;
  final String? birthDate;

  UserProfileModel({
    required this.uid,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    required this.targetScore,
    required this.currentLevel,
    required this.plan,
    required this.preferredSkills,
    required this.experiencePoints,
    required this.weeklyEp,
    required this.weeklyEpPeriodKey,
    required this.streakDays,
    required this.bestStreakDays,
    required this.totalStudyMinutes,
    required this.createdAt,
    this.phoneNumber,
    this.gender,
    this.birthDate,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      uid: json['uid'] ?? json['uid'] ?? '',
      displayName: json['displayName'] ?? '',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
      targetScore: json['targetScore'] ?? 0,
      currentLevel: json['currentLevel'] ?? '',
      plan: json['plan'] ?? '',
      preferredSkills: List<String>.from(json['preferredSkills'] ?? []),
      experiencePoints: json['experiencePoints'] ?? 0,
      weeklyEp: json['weeklyEp'] ?? 0,
      weeklyEpPeriodKey: json['weeklyEpPeriodKey'] ?? '',
      streakDays: json['streakDays'] ?? 0,
      bestStreakDays: json['bestStreakDays'] ?? 0,
      totalStudyMinutes: json['totalStudyMinutes'] ?? 0,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      phoneNumber: json['phoneNumber'],
      gender: json['gender'],
      birthDate: json['birthDate'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'displayName': displayName,
      'email': email,
      'avatarUrl': avatarUrl,
      'targetScore': targetScore,
      'currentLevel': currentLevel,
      'plan': plan,
      'preferredSkills': preferredSkills,
      'experiencePoints': experiencePoints,
      'weeklyEp': weeklyEp,
      'weeklyEpPeriodKey': weeklyEpPeriodKey,
      'streakDays': streakDays,
      'bestStreakDays': bestStreakDays,
      'totalStudyMinutes': totalStudyMinutes,
      'createdAt': createdAt.toIso8601String(),
      'phoneNumber': phoneNumber,
      'gender': gender,
      'birthDate': birthDate,
    };
  }

  UserProfileModel copyWith({
    String? uid,
    String? displayName,
    String? email,
    String? avatarUrl,
    int? targetScore,
    String? currentLevel,
    String? plan,
    List<String>? preferredSkills,
    int? experiencePoints,
    int? weeklyEp,
    String? weeklyEpPeriodKey,
    int? streakDays,
    int? bestStreakDays,
    int? totalStudyMinutes,
    DateTime? createdAt,
    String? phoneNumber,
    String? gender,
    String? birthDate,
  }) {
    return UserProfileModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      targetScore: targetScore ?? this.targetScore,
      currentLevel: currentLevel ?? this.currentLevel,
      plan: plan ?? this.plan,
      preferredSkills: preferredSkills ?? this.preferredSkills,
      experiencePoints: experiencePoints ?? this.experiencePoints,
      weeklyEp: weeklyEp ?? this.weeklyEp,
      weeklyEpPeriodKey: weeklyEpPeriodKey ?? this.weeklyEpPeriodKey,
      streakDays: streakDays ?? this.streakDays,
      bestStreakDays: bestStreakDays ?? this.bestStreakDays,
      totalStudyMinutes: totalStudyMinutes ?? this.totalStudyMinutes,
      createdAt: createdAt ?? this.createdAt,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      gender: gender ?? this.gender,
      birthDate: birthDate ?? this.birthDate,
    );
  }
}
