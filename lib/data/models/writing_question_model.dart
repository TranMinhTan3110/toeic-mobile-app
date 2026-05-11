class WritingQuestion {
  final String id;
  final int taskNumber;
  final String taskType;
  final String promptText;
  final String? promptImageUrl;
  final List<String> givenWords;
  final String? emailContent;
  final List<String> emailQuestions;
  final int timeLimit;
  final int? minWords;
  final int? maxWords;
  final int maxScore;
  final List<String> scoringCriteria;
  final String? sampleAnswer;
  final String? topic;
  final String difficulty;
  final String? examSetId;
  final bool isPractice;

  WritingQuestion({
    required this.id,
    required this.taskNumber,
    required this.taskType,
    required this.promptText,
    this.promptImageUrl,
    required this.givenWords,
    this.emailContent,
    required this.emailQuestions,
    required this.timeLimit,
    this.minWords,
    this.maxWords,
    required this.maxScore,
    required this.scoringCriteria,
    this.sampleAnswer,
    this.topic,
    required this.difficulty,
    this.examSetId,
    required this.isPractice,
  });

  factory WritingQuestion.fromJson(Map<String, dynamic> json) {
    return WritingQuestion(
      id: json['id'] ?? '',
      taskNumber: json['taskNumber'] ?? 0,
      taskType: json['taskType'] ?? '',
      promptText: json['promptText'] ?? '',
      promptImageUrl: json['promptImageUrl'],
      givenWords: List<String>.from(json['givenWords'] ?? []),
      emailContent: json['emailContent'],
      emailQuestions: List<String>.from(json['emailQuestions'] ?? []),
      timeLimit: json['timeLimit'] ?? 0,
      minWords: json['minWords'],
      maxWords: json['maxWords'],
      maxScore: json['maxScore'] ?? 0,
      scoringCriteria: List<String>.from(json['scoringCriteria'] ?? []),
      sampleAnswer: json['sampleAnswer'],
      topic: json['topic'],
      difficulty: json['difficulty'] ?? '',
      examSetId: json['examSetId'],
      isPractice: json['isPractice'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'taskNumber': taskNumber,
      'taskType': taskType,
      'promptText': promptText,
      'promptImageUrl': promptImageUrl,
      'givenWords': givenWords,
      'emailContent': emailContent,
      'emailQuestions': emailQuestions,
      'timeLimit': timeLimit,
      'minWords': minWords,
      'maxWords': maxWords,
      'maxScore': maxScore,
      'scoringCriteria': scoringCriteria,
      'sampleAnswer': sampleAnswer,
      'topic': topic,
      'difficulty': difficulty,
      'examSetId': examSetId,
      'isPractice': isPractice,
    };
  }
}
