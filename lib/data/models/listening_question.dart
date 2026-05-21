class ListeningQuestion {
  final String id;
  final int part;
  final String? questionText;
  final String? imageUrl;
  final String? audioUrl;
  final List<String> options;
  final String correctAnswer;
  final String? explanation;
  final String? explanationVi;
  final String? script;
  final String? groupId;
  final String difficulty;

  ListeningQuestion({
    required this.id,
    required this.part,
    this.questionText,
    this.imageUrl,
    this.audioUrl,
    required this.options,
    required this.correctAnswer,
    this.explanation,
    this.explanationVi,
    this.script,
    this.groupId,
    this.difficulty = 'medium',
  });

  factory ListeningQuestion.fromJson(Map<String, dynamic> json) {
    return ListeningQuestion(
      id: json['id'] ?? '',
      part: json['part'] ?? 0,
      questionText: json['questionText'],
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
      options: List<String>.from(json['options'] ?? []),
      correctAnswer: json['correctAnswer'] ?? '',
      explanation: json['explanation'],
      explanationVi: json['explanationVi'],
      script: json['script'],
      groupId: json['groupId'],
      difficulty: json['difficulty'] ?? 'medium',
    );
  }
}

class ListeningGroup {
  final String id;
  final int part;
  final String? passageText;
  final String? script;
  final String? imageUrl;
  final String? audioUrl;
  final List<ListeningQuestion> questions;
  final String? source;

  ListeningGroup({
    required this.id,
    required this.part,
    this.passageText,
    this.script,
    this.imageUrl,
    this.audioUrl,
    required this.questions,
    this.source,
  });

  factory ListeningGroup.fromJson(Map<String, dynamic> json) {
    return ListeningGroup(
      id: json['id'] ?? '',
      part: json['part'] ?? 0,
      passageText: json['passageText'],
      script: json['script'],
      imageUrl: json['imageUrl'],
      audioUrl: json['audioUrl'],
      questions: (json['questions'] as List?)
              ?.map((q) => ListeningQuestion.fromJson(q))
              .toList() ??
          [],
      source: json['source'],
    );
  }
}
